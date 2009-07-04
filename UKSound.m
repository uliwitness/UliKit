//
//  UKSound.m
//  PlayBufferedSoundFile
//
/*
 Copyright (c) 2002-2003, Kurt Revis.  All rights reserved.
 Modified by M. Uli Kusterer, (c) 2004.

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the name of Snoize nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

//
// Acknowledgements:
// Thanks to the following people who have sent improvements and suggestions.
//
// Ben Haller -- threading bug fixes
// Steven Frank -- bug fixes
// Frank Vernon -- changes for QuickTime 4 AAC decoding (VBR)
//

/*
    Renamed to fit into UliKit and added transitionVolumeTo:duration: for fades.
    Report bugs to this modified version to me, so Kurt doesn't get annoyed by
    being asked to fix my mistakes!
*/

#import "UKSound.h"

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/DefaultAudioOutput.h>
#import <CoreAudio/CoreAudio.h>
#import <unistd.h>
#import <mach/mach.h>
#import <mach/mach_error.h>
#import <mach/mach_time.h>

#import "UKVirtualRingBuffer.h"


//
// Theory of operation:
//
// This class uses QuickTime to read the audio file -- getting the format as well as the actual samples.
// We then use the QuickTime SoundConverter to convert the samples to an audio format which is
// suitable for output. This may do format conversion, decompression, and sample rate conversion.
// Then, to actually play the sound, we give the converted data to the CoreAudio default audio output unit.
//
// This can be somewhat confusing.  Note that there are three threads involved:
//
// 1. The calling thread (which calls -play, -stop, etc.) does some setup work, spawns off work into the other
// threads, and returns immediately.  This should probably be the main thread of your application. Even if it
// isn't the main thread, you should only call these methods from one thread.
//
// 2. The feeder thread is periodically woken up. It asks the SoundConverter for a new buffer of converted data.
// The SoundConverter calls our fillSoundConverterBuffer() function when it needs more source samples. We
// provide this data by calling QuickTime (again) to read samples from the file.
//
// 3. The CoreAudio playback thread calls our renderCallback() function periodically when it needs more data
// to play.
//
// Thread 2 notifies thread 1 that it has finished playing via the NSPort signalFinishPort.
// Threads 2 and 3 communicate via the UKVirtualRingBuffer 'ringBuffer' and the int 'playbackStatus'.
// Thread 3 wakes up thread 2 using the Mach semaphore 'semaphore'.
//
// Why do we bother with the ring buffer? Because reading from the file may block, and it is
// strongly recommended not to do so while in the CoreAudio thread (which is a high-priority,
// time-constraint thread).
// Why do we bother using a separate feeder thread? Because in an application, you want the main thread
// to be free to run the UI. Also, the feeder thread needs to have a higher priority than most other threads
// in the system, to ensure that it gets time on a regular basis; it also needs to have be scheduled
// "non-timeshare" so its priority does not change dynamically.
// With this increase in priority comes more responsibility: we must not hog the CPU, or the
// performance and responsiveness of the whole system may suffer. In this case the feeder thread
// is largely IO-bound (except for any decompression that the SoundConverter does) so we're pretty safe.
//
// For more details on thread scheduling parameters, see the archives of the CoreAudio-API list
// at lists.apple.com around the date of 5 May 2002.
//

// 
// Parameters to play with:
//

#define RING_BUFFER_SIZE (128 * 1024)
// Size (in bytes) of ring buffer. Should be a multiple of the page size (currently 4 KB), but it will be rounded up if necessary.
// Too big and we waste memory; too small and we run the risk of the buffer running dry (causing dropouts).
// Instead of hard-coded, this really should be computed, based on two factors: the worst-case time we expect our feeder thread to block, and the data rate of the sound file being played.
// (128 KB is about 371 milliseconds of 44.1k, 32-bit float, stereo sound.)

#define RING_BUFFER_WRITE_CHUNK_SIZE (16 * 1024)
// Size (in bytes) of chunks to write into the ring buffer. Should probably be at least a page.
// Too big and we cause writes to take too long (and the buffer may run dry while we are writing).
// Too small and we waste CPU by waking up and writing too often.

#define FILE_SAMPLE_BUFFER_SIZE (64 * 1024)
// Size (in bytes) of chunks of sample data to read from the file at one time. This is uncompressed, unconverted data.
// This is the amount we pass to GetMediaSample(), but that doesn't mean that the actual filesystem reads will necessarily be this size.

#define FEEDER_THREAD_IMPORTANCE 6
// Additional priority to use for the feeder thread, on top of this task's ordinary priority.
// This should be the lowest possible value that gives good results (no dropouts even when the machine is under load).
// The value here (6) is good on my machine (G4/450, 1 processor, OS X 10.2.1) but don't take my word for it;
// you may want to test and adjust for other machines.
// It looks like we would use 6 to get the equivalent of what iTunes uses.


@interface UKSound (Private)

// Reading file as a QuickTime movie
- (BOOL)openFileAsMovie;
- (BOOL)getMovieSoundFormat:(SoundComponentData *)outSoundFormat decompressionAtom:(AudioFormatAtomPtr *)outAtom isVBR: (BOOL*)outIsVBRPtr;

