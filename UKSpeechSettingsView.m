//
//  UKSpeechSettingsView.m
//  CocoaMoose
//
//  Created by Uli Kusterer on Mon Apr 05 2004.
//  Copyright (c) 2004 M. Uli Kusterer. Uli Kusterer
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

#import "UKSpeechSettingsView.h"


NSString*	UKSpeechPitchBaseProperty = NULL;


// These are here so we don't have to pull in UKSpeechSynthesizer or 10.5:
@interface NSObject (UKSpeechSynthExtensions)

-(void)				setVolume: (float)n;
-(float)			volume;

-(id)				objectForProperty:(NSString *)property error:(NSError **)outError;
-(BOOL)				setObject:(id)object forProperty:(NSString *)property error:(NSError **)outError;

-(void)				setRate: (float)n;
-(float)			rate;

@end


@implementation UKSpeechSettingsView

+(void)	load
{
	if( UKSpeechPitchBaseProperty == NULL )
	{
		void*			dataPtr = NULL;
		CFBundleRef		cocoaBundle = CFBundleGetBundleWithIdentifier( CFSTR("com.apple.Cocoa") );
		if( !cocoaBundle )
			cocoaBundle = CFBundleGetBundleWithIdentifier( CFSTR("com.apple.cocoa") );
		if( cocoaBundle )
			dataPtr = CFBundleGetDataPointerForName( cocoaBundle, CFSTR("NSSpeechPitchBaseProperty") );
		if( !dataPtr )
		{
			CFBundleRef		fallbackBundle = CFBundleGetBundleWithIdentifier( CFSTR("de.zathras.moose.ukspeechsynthesizer") );
			if( fallbackBundle )
				dataPtr = CFBundleGetDataPointerForName( fallbackBundle, CFSTR("NSSpeechPitchBaseProperty") );
		}
		if( dataPtr )
			UKSpeechPitchBaseProperty = *(NSString**)dataPtr;
		else
			UKSpeechPitchBaseProperty = @"NSSpeechPitchBaseProperty";
	}
}

-(void) awakeFromNib
{
	static BOOL		isAwaking = NO;
	NSPoint			pos = { 0, 0 };
	
	if( !isAwaking )
	{
		isAwaking = YES;
		[NSBundle loadNibNamed: @"UKSpeechSettingsView" owner: self];
		pos.y += [self frame].size.height -[mainView frame].size.height;
		[mainView setFrameOrigin: pos];
		[self addSubview: mainView];
		[mainView setAutoresizingMask: NSViewWidthSizable | NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin];
		
		[voicePopup removeAllItems];
		NSEnumerator*		enny = [[NSSpeechSynthesizer availableVoices] objectEnumerator];
		NSString*			voiceID = nil;
		while( (voiceID = [enny nextObject]) )
		{
			[voicePopup addItemWithTitle: [[NSSpeechSynthesizer attributesForVoice: voiceID] objectForKey: NSVoiceName]];
		}
		if( speechSynthesizer )
			[self reflectVoiceInUI: nil];
		isAwaking = NO;
	}
}

-(void) dealloc
{
	[mainView release];
	[speechSynthesizer release];
	
	[super dealloc];
}


-(IBAction) voiceChanged: (id)sender
{
	NSString*		currVoice = [[NSSpeechSynthesizer availableVoices] objectAtIndex: [voicePopup indexOfSelectedItem]];
	[speechSynthesizer setVoice: currVoice];
	[self reflectVoiceInUI: nil];
}

-(IBAction) pitchChanged: (id)sender
{
	[speechSynthesizer setObject: [NSNumber numberWithFloat: [pitchStepper floatValue]] forProperty: UKSpeechPitchBaseProperty error: nil];
	[pitchField setDoubleValue: [pitchStepper floatValue]];
}


-(IBAction) volumeChanged: (id)sender
{
	[speechSynthesizer setVolume: [volumeSlider floatValue]];
}


-(IBAction) rateChanged: (id)sender
{
	[speechSynthesizer setRate: [rateStepper floatValue]];
	[rateField setFloatValue: [rateStepper floatValue]];
}


