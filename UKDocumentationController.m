//
//  UKDocumentationController.m
//  Shovel
//
//  Created by Uli Kusterer on 04.10.04.
//  Copyright 2004 M. Uli Kusterer. All rights reserved.
//

#import "UKDocumentationController.h"


@implementation UKDocumentationController

-(void)	showReadme: (id)sender
{
	[self showHelpBookAnchor: @"readme"];
}


-(void)	showReleaseNotes: (id)sender
{
	[self showHelpBookAnchor: @"release_notes"];
}


-(void)	showFAQ: (id)sender
{
	[self showHelpBookAnchor: @"faq"];
}


// Main bottleneck for all of our menu item actions:
-(void)	showHelpBookAnchor: (NSString*)str
{
	NSDictionary*	infod = nil;
	NSBundle*		mainb = [NSBundle mainBundle];
    
	if( [mainb respondsToSelector: @selector(localizedInfoDictionary)] )
		infod = [mainb localizedInfoDictionary];
	else
		infod = [mainb infoDictionary];
	
	NSString*		helpBookName = [infod objectForKey: @"CFBundleHelpBookName"];
	if( helpBookName == nil )
		helpBookName = [[mainb infoDictionary] objectForKey: @"CFBundleHelpBookName"];
	if( [[NSHelpManager sharedHelpManager] respondsToSelector: @selector(openHelpAnchor:inBook:)] )
		[[NSHelpManager sharedHelpManager] openHelpAnchor: str inBook: helpBookName];
	else
		[NSApp showHelp: self];
}



@end