// Using the SoundConverter to translate from file samples to the audio output's format
- (BOOL)startSoundConverter;
- (void)stopSoundConverter;

static Boolean fillSoundConverterBuffer(SoundComponentDataPtr *data, void *refCon);
- (Boolean)fillSoundConverterBuffer:(SoundComponentDataPtr *)data;

// CoreAudio output
- (BOOL)setUpAudioOutput;
- (BOOL)getOutputSoundConverterFormat:(SoundComponentData *)outputSoundConverterFormat;
static UnsignedFixed ConvertFloat64ToUnsignedFixed(Float64 float64Value);

- (BOOL)startAudioOutput;
- (void)stopAudioOutput;
- (void)tearDownAudioOutput;

// File reading thread
- (void)setThreadPolicy;
- (void)fillRingBufferInThread:(id)unused;
- (void)convertIntoRingBuffer;

// Audio playback thread
static OSStatus renderCallback(void *inRefCon, AudioUnitRenderActionFlags inActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, AudioBuffer *ioData);
- (void)renderWithFlags:(AudioUnitRenderActionFlags)flags timeStamp:(const AudioTimeStamp *)timeStamp bus:(UInt32)busNumber buffer:(AudioBuffer *)ioData;

// Control thread (finishing)
- (BOOL)checkIfInControllingThreadWithSelector:(SEL)selector;
- (void)addSignalFinishPortToControllingRunLoop;
- (void)removeSignalFinishPortFromControllingRunLoop;
- (void)handlePortMessage:(NSPortMessage *)message;
- (void)finishPlaying;

// Fade timer:
-(void) soundFadeTimerAction: (NSTimer*)timer;

@end


@implementation UKSound

enum {
    statusStopped = 0,
    statusReadingFromFile,
    statusPaused,
    statusDoneReadingFromFile,
    statusDonePlaying
};

static NSString *UKSoundStoppingRunLoopMode = @"UKSoundStoppingRunLoopMode";


+ (void)initialize
{
    static BOOL initialized = NO;

    [super initialize];    
    if (!initialized) {
        OSErr err;
        
        initialized = YES;

        err = EnterMovies();
        if (err != noErr)
            NSLog(@"+[UKSound initialize]: EnterMovies() failed with error code %hd", err);
    }
}

