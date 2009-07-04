//
//  UKSpeechSettingsView.h
//  CocoaMoose
//
//  Created by Uli Kusterer on Mon Apr 05 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
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

