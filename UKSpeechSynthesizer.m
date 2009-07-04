//
//  UKSpeechSynthesizer.m
//  UKSpeechSynthesizer
//
//  Created by Uli Kusterer on Mon Jun 30 2003.
//  Copyright (c) 2003 M. Uli Kusterer. All rights reserved.
//

/* -----------------------------------------------------------------------------
	Headers:
   -------------------------------------------------------------------------- */

#import <Carbon/Carbon.h>
#import "UKSpeechSynthesizer.h"
#import "UKHelperMacros.h"


/* -----------------------------------------------------------------------------
	Constants:
   -------------------------------------------------------------------------- */

// This is what we prefix when returning voice identifiers so we're compatible with NSSpeechChannel:
#define UK_SPEECH_VOICE_PREFIX  @"com.apple.speech.synthesis.voice."

NSString* const NSSpeechPitchBaseProperty = @"NSSpeechPitchBaseProperty";


/* -----------------------------------------------------------------------------
	Prototypes:
   -------------------------------------------------------------------------- */

pascal void		MyPhonemeCallback( SpeechChannel chan, long refCon, short phonemeOpcode );
pascal void		MySpeechDoneCallback( SpeechChannel chan, long refCon );


@interface UKSpeechSynthesizer (PrivateMethods)

-(id)			reallocSpeechChannelWithVoice: (VoiceSpec*)spec;
-(void)			setPhonemeOpcode: (short)n;
-(void)			notifySpeechDoneObject: (id)dummy;
-(void)			notifySpeechPhonemeObject: (id)dummy;

@end


@implementation UKSpeechSynthesizer

/* -----------------------------------------------------------------------------
	Class methods:
   -------------------------------------------------------------------------- */

+(id)			speechSynthesizer
{
	return [[[self alloc] autorelease] init];
}


+(id)			speechSynthesizerWithVoice: (NSString*)voiceName
{
	return [[[self alloc] autorelease] initWithVoice: voiceName];
}



+(VoiceSpec)	voiceSpecFromVoice: (NSString*)voiceName
{
	VoiceSpec			spec = { 0 };
	short				count, x;
	VoiceDescription	vInfo;
	
	if( CountVoices( &count ) != noErr )
		return spec;
	
	NSAutoreleasePool*  pool = [[NSAutoreleasePool alloc] init];
	for( x = 0; x < count; x++ )
	{
		if( GetIndVoice( x, &spec ) == noErr )
		{
			if( GetVoiceDescription( &spec, &vInfo, sizeof(vInfo) ) == noErr )
			{
				if( [[UK_SPEECH_VOICE_PREFIX stringByAppendingString: [NSString stringWithCString:(char*)(vInfo.name +1) length:(vInfo.name[0])]] isEqualToString:voiceName] )
				{
					[pool release];
					return spec;
				}
			}
		}
	}
	
	spec.id = 0; spec.creator = 0;
	
	[pool release];
	return spec;
}


+(NSArray*)	availableVoices
{
	VoiceSpec			spec = { 0 };
	short				count, x;
	VoiceDescription	vInfo;
	NSMutableArray*		theArray = [NSMutableArray array];
	
	if( CountVoices( &count ) != noErr )
		return nil;
	
	NSAutoreleasePool*  pool = [[NSAutoreleasePool alloc] init];
	for( x = 0; x < count; x++ )
	{
		if( GetIndVoice( x, &spec ) == noErr )
		{
			if( GetVoiceDescription( &spec, &vInfo, sizeof(vInfo) ) == noErr )
				[theArray addObject: [UK_SPEECH_VOICE_PREFIX stringByAppendingString: [NSString stringWithCString:(char*)(vInfo.name +1) length:(vInfo.name[0])]]];
		}
	}
	
	[pool release];
	return theArray;
}


+(NSString*)	voiceFromVoiceSpec: (VoiceSpec*)spec
{
	VoiceDescription	vInfo;

	if( GetVoiceDescription( spec, &vInfo, sizeof(vInfo) ) == noErr )
	{
		return( [UK_SPEECH_VOICE_PREFIX stringByAppendingString: [NSString stringWithCString:(char*)(vInfo.name +1) length:(vInfo.name[0])]] );
	}
	else
		return nil;
}


+(NSString*)		defaultVoice
{
	return[self voiceFromVoiceSpec: NULL];
}