- (id)initWithContentsOfURL:(NSURL *)url;
{
    kern_return_t err;

    if (![super init])
        return nil;

    flags.shouldLoop = NO;
    flags.isStopping = NO;
    
    url = [url standardizedURL];
    // Only file URLs are handled currently
    if (![url isFileURL])
        goto errorReturn;
    fileName = [[url path] copy];

    mediaTimeLock = [[NSLock alloc] init];

    soundConverterBufferFillerUPP = NewSoundConverterFillBufferDataUPP(fillSoundConverterBuffer);
    converterSourceSampleDataHandle = NewHandle(FILE_SAMPLE_BUFFER_SIZE);

    if (![self openFileAsMovie])
        goto errorReturn;

    ringBuffer = [(UKVirtualRingBuffer *)[UKVirtualRingBuffer alloc] initWithLength:RING_BUFFER_SIZE];
    if (!ringBuffer)
        goto errorReturn;

    err = semaphore_create(mach_task_self(), &semaphore, SYNC_POLICY_FIFO, 0);
    if (err)  {
#if DEBUG
        mach_error("semaphore_create", err);
#endif
        goto errorReturn;
    }

    signalFinishPort = [[NSPort alloc] init];
    [signalFinishPort setDelegate:self];
    signalFinishPortMessage = [[NSPortMessage alloc] initWithSendPort:signalFinishPort receivePort:nil components:nil];
    signalFinishRunLoopModes = [[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, NSEventTrackingRunLoopMode, UKSoundStoppingRunLoopMode, nil];
    
    playbackStatus = statusStopped;

    if (![self setUpAudioOutput])
        goto errorReturn;

    return self;

errorReturn:
    [self release];
    return nil;
}

- (id)initWithContentsOfFile:(NSString *)path;
{
    NSURL *url;

    url = [NSURL fileURLWithPath:path];
    if (url)
        return [self initWithContentsOfURL:url];
    else {
        [self release];
        return nil;
    }
}

- (void)dealloc
{
    if (outputAudioUnit)
        [self tearDownAudioOutput];

    [fileName release];
    [ringBuffer release];

    if (movie)
        DisposeMovie(movie);

    if (converterSourceSampleDataHandle)
        DisposeHandle(converterSourceSampleDataHandle);

    if (semaphore)
        semaphore_destroy(mach_task_self(), semaphore);

    [signalFinishPort invalidate];
    [signalFinishPort release];
    [signalFinishPortMessage release];
    [signalFinishRunLoopModes release];

    [mediaTimeLock release];

    [super dealloc];
}

- (BOOL)play;
{
    if ([self isPlaying]) {
#if DEBUG
        NSLog(@"can't play because we're already playing");
#endif
        return NO;
    }

    if (!fileName) {
#if DEBUG
        NSLog(@"can't play because there's no file");
#endif
        return NO;
    }

    // Remember which run loop (and thus thread) is controlling playback.
    controllingRunLoop = [NSRunLoop currentRunLoop];
    
    if (![self startSoundConverter])
        return NO;

    // Set the initial status...
    playbackStatus = statusReadingFromFile;
    [ringBuffer empty];

    // Now start the audio.  It doesn't matter that we do this before putting any data into the ring buffer,
    // since we will play silence until any data can be read from it.
    if ([self startAudioOutput]) {
        // When playback finishes, we will want to run some code in this thread.
        // So add our port to this thread's run loop. We will send a message to the port from
        // the feeder thread, causing -handlePortMessage: to be called in this thread.
        [self addSignalFinishPortToControllingRunLoop];
        
        // Start reading the file into the ring buffer, in another thread.
        [NSThread detachNewThreadSelector:@selector(fillRingBufferInThread:) toTarget:self withObject:nil];

        return YES;
    } else {
        playbackStatus = statusStopped;
        [self stopSoundConverter];
        return NO;
    }
}

- (BOOL)pause;
{
    if (![self checkIfInControllingThreadWithSelector:_cmd])
        return NO;

    if (playbackStatus != statusReadingFromFile)
        return NO;

    playbackStatus = statusPaused;

    // TODO We will play the rest of the data in the ring buffer, and then play silence.
    // Depending on how large the buffer is, there could be a significant length of time before sound goes silent.
    // The render callback could instead check if (playbackStatus == statusPaused), and then play silence
    // without removing from the buffer. That gives us immediate pausing, but there's another problem:
    // if we change the playback position while paused, and then resume, we hear the old audio from the buffer
    // before we hear the audio at the new position.
    // The solution is to empty the buffer when appropriate, but that will be tricky, since it is only safe
    // to empty the ring buffer when we can guarantee that no one is reading or writing it.
    // Setting playbackStatus is not enough to do that.
    
    return YES;
}

- (BOOL)resume;
{
    if (![self checkIfInControllingThreadWithSelector:_cmd])
        return NO;

    if (playbackStatus != statusPaused)
        return NO;

    playbackStatus = statusReadingFromFile;

    return YES;
}

- (BOOL)stop;
{
    if (![self checkIfInControllingThreadWithSelector:_cmd])
        return NO;

    if (![self isPlaying]) {
#if DEBUG
        NSLog(@"can't stop because we're already stopped");
#endif
        return NO;
    }

    // Tell the feeder and render threads to stop.
    playbackStatus = statusDoneReadingFromFile;
    flags.isStopping = YES;

    // If we are still playing, wait until we are completely stopped.
    // Run the current run loop in a private mode until the feeder thread sends the signalFinishPortMessage.
    // We limit waiting to a few seconds so we don't stall forever if the other thread is stuck for some reason.
    if ([self isPlaying])
        [[NSRunLoop currentRunLoop] runMode:UKSoundStoppingRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];

    // Now the stop process is complete
    flags.isStopping = NO;

    return (![self isPlaying]);
}

- (BOOL)isPlaying
{
    return (playbackStatus != statusStopped);
}

- (BOOL)isPaused
{
    return (playbackStatus == statusPaused);
}

- (id)delegate
{
    return nonretainedDelegate;
}

- (void)setDelegate:(id)aDelegate
{
    nonretainedDelegate = aDelegate;
}

- (float)volume;
{
    float volume = 1.0;	// default

    AudioUnitGetParameter(outputAudioUnit, kHALOutputParam_Volume, kAudioUnitScope_Global, 0, &volume);
    return volume;
}

- (void)setVolume:(float)value;
{
    AudioUnitSetParameter(outputAudioUnit, kHALOutputParam_Volume, kAudioUnitScope_Global, 0, value, 0);
}

- (BOOL)shouldLoop;
{
    return flags.shouldLoop;
}

- (void)setShouldLoop:(BOOL)value;
{
    flags.shouldLoop = value;
}

- (float)duration;
{
    // convert mediaDuration to seconds
    if (mediaTimeScale == 0)
        return 0.0f;
    else
        return (double)mediaDuration / (double)mediaTimeScale;
}

- (float)playbackPosition;
{
    // No need to lock mediaTimeLock; reading currentMediaTime is atomic

    if (mediaTimeScale == 0)
        return 0.0f;
    else
        return (double)currentMediaTime / (double)mediaTimeScale;
}

- (void)setPlaybackPosition:(float)value
{
    TimeValue newTime;

    [mediaTimeLock lock];

    newTime = (TimeValue)floor(value * (double)mediaTimeScale);
    if (newTime < 0)
        newTime = 0;
    else if (newTime > mediaDuration)
        newTime = mediaDuration;
    currentMediaTime = newTime;
    flags.currentMediaTimeWasChanged = YES;

    [mediaTimeLock unlock];
}

-(void) transitionVolumeTo: (float)value duration: (float)time stopPlaying: (BOOL)doStop
{
	[self transitionVolumeTo: value duration: time stopPlaying: doStop
			pausePlaying: NO];
}

-(void) transitionVolumeTo: (float)value duration: (float)time stopPlaying: (BOOL)doStop
			pausePlaying: (BOOL)doPause
{
    fadeDuration = time;
    fadeDestVolume = value;
    
    float       volDiff = (fadeDestVolume -[self volume]);
    
    fadeStepWidth = volDiff / (time * 10);
    
    stopPlayingAfterFade = doStop;
    pausePlayingAfterFade = doPause;
    
    if( fadeStepWidth != 0 )
        [NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(soundFadeTimerAction:) userInfo: nil repeats: YES];
    else if( doStop )
        [self stop];
	else if( doPause )
        [self pause];
}

@end


@implementation UKSound (Private)

//
// Reading file as a QuickTime movie
//

- (BOOL)openFileAsMovie;
{
    NSURL *fileURL;
    FSRef fsRef;
    FSSpec fsSpec;
    OSErr err;
    short fileRefNum;
    short resID = 0;
    Boolean wasChanged;
    Track track;

    // Convert our file name to an FSSpec
    fileURL = [NSURL fileURLWithPath:fileName];
    if (!CFURLGetFSRef((CFURLRef)fileURL, &fsRef))
        return NO;
    if (FSGetCatalogInfo(&fsRef, kFSCatInfoNone, NULL, NULL, &fsSpec, NULL) != noErr)
        return NO;

    // Open the movie file
    err = OpenMovieFile(&fsSpec, &fileRefNum, fsRdPerm);
    if (err != noErr)
        return NO;

    // Instantiate the movie and close the file
    err = NewMovieFromFile(&movie, fileRefNum, &resID, NULL, newMovieActive, &wasChanged);
    CloseMovieFile(fileRefNum);
    if (err != noErr)
        return NO;

    // Get the first sound track
    track = GetMovieIndTrackType(movie, 1, SoundMediaType, movieTrackMediaType);
    if (!track) 
        return NO;

    // Get the sound track's media
    media = GetTrackMedia(track);
    if (!media)
        return NO;
    
    return YES;
}

- (BOOL)getMovieSoundFormat:(SoundComponentData *)outSoundFormat decompressionAtom:(AudioFormatAtomPtr *)outAtom isVBR: (BOOL*)outIsVBRPtr
{
    OSErr err;
    SoundDescriptionV1Handle sourceSoundDescription;
    Handle extension;

    // Get the description of the sample data
    sourceSoundDescription = (SoundDescriptionV1Handle)NewHandle(0);
    GetMediaSampleDescription(media, 1, (SampleDescriptionHandle)sourceSoundDescription);
    err = GetMoviesError();
    if (err != noErr) {
        DisposeHandle((Handle)sourceSoundDescription);
        return NO;
    }

    // Get the "magic" decompression atom.
    // This extension to the SoundDescription information stores data specific to a given audio decompressor.
    // Some audio decompression algorithms require a set of out-of-stream values to configure the decompressor.
    extension = NewHandle(0);
    err = GetSoundDescriptionExtension((SoundDescriptionHandle)sourceSoundDescription, &extension, siDecompressionParams);
    if (noErr == err) {
        // Copy the atom
        Size size;

        size = GetHandleSize(extension);
        HLock(extension);
        *outAtom = malloc(size);
        memcpy(*outAtom, *extension, size);
        HUnlock(extension);
    } else {
        // If it doesn't have an atom, that's OK
        *outAtom = NULL;
    }

    // Remember the format of the audio in the movie
    // (converting from a SoundDescription to a SoundComponentData)
    outSoundFormat->flags = 0;
    outSoundFormat->format = (*sourceSoundDescription)->desc.dataFormat;
    outSoundFormat->numChannels = (*sourceSoundDescription)->desc.numChannels;
    outSoundFormat->sampleSize = (*sourceSoundDescription)->desc.sampleSize;
    outSoundFormat->sampleRate = (*sourceSoundDescription)->desc.sampleRate;
    outSoundFormat->sampleCount = 0;
    outSoundFormat->buffer = 0;
    outSoundFormat->reserved = 0;

    if (outIsVBRPtr)
        *outIsVBRPtr = ((*sourceSoundDescription)->desc.compressionID == variableCompression);

    DisposeHandle(extension);
    DisposeHandle((Handle)sourceSoundDescription);

    return YES;
}


//
// Using the SoundConverter to translate from file samples to the audio output's format
//

- (BOOL)startSoundConverter;
{
    OSErr err;
    SoundComponentData outputSoundConverterFormat;
    SoundComponentData sourceSoundConverterFormat;
    AudioFormatAtomPtr audioFormatAtom = NULL;
    BOOL isVBR;

    // Get the audio output's format, in a structure that the SoundConverter understands
    if (![self getOutputSoundConverterFormat:&outputSoundConverterFormat])
        goto errorReturn;

    // Get the format of the input file, along with any additional decompression parameters
    if (![self getMovieSoundFormat:&sourceSoundConverterFormat decompressionAtom:&audioFormatAtom isVBR: &isVBR])
        goto errorReturn;

    // Remember if this source is VBR or not
    isSourceVBR = isVBR;

    // Create the sound converter
    err = SoundConverterOpen(&sourceSoundConverterFormat, &outputSoundConverterFormat, &soundConverter);
    if (err != noErr || soundConverter == NULL)
        goto errorReturn;

    // Let the sound converter know that we can handle VBR formats.
    // (This doesn't seem to be strictly necessary but the QT 6 docs say to do it.)
    SoundConverterSetInfo(soundConverter, siClientAcceptsVBR, (void*)true);

    // If we have a decompression atom, give it to the SoundConverter
    if (audioFormatAtom) {
        err = SoundConverterSetInfo(soundConverter, siDecompressionParams, audioFormatAtom);

        // and get rid of it
        free(audioFormatAtom);
        audioFormatAtom = NULL;

        // Sometimes we get the error siUnknownInfoType. (I've seen this in AIFF files which contain a chunk of type 'wave'.)
        // However, we can still continue on and decode successfully.
        if (err != noErr && err != siUnknownInfoType)
            goto errorReturn;
    }        

    // Start reading the movie from the beginning, and remember how long it is
    mediaDuration = GetMediaDuration(media);
    mediaTimeScale = GetMediaTimeScale(media);
    currentMediaTime = 0;
    flags.currentMediaTimeWasChanged = NO;

    // Fill in converterSourceSoundComponentData so as little of it needs to change as possible later on
    converterSourceSoundComponentData.desc.flags = kExtendedSoundData;
    converterSourceSoundComponentData.desc.format = sourceSoundConverterFormat.format;
    converterSourceSoundComponentData.desc.numChannels = sourceSoundConverterFormat.numChannels;
    converterSourceSoundComponentData.desc.sampleSize = sourceSoundConverterFormat.sampleSize;
    converterSourceSoundComponentData.desc.sampleRate = sourceSoundConverterFormat.sampleRate;
    converterSourceSoundComponentData.desc.flags = kExtendedSoundData;
    converterSourceSoundComponentData.recordSize = sizeof(ExtendedSoundComponentData);
    converterSourceSoundComponentData.extendedFlags = kExtendedSoundSampleCountNotValid | kExtendedSoundBufferSizeValid;
    if (isSourceVBR)
        converterSourceSoundComponentData.extendedFlags |= kExtendedSoundCommonFrameSizeValid;
        
    // Finally, begin the conversion
    err = SoundConverterBeginConversion(soundConverter);
    if (err != noErr)
        goto errorReturn;

    return YES;

errorReturn:
    if (soundConverter) {
        SoundConverterClose(soundConverter);
        soundConverter = NULL;
    }

    if (audioFormatAtom)
        free(audioFormatAtom);
    
    return NO;
}

- (void)stopSoundConverter;
{
    if (soundConverter)
        SoundConverterClose(soundConverter);
    soundConverter = NULL;
}

Boolean fillSoundConverterBuffer(SoundComponentDataPtr *data, void *refCon)
{
    return [(UKSound *)refCon fillSoundConverterBuffer:data];
}

- (Boolean)fillSoundConverterBuffer:(SoundComponentDataPtr *)data;
{
    long sourceBytesReturned;
    long numberOfSamples;
    TimeValue sourceReturnedTime, durationPerSample;
    OSErr err;
    Boolean success;

    if (currentMediaTime >= mediaDuration) {
        if (flags.shouldLoop)
            currentMediaTime = 0;
        else
            return false;
    }

    [mediaTimeLock lock];
    flags.currentMediaTimeWasChanged = NO;

    HUnlock(converterSourceSampleDataHandle);

    err = GetMediaSample(
                media,
                converterSourceSampleDataHandle,	// sample data is returned into this handle
                FILE_SAMPLE_BUFFER_SIZE,	// maximum number of bytes of sample data to be returned
                &sourceBytesReturned,	// the number of bytes of sample data returned
                currentMediaTime,		// starting time of the sample to be retrieved
                &sourceReturnedTime,	// indicates the actual time of the returned sample data
                &durationPerSample,		// duration of each sample in the media
                NULL,				// sample description corresponding to the returned sample data (NULL to ignore)
                NULL,				// index value to the sample description that corresponds to the returned sample data (NULL to ignore)
                0,					// maximum number of samples to be returned (0 to use a value that is appropriate for the media)
                &numberOfSamples,		// number of samples it actually returned
                NULL);				// flags that describe the sample (NULL to ignore)

    HLock(converterSourceSampleDataHandle);

    if (noErr == err && sourceBytesReturned > 0) {
        currentMediaTime = sourceReturnedTime + (durationPerSample * numberOfSamples);

        converterSourceSoundComponentData.bufferSize = sourceBytesReturned;
        converterSourceSoundComponentData.desc.buffer = (Byte *)*converterSourceSampleDataHandle;

        // For VBR audio we specified the kExtendedSoundCommonFrameSizeValid flag,
        // so we must fill in the commonFrameSize field appropriately.
        // GetMediaSample always returns all frames with the same size.
        if (isSourceVBR)
            converterSourceSoundComponentData.commonFrameSize = sourceBytesReturned / numberOfSamples;

        *data = (SoundComponentDataPtr)&converterSourceSoundComponentData;
        success = true;
    } else {
        success = false;
    }

    [mediaTimeLock unlock];

    return success;
}


//
// CoreAudio output
//

- (BOOL)setUpAudioOutput;
{
    OSStatus err;
    struct AudioUnitInputCallback inputCallbackStruct;

    // Note: This is what we call "sophisticated error handling".

    err = OpenDefaultAudioOutput(&outputAudioUnit);
    if (err)
        return NO;

    err = AudioUnitInitialize(outputAudioUnit);
    if (err)
        return NO;
    
    // Set up our callback to feed data to the AU.
    inputCallbackStruct.inputProc = renderCallback;
    inputCallbackStruct.inputProcRefCon = self;
    err = AudioUnitSetProperty(outputAudioUnit, kAudioUnitProperty_SetInputCallback, kAudioUnitScope_Input, 0, &inputCallbackStruct, sizeof(inputCallbackStruct));
    if (err)
        return NO;

    return YES;
}

- (BOOL)getOutputSoundConverterFormat:(SoundComponentData *)outputSoundConverterFormat
{
    OSErr err;
    AudioStreamBasicDescription outputCoreAudioFormat;
    UInt32 size;

    // Get the format that the AudioUnit expects us to give it
    size = sizeof(AudioStreamBasicDescription);
    err = AudioUnitGetProperty(outputAudioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &outputCoreAudioFormat, &size);
    if (err)
        return NO;

    // Translate the format to a SoundComponentData for the sound converter. Yuck.
    outputSoundConverterFormat->flags = 0;

    if (outputCoreAudioFormat.mFormatID != kAudioFormatLinearPCM)
        return NO;

    if (outputCoreAudioFormat.mFormatFlags & kLinearPCMFormatFlagIsFloat) {
        if (outputCoreAudioFormat.mBitsPerChannel == 32)
            outputSoundConverterFormat->format = kFloat32Format;
        else if (outputCoreAudioFormat.mBitsPerChannel == 64)
            outputSoundConverterFormat->format = kFloat64Format;
        else
            return NO;
    } else {
        BOOL isBigEndian = (outputCoreAudioFormat.mFormatFlags & kLinearPCMFormatFlagIsBigEndian);

        if (outputCoreAudioFormat.mBitsPerChannel == 16)
            outputSoundConverterFormat->format = (isBigEndian ? k16BitBigEndianFormat : k16BitLittleEndianFormat);
        else if (outputCoreAudioFormat.mBitsPerChannel == 32)
            outputSoundConverterFormat->format = (isBigEndian ? k32BitFormat : k32BitLittleEndianFormat);
        else
            return NO;
    }

    outputSoundConverterFormat->numChannels = outputCoreAudioFormat.mChannelsPerFrame;
    outputSoundConverterFormat->sampleSize = outputCoreAudioFormat.mBitsPerChannel;
    outputSoundConverterFormat->sampleRate = ConvertFloat64ToUnsignedFixed(outputCoreAudioFormat.mSampleRate);
    outputSoundConverterFormat->sampleCount = 0;
    outputSoundConverterFormat->buffer = NULL;
    outputSoundConverterFormat->reserved = 0;

    return YES;
}

UnsignedFixed ConvertFloat64ToUnsignedFixed(Float64 float64Value)
{
    UnsignedFixed fixedValue;

    // High 2 bytes is the integer part of the value
    // Low 2 bytes is the floating point part of the value
    fixedValue = ((UInt32)float64Value << 16) + ((UInt16)((float64Value - floor(float64Value)) * 65536.0));

    return fixedValue;
}

- (BOOL)startAudioOutput;
{
    return (noErr == AudioOutputUnitStart(outputAudioUnit));    
}

- (void)stopAudioOutput;
{
    // Don't bother checking for errors -- we can't do anything about them anyway.
    if (outputAudioUnit)
        AudioOutputUnitStop(outputAudioUnit);
}

- (void)tearDownAudioOutput;
{
    // Don't bother checking for errors -- we can't do anything about them anyway.
    if (outputAudioUnit)
        CloseComponent(outputAudioUnit);
    outputAudioUnit = NULL;
}


//
// File reading thread
// (an ordinary thread, managed by this app)
//

- (void)setThreadPolicy;
{
    // Increase this thread's priority, and turn off timesharing.  See the notes at the top of this file.

    kern_return_t error;
    thread_extended_policy_data_t extendedPolicy;
    thread_precedence_policy_data_t precedencePolicy;

    extendedPolicy.timeshare = 0;
    error = thread_policy_set(mach_thread_self(), THREAD_EXTENDED_POLICY,  (thread_policy_t)&extendedPolicy, THREAD_EXTENDED_POLICY_COUNT);
    if (error != KERN_SUCCESS) {
#if DEBUG
        mach_error("Couldn't set feeder thread's extended policy", error);
#endif
    }

    precedencePolicy.importance = FEEDER_THREAD_IMPORTANCE;
    error = thread_policy_set(mach_thread_self(), THREAD_PRECEDENCE_POLICY, (thread_policy_t)&precedencePolicy, THREAD_PRECEDENCE_POLICY_COUNT);
    if (error != KERN_SUCCESS) {
#if DEBUG
        mach_error("Couldn't set feeder thread's precedence policy", error);
#endif
    }
}

- (void)fillRingBufferInThread:(id)unused
{
    NSAutoreleasePool *pool;

    pool = [[NSAutoreleasePool alloc] init];

    [self setThreadPolicy];
    
    NS_DURING {
        mach_timespec_t timeout = { 2, 0 };	// 2 seconds, 0 nanoseconds

        // While there is still data to be read from the file, fill as much of the ring buffer as is practical.
        // Then sleep until the playback thread wakes us up; at that time, there will be space to write into the buffer again,
        // or playbackStatus will be set to statusDonePlaying.
        while (playbackStatus != statusDonePlaying) {
            if (playbackStatus == statusReadingFromFile)
                [self convertIntoRingBuffer];

            // Wait for the audio thread to signal us that it could use more data, or for the timeout to happen
            semaphore_timedwait(semaphore, timeout);
        }

        // Now we are done playing sound, but we still need to clean things up in the control thread.

#if 0
        // This should work but it doesn't. If it did, we could avoid all the NSPort stuff...
        // Bugs have been filed with Apple: 3157666 and 3157696.
        [controllingRunLoop performSelector:@selector(finishPlaying) target:self argument:nil order:0 modes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, NSEventTrackingRunLoopMode, UKSoundStoppingRunLoopMode, nil]];            
#else
        [signalFinishPortMessage sendBeforeDate:[NSDate distantFuture]];
#endif
        
    } NS_HANDLER {
        NSLog(@"UKSound: exception raised in fillRingBufferInThread: %@", localException);
    } NS_ENDHANDLER;

    [pool release];
}

