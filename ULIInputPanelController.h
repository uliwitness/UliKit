//
//  ULIInputPanelController.h
//  Stacksmith
//
//  Created by Uli Kusterer on 04.05.11.
//  Copyright 2011 Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ULIInputPanelController : NSObject

@property (strong) NSWindow		*	window;
@property (assign) BOOL				passwordMode;
@property (copy) NSString*			answerString;
@property (copy) NSString*			prompt;

+(id)	inputPanelWithPrompt: (NSString*)inPrompt answer: (NSString*)inAnswer;

-(id)	initWithPrompt: (NSString*)inPrompt answer: (NSString*)inAnswer;

-(NSModalResponse)	runModal;	// NSAlertFirstButtonReturn for OK, NSAlertSecondButtonReturn for cancel.

-(IBAction)		doOKButton: (id)sender;
-(IBAction)		doCancelButton: (id)sender;

@end