+(NSDictionary*)	attributesForVoice:(NSString*)voice
{
	VoiceDescription	vInfo;
	VoiceSpec			spec = [self voiceSpecFromVoice: voice];
	if( GetVoiceDescription( &spec, &vInfo, sizeof(vInfo) ) == noErr )
	{
		NSMutableDictionary*	dict = [NSMutableDictionary dictionary];
		[dict setObject: voice forKey: NSVoiceIdentifier];
		[dict setObject: [NSString stringWithCString:(char*)(vInfo.name +1) length:(vInfo.name[0])] forKey: NSVoiceName];
		[dict setObject: [NSString stringWithCString:(char*)(vInfo.comment +1) length:(vInfo.comment[0])] forKey: NSVoiceDemoText];
		[dict setObject: [NSNumber numberWithShort: vInfo.age] forKey: NSVoiceAge];
		
		NSString*   genders[3] = {  NSVoiceGenderNeuter,
									NSVoiceGenderMale,
									NSVoiceGenderFemale };
		
		[dict setObject: genders[vInfo.gender] forKey: NSVoiceGender];
		[dict setObject: [NSNumber numberWithShort: vInfo.language] forKey: NSVoiceLanguage];
		
		return dict;
	}
	else
		return nil;
}


+(BOOL)			isAnyApplicationSpeaking
{
	return SpeechBusySystemWide();
}


/* -----------------------------------------------------------------------------
	Instance methods:
   -------------------------------------------------------------------------- */

-(id)	init
{
	if( self = [super init] )
	{
		speechChannel = nil;
		speechPhonemeUPP = speechDoneUPP = nil;
		delegate = nil;
		buffer = nil;
		
		speechPhonemeUPP = NewSpeechPhonemeUPP( &MyPhonemeCallback );
		speechDoneUPP = NewSpeechDoneUPP( &MySpeechDoneCallback );
	
		if( [self reallocSpeechChannelWithVoice: nil] == nil )
			return nil;
	}
	return self;
}

-(id)	initWithVoice: (NSString*)voiceName
{
	if( self = [super init] )
	{
		VoiceSpec	spec = [UKSpeechSynthesizer voiceSpecFromVoice:voiceName];
		speechChannel = nil;
		speechPhonemeUPP = speechDoneUPP = nil;
		delegate = nil;
		buffer = nil;
		
		speechPhonemeUPP = NewSpeechPhonemeUPP( &MyPhonemeCallback );
		speechDoneUPP = NewSpeechDoneUPP( &MySpeechDoneCallback );
	
		if( [self reallocSpeechChannelWithVoice: &spec] == nil )
			return nil;
	}
	return self;
}

-(void)	dealloc
{
	DisposeSpeechChannel( speechChannel );
	if( speechDoneUPP != nil )
		DisposeSpeechDoneUPP( (SpeechDoneUPP) speechDoneUPP);
	if( speechPhonemeUPP != nil )
		DisposeSpeechPhonemeUPP( (SpeechPhonemeUPP) speechPhonemeUPP);
	if( buffer )
		free( buffer );
	
	[super dealloc];
}


- (oneway void)release
{
	if( [self retainCount] == 1 )
		UKLog(@"UKSpeechChannel released.");
	[super release];
}



-(id)	reallocSpeechChannelWithVoice: (VoiceSpec*)spec
{
	if( speechChannel )
	{
		DisposeSpeechChannel( speechChannel );
		speechChannel = nil;
	}

	if( NewSpeechChannel( spec, &speechChannel ) != noErr )
		return nil;
	
	if( SetSpeechInfo( speechChannel, soRefCon, (Ptr)self ) != noErr ) return nil;
	if( SetSpeechInfo( speechChannel, soPhonemeCallBack, speechPhonemeUPP ) != noErr ) return nil;
	if( SetSpeechInfo( speechChannel, soSpeechDoneCallBack, speechDoneUPP ) != noErr ) return nil;
	
	if( spec == nil )
	{
		[currVoice release];
		currVoice = [[UKSpeechSynthesizer defaultVoice] retain];
	}
	
	return self;
}


-(BOOL)			usesFeedbackWindow
{
	return usesFeedbackWindow;
}


-(void)			setUsesFeedbackWindow: (BOOL)n
{
	usesFeedbackWindow = n;
}


-(void)			setVoice: (NSString*)voiceName
{
	VoiceSpec		spec;
	
	if( voiceName == nil )
		[self reallocSpeechChannelWithVoice: nil];
	else
	{
		[currVoice release];
		currVoice = [voiceName retain];
		spec = [UKSpeechSynthesizer voiceSpecFromVoice: voiceName];
		[self reallocSpeechChannelWithVoice: &spec];
	}
}