- (void)convertIntoRingBuffer
{
    // Check if there is a reasonable amount of space available to write to the ring buffer.
    // If there is, ask the SoundConverter to put a chunk of converted data into the ring buffer.
    // Repeat this until the available space to write is too small, or we run out of data to convert.

    BOOL continueReading;

    do {
        UInt32 bytesToWrite, bytesAvailableToWrite;
        void *writePointer;

        continueReading = NO;

        bytesToWrite = RING_BUFFER_WRITE_CHUNK_SIZE;
        bytesAvailableToWrite = [ringBuffer lengthAvailableToWriteReturningPointer:&writePointer];

        if (bytesAvailableToWrite >= bytesToWrite) {
            OSErr err = noErr;
            UInt32 bytesWritten;
            UInt32 framesWritten;
            UInt32 outputFlags;

            if (flags.currentMediaTimeWasChanged) {
                // Throw away any data that may have been buffered inside the SoundConverter,
                // and restart the conversion at the new time.
                UInt32 discardBytesWritten, discardFramesWritten;

                err = SoundConverterEndConversion(soundConverter, NULL, &discardFramesWritten, &discardBytesWritten);
                if (err == noErr)
                    err = SoundConverterBeginConversion(soundConverter);
            }

            if (err == noErr) {
                // Request the sound converter to convert one buffer of data.
                err = SoundConverterFillBuffer(soundConverter,
                                               soundConverterBufferFillerUPP,
                                               self,
                                               writePointer,
                                               bytesToWrite,
                                               &bytesWritten,
                                               &framesWritten,
                                               &outputFlags);
            }
            
            if (err != noErr) {
                // Act like there's no more data
                bytesWritten = 0;
                outputFlags = kSoundConverterDidntFillBuffer;
#if DEBUG
                NSLog(@"SoundConverterFillBuffer returned error %d, terminating playback", err);
#endif
            }
            
            if (bytesWritten > 0)
                [ringBuffer didWriteLength:bytesWritten];

            if (outputFlags & kSoundConverterDidntFillBuffer) {
                // We have read the last of the file (or hit an error in reading it, or EOF). So now we're done.
                playbackStatus = statusDoneReadingFromFile;
            } else {
                // Immediately go back around for another chunk.
                continueReading = YES;
            }
        }
    } while (continueReading);
}


