//
//  UKSpeechSettingsView.h
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

#import <Cocoa/Cocoa.h>


@interface UKSpeechSettingsView : NSView
{
	IBOutlet NSView*		mainView;
	IBOutlet NSTextView*	demoText;
	IBOutlet NSPopUpButton* voicePopup;
	IBOutlet NSTextField*   ageField;
	IBOutlet NSTextField*   genderField;
	IBOutlet NSSlider*		volumeSlider;
	IBOutlet NSTextField*   pitchField;
	IBOutlet NSTextField*   rateField;
	IBOutlet NSStepper*		pitchStepper;
	IBOutlet NSStepper*		rateStepper;
	NSSpeechSynthesizer*	speechSynthesizer;
	NSArray*				topLevelObjects;	// Top level objects loaded from our NIB.
}

-(IBAction) voiceChanged: (id)sender;
-(IBAction) testSpeak: (id)sender;
-(IBAction) pitchChanged: (id)sender;
-(IBAction) volumeChanged: (id)sender;
-(IBAction) rateChanged: (id)sender;

-(NSSpeechSynthesizer *)	speechSynthesizer;
-(void)	setSpeechSynthesizer: (NSSpeechSynthesizer *)newSpeechSynthesizer;

// private:
-(void) reflectVoiceInUI: (id)sender;

@end


@interface NSSpeechSynthesizer (UKSpeechSettings)

-(NSDictionary*)	settingsDictionary;
-(void)				setSettingsDictionary: (NSDictionary*)dict;

+(NSString*)		prettifyString: (NSString*)inString;

@end