-(NSString*)	voice
{
	return currVoice;
}


-(void)			startSpeakingString: (NSString*)str
{
	if( isSpeaking )
	{
		UKLog(@"Stopping previous speech.");
		[self stopSpeaking];	// Can't do this unconditionally! It'll send an additional "speech done" callback!
	}
	
	if( buffer )
	{
		free( buffer );
		buffer = nil;
	}
	buffer = malloc( [str cStringLength] +1 );
	[str getCString:buffer];
	
	[self retain];
	
	UKLog(@"About to speak: \"%@\"",str);
	SpeakText( speechChannel, buffer, strlen(buffer) );
	isSpeaking = YES;
	
	if( [str length] == 0 )
	{
		UKLog(@"Triggering Speech Done Notification because [str length] == 0");
		[self notifySpeechDoneObject: nil];
	}
}


-(BOOL)			isSpeaking
{
	return isSpeaking;
}


-(void)			stopSpeaking
{
	StopSpeech( speechChannel );
}


-(void)			stopSpeakingAt: (long)whereToStop
{
	StopSpeechAt( speechChannel, whereToStop );
}


-(void)			pauseSpeakingAt: (long)whereToStop
{
	PauseSpeechAt( speechChannel, whereToStop );
}


-(void)			continueSpeaking
{
	ContinueSpeech( speechChannel );
}


-(void)			setSpeechPitch: (double)pitch
{
	SetSpeechPitch( speechChannel, X2Fix( pitch ) );
}


-(double)		speechPitch
{
	Fixed		nb;
	GetSpeechPitch( speechChannel, &nb );
	
	return Fix2X( nb );
}

- (id)objectForProperty:(NSString *)property error:(NSError **)outError
{
	if( [property isEqualToString: NSSpeechPitchBaseProperty] )
	{
		if( outError )
			*outError = nil;
		return [NSNumber numberWithDouble: [self speechPitch]];
	}
	else
	{
		if( outError )
			*outError = [NSError errorWithDomain: @"UKSpeechSynthesizerErrorDomain" code: 1 userInfo: [NSDictionary dictionary]];
		return nil;
	}
}


- (BOOL)setObject:(id)object forProperty:(NSString *)property error:(NSError **)outError
{
	if( [property isEqualToString: NSSpeechPitchBaseProperty] )
	{
		if( outError )
			*outError = nil;
		[self setSpeechPitch: [object doubleValue]];
		return YES;
	}
	else
	{
		if( outError )
			*outError = [NSError errorWithDomain: @"UKSpeechSynthesizerErrorDomain" code: 1 userInfo: [NSDictionary dictionary]];
		return NO;
	}
}


-(void) setRate: (float)n
{
	Fixed		vVolume;
	
	vVolume = X2Fix(n);
	SetSpeechInfo( speechChannel, soRate, &vVolume );
}


-(float)	rate
{
	Fixed				vVolume;
	float				n = 0;
	
	if( GetSpeechInfo( speechChannel, soRate, &vVolume ) == noErr )
		n = Fix2X( vVolume );
	
	return n;
}


-(void)			notifySpeechDoneObject: (id)dummy
{
	if( buffer )
	{
		free( buffer );
		buffer = nil;
	}
	UKLog(@"Speech Done Notification.");
	
	if( isSpeaking )
	{
		[self release];
		isSpeaking = NO;
	}
	[delegate speechSynthesizer: (NSSpeechSynthesizer*) self didFinishSpeaking: YES];
}


-(void)			notifySpeechPhonemeObject: (id)dummy
{
	[delegate speechSynthesizer: (NSSpeechSynthesizer*) self willSpeakPhoneme: phonemeOpcode];
}


-(void)			setVolume: (float)n
{
	Fixed		vVolume;
	
	vVolume = X2Fix(n);
	SetSpeechInfo( speechChannel, soVolume, &vVolume );
}


-(float)		volume
{
	Fixed		vVolume;
	float		n = -1;
	
	if( GetSpeechInfo( speechChannel, soVolume, &vVolume ) == noErr )
	{
		n = Fix2X( vVolume );
	}
	
	return n;
}


-(void)			setDelegate: (id)delly
{
	delegate = delly;
}


-(id)			delegate
{
	return delegate;
}

-(void)			setPhonemeOpcode: (short)n
{
	phonemeOpcode = n;
}