//
// Audio playback thread
// (time-constraint, managed by CoreAudio)
//

static OSStatus renderCallback(void *inRefCon, AudioUnitRenderActionFlags inActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, AudioBuffer *ioData)
{
    // Thunk over to the Objective-C object
    [(UKSound *)inRefCon renderWithFlags:inActionFlags timeStamp:inTimeStamp bus:inBusNumber buffer:ioData];

    return noErr;
}

- (void)renderWithFlags:(AudioUnitRenderActionFlags)renderFlags timeStamp:(const AudioTimeStamp *)timeStamp bus:(UInt32)busNumber buffer:(AudioBuffer *)ioData;
{
    UInt32 bytesAvailable, bytesToRead;
    void *readPointer;
    id capturedDelegate;

    // If we're stopping early, short-circuit through a lot of work
    if (flags.isStopping && playbackStatus != statusDonePlaying) {
        // Play silence
        bzero(ioData->mData, ioData->mDataByteSize);
        // Tell the feeder thread that it's finished
        playbackStatus = statusDonePlaying;
        semaphore_signal(semaphore);
        // and that's all
        return;
    }
    
    // If playback is stopped, or if we have played all the sound there is to play, just play silence
    if (playbackStatus == statusStopped || playbackStatus == statusDonePlaying) {
        bzero(ioData->mData, ioData->mDataByteSize);
        return;
    }

    // Normal case: we want to read some audio data from the ring buffer.
    // How much is available?
    bytesAvailable = [ringBuffer lengthAvailableToReadReturningPointer:&readPointer];
    if (bytesAvailable >= ioData->mDataByteSize) {
        bytesToRead = ioData->mDataByteSize;
    } else {
        // The ring buffer has run dry.  This happens normally when we get to the end of the file's data, and
        // also often happens after the audio has been started but before the feeder thread has run yet.
        // If neither condition is the case, then the filler thread did not keep up for some reason, and we are
        // forced to play a dropout.
        
        // Just read as much as possible from the ring buffer, and fill the result of the audio buffer with zero.
        bytesToRead = bytesAvailable;
        bzero(ioData->mData + bytesToRead, ioData->mDataByteSize - bytesToRead);

        // We may change playbackStatus later (see below).
    }

    if (bytesToRead > 0) {
        // Finally read from the ring buffer.
        memcpy(ioData->mData, readPointer, bytesToRead);            
        [ringBuffer didReadLength:bytesToRead];
    }

    // Someone could be changing the delegate in another thread,
    // so make sure we grab the value of the variable 'nonretainedDelegate' exactly once
    capturedDelegate = nonretainedDelegate;
    if ([capturedDelegate respondsToSelector:@selector(sound:didPlayAudioBuffer:)])
        [capturedDelegate sound:self didPlayAudioBuffer:ioData];

    // If there is no more data to be read, tell the feeder thread that we are done playing.
    if (bytesAvailable == 0 && playbackStatus == statusDoneReadingFromFile)
        playbackStatus = statusDonePlaying;

    // If there is now enough space available to write into the ring buffer, wake up the feeder thread.
    if (bytesAvailable < (RING_BUFFER_SIZE - RING_BUFFER_WRITE_CHUNK_SIZE))
        semaphore_signal(semaphore);
}

