//
//  ULIInputPanelController.m
//  Stacksmith
//
//  Created by Uli Kusterer on 04.05.11.
//  Copyright 2011 Uli Kusterer. All rights reserved.
//

#import "ULIInputPanelController.h"
#import "NSStringDrawing+SizeWithRect.h"
#import "UKHelperMacros.h"


#if !__has_feature(objc_arc)
#error This file requires ARC. Please add the -fobjc-arc compiler option for this file.
#endif


@interface ULIInputPanelController ()

@property (strong) NSTextField	*	answerField;

@end


@implementation ULIInputPanelController

@synthesize window;
@synthesize answerField;
@synthesize passwordMode;
@synthesize prompt;
@synthesize answerString;

+(id)	inputPanelWithPrompt: (NSString*)inPrompt answer: (NSString*)inAnswer
{
	return [[[self class] alloc] initWithPrompt: inPrompt answer: inAnswer];
}

-(id)	initWithPrompt: (NSString*)inPrompt answer: (NSString*)inAnswer
{
    self = [super init];
    if (self)
	{
		self.prompt = inPrompt;
		self.answerString = inAnswer;
    }
    
    return self;
}


- (void)dealloc
{
	[window close];
}


-(void)	createWindowContents
{
	window = [[NSPanel alloc] initWithContentRect: NSMakeRect(0,0, 422,4000) styleMask: NSWindowStyleMaskTitled backing: NSBackingStoreBuffered defer: NO];
	[window setReleasedWhenClosed: NO];
	
	NSView		*	contentView = [window contentView];
	NSRect			availableBox = NSInsetRect( [contentView bounds], 12, 12 );
	
	// OK button:
	NSButton	*	okButton = [[NSButton alloc] initWithFrame: availableBox];
	[okButton setBezelStyle: NSBezelStyleRounded];
	[okButton setTitle: @"OK"];
	[okButton setKeyEquivalent: @"\r"];
	[okButton setFont: [NSFont systemFontOfSize: [NSFont systemFontSizeForControlSize: NSControlSizeRegular]]];
	[okButton setTag: NSAlertFirstButtonReturn];
	[okButton setTarget: self];
	[okButton setAction: @selector(doOKButton:)];
	[contentView addSubview: okButton];
	[okButton sizeToFit];
	NSRect		okButtonBox = [okButton frame];
	okButtonBox.size.width += 22;

	// Cancel button to its left:
	NSButton	*	cancelButton = [[NSButton alloc] initWithFrame: availableBox];
	[cancelButton setBezelStyle: NSBezelStyleRounded];
	[cancelButton setTitle: @"Cancel"];
	[cancelButton setKeyEquivalent: @"\033"];
	[cancelButton setFont: [NSFont systemFontOfSize: [NSFont systemFontSizeForControlSize: NSControlSizeRegular]]];
	[cancelButton setTag: NSAlertSecondButtonReturn];
	[cancelButton setTarget: self];
	[cancelButton setAction: @selector(doCancelButton:)];
	[contentView addSubview: cancelButton];
	[cancelButton sizeToFit];
	NSRect		cancelButtonBox = [cancelButton frame];
	cancelButtonBox.size.width += 22;
	
	// Now that we know both rects, make both buttons the same size:
	if( cancelButtonBox.size.width > okButtonBox.size.width )
		okButtonBox.size.width = cancelButtonBox.size.width;
	else if( cancelButtonBox.size.width < okButtonBox.size.width )
		cancelButtonBox.size.width = okButtonBox.size.width;
	okButtonBox.origin.x = NSMaxX(availableBox) -okButtonBox.size.width;
	cancelButtonBox.origin.x = NSMinX(okButtonBox) -2 -cancelButtonBox.size.width;
	
	[cancelButton setFrame: cancelButtonBox];
	[okButton setFrame: okButtonBox];

	availableBox.size.height -= okButtonBox.size.height +12;
	availableBox.origin.y += okButtonBox.size.height +12;
	
	// Edit field above the two:
	if( passwordMode )
		answerField = [[NSSecureTextField alloc] initWithFrame: availableBox];
	else
		answerField = [[NSTextField alloc] initWithFrame: availableBox];
	[answerField setStringValue: self.answerString];
	[[answerField cell] setWraps: YES];
	[[answerField cell] setLineBreakMode: NSLineBreakByWordWrapping];
	[contentView addSubview: answerField];
	NSRect	bestRect = availableBox;
	bestRect.size.height = [[answerField attributedStringValue] sizeWithRect: NSInsetRect(availableBox,4,4)].height + 8;
	[answerField setFrame: bestRect];
	
	availableBox.size.height -= bestRect.size.height +12;
	availableBox.origin.y += bestRect.size.height +12;
	
	// Prompt field above that:
	NSTextField	*	messageField = [[NSTextField alloc] initWithFrame: availableBox];
	[messageField setStringValue: self.prompt];
	[[messageField cell] setWraps: YES];
	[messageField setBezeled: NO];
	[messageField setEditable: NO];
	[messageField setSelectable: YES];
	[messageField setDrawsBackground: NO];
	[[messageField cell] setLineBreakMode: NSLineBreakByWordWrapping];
	[contentView addSubview: messageField];
	bestRect = availableBox;
	bestRect.size.height = [[messageField attributedStringValue] sizeWithRect: availableBox].height;
	[messageField setFrame: bestRect];
	
	availableBox.size.height -= bestRect.size.height +12;
	availableBox.origin.y += bestRect.size.height +12;
	
	// Resize window to fit:
	NSRect		wdFrame = [window contentRectForFrameRect: [window frame]];
	wdFrame.size.height = NSMinY(availableBox);
	[window setFrame: [window frameRectForContentRect: wdFrame] display: NO];
}


-(NSModalResponse)	runModal
{
	[self.window center];
	[self.window makeKeyAndOrderFront: self];

	NSInteger	buttonHit = [NSApp runModalForWindow: [self window]];
	
	[self.window orderOut: self];

	self.answerString = answerField.stringValue;
	
	return buttonHit;
}


-(NSWindow*)	window
{
	if( !window )
	{
		[self createWindowContents];
	}
	return window;
}


-(void)	setWindow: (NSWindow*)inWindow
{
	window = inWindow;
}


-(IBAction)		doOKButton: (id)sender
{
	[NSApp stopModalWithCode: NSAlertFirstButtonReturn];
}


-(IBAction)		doCancelButton: (id)sender
{
	[NSApp stopModalWithCode: NSAlertSecondButtonReturn];
}

@end
