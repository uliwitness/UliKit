//
//  UKDocumentationController.m
//  Shovel
//
//  Created by Uli Kusterer on 04.10.04.
//  Copyright 2004 Uli Kusterer.
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