//
// Control thread (finishing up)
//

- (BOOL)checkIfInControllingThreadWithSelector:(SEL)selector
{
    BOOL inRightThread = ([NSRunLoop currentRunLoop] == controllingRunLoop);

#if DEBUG
    if (!inRightThread)
        NSLog(@"UKSound: %@ should only be called in the same thread that called -play", NSStringFromSelector(selector));
#endif

    return inRightThread;
}

- (void)addSignalFinishPortToControllingRunLoop
{
    NSEnumerator *enumerator;
    NSString *mode;

    enumerator = [signalFinishRunLoopModes objectEnumerator];
    while ((mode = [enumerator nextObject]))
        [controllingRunLoop addPort:signalFinishPort forMode:mode];
}

- (void)removeSignalFinishPortFromControllingRunLoop
{
    NSEnumerator *enumerator;
    NSString *mode;

    enumerator = [signalFinishRunLoopModes objectEnumerator];
    while ((mode = [enumerator nextObject]))
        [controllingRunLoop removePort:signalFinishPort forMode:mode];
}

- (void)handlePortMessage:(NSPortMessage *)message
{
    [self removeSignalFinishPortFromControllingRunLoop];
    [self finishPlaying];
}

- (void)finishPlaying
{
    id capturedDelegate;

    // Clean up.
    [self stopAudioOutput];
    [self stopSoundConverter];

    playbackStatus = statusStopped;

    // Tell the delegate that playback is finished.
    // Someone could be changing the delegate in another thread,
    // so make sure we grab the value of the variable 'nonretainedDelegate' exactly once
    capturedDelegate = nonretainedDelegate;
    if ([capturedDelegate respondsToSelector:@selector(sound:didFinishPlaying:)])
        [capturedDelegate sound:self didFinishPlaying:(currentMediaTime == mediaDuration)];
}