-(SpeechChannel)	channel
{
	return speechChannel;
}

-(NSDictionary*)	settingsDictionary
{
	NSMutableDictionary*		dict = [NSMutableDictionary dictionary];
	
	[dict setObject: [self voice] forKey: @"voice"];
	[dict setObject: [NSNumber numberWithInt: [self usesFeedbackWindow]] forKey: @"usesFeedbackWindow"];
	[dict setObject: [NSNumber numberWithFloat: [self volume]] forKey: @"speechVolume"];
	[dict setObject: [NSNumber numberWithDouble: [self speechPitch]] forKey: @"speechPitch"];
	[dict setObject: [NSNumber numberWithFloat: [self rate]] forKey: @"speechRate"];
	
	UKLog(@"speechSettingsDict(OUT) = %@", dict);
	
	return dict;
}


-(void)				setSettingsDictionary: (NSDictionary*)dict
{
	UKLog(@"speechSettingsDict(IN) = %@",dict);
	
	[self setVoice: [dict objectForKey: @"voice"]];
	[self setUsesFeedbackWindow: [[dict objectForKey: @"usesFeedbackWindow"] boolValue]];
	[self setVolume: [[dict objectForKey: @"speechVolume"] floatValue]];
	[self setSpeechPitch: [[dict objectForKey: @"speechPitch"] doubleValue]];
	[self setRate: [[dict objectForKey: @"speechRate"] floatValue]];
}


// Remove any speech commands from the specified string. You can use this for displaying the string being spoken:
+(NSString*)	prettifyString: (NSString*)inString
{
	NSMutableString*	str = [inString mutableCopy];
	NSRange				commandRange = { 0, 0 },
						cmdEndRange;
	
	if( !str )
		return str;
	
	while( commandRange.location != NSNotFound || commandRange.length != 0 )
	{
		commandRange = [str rangeOfString: @"[["];
		
		if( commandRange.location == NSNotFound && commandRange.length == 0 )
			break;
		
		cmdEndRange = [str rangeOfString: @"]]"];
		if( cmdEndRange.location == NSNotFound && cmdEndRange.length == 0 )
			break;

		commandRange.length += ((cmdEndRange.location +cmdEndRange.length) -(commandRange.location +commandRange.length));
		[str deleteCharactersInRange: commandRange];
	}
	
	return str;
}

@end


@implementation NSObject (UKSpeechSynthesizerDelegate)

- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender didFinishSpeaking:(BOOL)finishedSpeaking
{
	
}


- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender willSpeakPhoneme:(short)phonemeOpcode
{
	
}


@end




/* --------------------------------------------------------------------------------
	MyPhonemeCallback:
		Phoneme callback procedure for lip syncronization.
	
	REVISIONS:
		2000-11-02	UK	Created.
   ----------------------------------------------------------------------------- */

pascal void		MyPhonemeCallback( SpeechChannel chan, long refCon, short phonemeOpcode )
{
	CREATE_AUTORELEASE_POOL(pool);
	if( [(UKSpeechSynthesizer*)refCon isSpeaking] )
	{
		UKLog(@"Phoneme %d",phonemeOpcode);
		[((UKSpeechSynthesizer*)refCon) setPhonemeOpcode:phonemeOpcode];
		[((UKSpeechSynthesizer*)refCon) performSelectorOnMainThread:@selector(notifySpeechPhonemeObject:)
									withObject:nil waitUntilDone: NO];
	}
	else
		UKLog(@"Ignoring Phoneme %d which arrived after speech done callback.",phonemeOpcode);
	DESTROY(pool);
}


/* --------------------------------------------------------------------------------
	MySpeechDoneCallback:
		Speech output has ended. Notify the speech channel so it can broadcast a
        message that may be used to hide any speech feedback elements or to reset
        lip-synched mouths to a default position.
	
	REVISIONS:
		2001-08-18	UK	Created.
   ----------------------------------------------------------------------------- */

pascal void		MySpeechDoneCallback( SpeechChannel chan, long refCon )
{
	CREATE_AUTORELEASE_POOL(pool);
	UKLog(@"Sending speech done on main thread.");
	//((UKSpeechSynthesizer*)refCon)->isSpeaking = NO;
	[((UKSpeechSynthesizer*)refCon) performSelectorOnMainThread:@selector(notifySpeechDoneObject:)
								withObject:nil waitUntilDone: NO];
	DESTROY(pool);
}