-(void) reflectVoiceInUI: (id)sender
{
	NSDictionary*   attrs = [NSSpeechSynthesizer attributesForVoice: [speechSynthesizer voice]];
	if( attrs == nil )
		attrs = [NSSpeechSynthesizer attributesForVoice: @"com.apple.speech.synthesis.voice.Fred"];
	NSString*		demoTextStr = [attrs objectForKey: NSVoiceDemoText];
	if( !demoTextStr )
		demoTextStr = @"Some nit didn't provide a demo text for this voice.";
	[demoText setString: demoTextStr];
	NSString*		currName = [attrs objectForKey: NSVoiceName];
	if( currName )
		[voicePopup selectItemWithTitle: currName];
	NSString*		gender = [attrs objectForKey: NSVoiceGender];
	if( [gender isEqualToString: NSVoiceGenderNeuter] )
		gender = @"Neuter";
	else if( [gender isEqualToString: NSVoiceGenderMale] )
		gender = @"Male";
	else if( [gender isEqualToString: NSVoiceGenderFemale] )
		gender = @"Female";
	[genderField setStringValue: NSLocalizedString( gender, @"" ) ];
	[ageField setObjectValue: [attrs objectForKey: NSVoiceAge]];
	
	if( [speechSynthesizer respondsToSelector: @selector(volume)] )
	{
		[pitchField setFloatValue: [[speechSynthesizer objectForProperty: UKSpeechPitchBaseProperty error: nil] floatValue]];
		[pitchStepper setFloatValue: [pitchField floatValue]];
		[volumeSlider setFloatValue: [speechSynthesizer volume]];
		[rateField setFloatValue: [speechSynthesizer rate]];
		[rateStepper setFloatValue: [rateField floatValue]];
	}
	else
	{
		[pitchField removeFromSuperview];
		pitchField = nil;
		[rateField removeFromSuperview];
		rateField = nil;
		[pitchStepper removeFromSuperview];
		pitchStepper = nil;
		[volumeSlider setEnabled: NO];
		[rateStepper removeFromSuperview];
		rateStepper = nil;
	}
}


-(IBAction) testSpeak: (id)sender
{
	[speechSynthesizer startSpeakingString: [demoText string]];
}


-(NSSpeechSynthesizer *)	speechSynthesizer
{
    return speechSynthesizer;
}

-(void)	setSpeechSynthesizer: (NSSpeechSynthesizer *)newSpeechSynthesizer
{
    if( speechSynthesizer != newSpeechSynthesizer )
	{
		[speechSynthesizer release];
		speechSynthesizer = [newSpeechSynthesizer retain];
		
		[self reflectVoiceInUI: nil];
	}
}

@end


@implementation NSSpeechSynthesizer (UKSpeechSettings)

-(NSDictionary*)	settingsDictionary
{
	NSMutableDictionary*		dict = [NSMutableDictionary dictionary];
	
	[dict setObject: [self voice] forKey: @"voice"];
	[dict setObject: [NSNumber numberWithInt: [self usesFeedbackWindow]] forKey: @"usesFeedbackWindow"];
	[dict setObject: [NSNumber numberWithFloat: [self volume]] forKey: @"volume"];
	[dict setObject: [NSNumber numberWithInt: lroundf([self volume] * 10.0f)] forKey: @"speechVolume"];
	[dict setObject: [NSNumber numberWithFloat: [[self objectForProperty: UKSpeechPitchBaseProperty error: nil] floatValue]] forKey: @"speechPitch"];
	[dict setObject: [NSNumber numberWithFloat: [self rate]] forKey: @"speechRate"];
	
	return dict;
}


-(void)				setSettingsDictionary: (NSDictionary*)dict
{
	[self setVoice: [dict objectForKey: @"voice"]];
	[self setUsesFeedbackWindow: [[dict objectForKey: @"usesFeedbackWindow"] boolValue]];
	id			volObj = [dict objectForKey: @"volume"];
	float		vol = 1.0f;
	if( volObj )
		vol = [volObj floatValue];
	else
	{
		volObj = [dict objectForKey: @"speechVolume"];
		if( volObj )
			vol = 0.1f * (float)[volObj intValue];	// This changed from speechVolume to volume and from a 0 ... 10 scale to a 0 ... 1.0 scale. So we may have to substitute this if missing.
	}
	[self setVolume: vol];
	[self setObject: [dict objectForKey: @"speechPitch"] forProperty: UKSpeechPitchBaseProperty error: nil];
	[self setRate: [[dict objectForKey: @"speechRate"] floatValue]];
}

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