-(void) soundFadeTimerAction: (NSTimer*)timer
{
    NSObject* capturedDelegate = nonretainedDelegate;

    // Finished playing during fade? Abort fade:
    if( ![self isPlaying] )
    {
        if( [capturedDelegate respondsToSelector:@selector(sound:didFadeIn:)] )
            [capturedDelegate sound: self didFadeIn: YES];
        [timer invalidate];
        return;
    }
    
    // Otherwise, step on in fade:
    float       newVolume = [self volume] +fadeStepWidth;
    BOOL        didFinishFade = NO;
    
  #if DEBUG
    NSLog( @"Fade: %f -> %f (%f)", [self volume], newVolume, fadeStepWidth );
  #endif
    
    // Exceeded destination value? Pin to dest and stop timer:
    if( fadeStepWidth > 0 && newVolume > fadeDestVolume )
    {
        newVolume = fadeDestVolume;
        [timer invalidate];
        if( stopPlayingAfterFade )
            [self stop];
        else if( pausePlayingAfterFade )
            [self pause];
      #if DEBUG
        NSLog( @"\tstopped timer." );
      #endif
        didFinishFade = YES;
    }
    else if( fadeStepWidth < 0 && newVolume < fadeDestVolume )
    {
        newVolume = fadeDestVolume;
        [timer invalidate];
        if( stopPlayingAfterFade )
            [self stop];
        else if( pausePlayingAfterFade )
            [self pause];
      #if DEBUG
        NSLog( @"\tstopped timer." );
      #endif
        didFinishFade = YES;
    }
    
    // Change volume:
    [self setVolume: newVolume];
    
    // Notify delegate:
    if( [capturedDelegate respondsToSelector:@selector(sound:didFadeIn:)] )
        [capturedDelegate sound: self didFadeIn: didFinishFade];
}

@end
