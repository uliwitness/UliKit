//
//  UKSpeechSynthesizer.h
//  UKSpeechSynthesizer
//
//  Created by Uli Kusterer on Mon Jun 30 2003.
//  Copyright (c) 2003-07 M. Uli Kusterer. Uli Kusterer
//
//	This software is provided 'as-is', without any express or implied
//	warranty. In no event will the authors be held liable for any damages
//	arising from the use of this software.
//
//	Permission is granted to anyone to use this software for any purpose,
//	including commercial applications, and to alter it and redistribute it
//	freely, subject to the following restrictions:
//
//	   1. The origin of this software must not be misrepresented; you must not
//	   claim that you wrote the original software. If you use this software
//	   in a product, an acknowledgment in the product documentation would be
//	   appreciated but is not required.
//
//	   2. Altered source versions must be plainly marked as such, and must not be
//	   misrepresented as being the original software.
//
//	   3. This notice may not be removed or altered from any source
//	   distribution.
//

/* -----------------------------------------------------------------------------
	Headers:
   -------------------------------------------------------------------------- */

#import <Foundation/Foundation.h>


/* -----------------------------------------------------------------------------
	Forwards:
   -------------------------------------------------------------------------- */

// This avoids our users from having to include all of Carbon.h every time:
#ifndef __SPEECHSYNTHESIS__
typedef struct SpeechChannelRecord SpeechChannelRecord;
typedef SpeechChannelRecord* SpeechChannel;
#endif


/* -----------------------------------------------------------------------------
	UKSpeechSynthesizer:
   -------------------------------------------------------------------------- */

@interface UKSpeechSynthesizer : NSObject
{
	SpeechChannel		speechChannel;		// The actual Carbon speech channel that is used for speech output.
	IBOutlet id			delegate;			// The delegate that gets notified of all those callbacks.
	BOOL				usesFeedbackWindow; // Dummy for NSSpeechSynthesizer compatibility.
	BOOL				isSpeaking;			// Keep track whether we're speaking.
	NSString*			currVoice;			// The currently assigned voice.

// private:
	short				phonemeOpcode;		// We can't pass parameters when calling back to the main thread, so we stash the phoneme here.
	void*				speechDoneUPP;		// cast to SpeechDoneUPP
	void*				speechPhonemeUPP;	// cast to SpeechPhonemeUPP
	char*				buffer;				// Keeps a copy of the text being spoken.
}

// Class methods:
+(id)			speechSynthesizer;									// UKSpeechSynthesizer-specific.
+(id)			speechSynthesizerWithVoice: (NSString*)voiceName;   // UKSpeechSynthesizer-specific.

+(NSArray*)		availableVoices;
+(NSDictionary*)attributesForVoice:(NSString*)voice;

+(BOOL)			isAnyApplicationSpeaking;

+(VoiceSpec)	voiceSpecFromVoice: (NSString*)voiceName;   // UKSpeechSynthesizer-specific.
+(NSString*)	voiceFromVoiceSpec: (VoiceSpec*)spec;		// UKSpeechSynthesizer-specific.
+(NSString*)	prettifyString: (NSString*)inString;		// UKSpeechSynthesizer-specific.

// Instance methods:
-(id)			init;
-(id)			initWithVoice: (NSString*)voiceName;

-(void)			setDelegate: (id)delly;
-(id)			delegate;

-(void)			setVoice: (NSString*)voiceName;				// Recreates the internal speech channel.
-(NSString*)	voice;

-(void)			startSpeakingString: (NSString*)str;		// This retains the channel until speech is done.
-(BOOL)			isSpeaking;
-(void)			stopSpeaking;

-(void)			setRate: (float)n;
-(float)		rate;

-(void)			setVolume: (float)n;
-(float)		volume;

// Only implements NSSpeechPitchBaseProperty for now:
-(id)			objectForProperty: (NSString *)property error: (NSError **)outError;
-(BOOL)			setObject: (id)object forProperty: (NSString *)property error: (NSError **)outError;

// Dummied out:
-(void)			setUsesFeedbackWindow: (BOOL)n;		// This remembers the state, but doesn't actually bring up a feedback window.
-(BOOL)			usesFeedbackWindow;
//-(void)		startSpeakingString: (NSString*)str toURL:(NSURL*)url;

// UKSpeechChannel-specific:
-(void)			stopSpeakingAt: (long)whereToStop;
-(void)			pauseSpeakingAt: (long)whereToStop;
-(void)			continueSpeaking;

-(void)			setSpeechPitch: (double)pitch;
-(double)		speechPitch;

-(NSDictionary*)	settingsDictionary;
-(void)				setSettingsDictionary: (NSDictionary*)dict;

-(SpeechChannel)	channel;

-(BOOL)				isSpeaking;

@end


// Delegate methods: (informal protocol)
@interface NSObject (UKSpeechSynthesizerDelegate)

- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender didFinishSpeaking:(BOOL)finishedSpeaking;
//- (void)speechSynthesizer:(UKSpeechSynthesizer *)sender willSpeakWord:(NSRange)characterRange ofString:(NSString *)string;
- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender willSpeakPhoneme:(short)phonemeOpcode;

@end

extern NSString* const NSSpeechPitchBaseProperty;	// 10.5-only property that we fake on 10.4 and before.
