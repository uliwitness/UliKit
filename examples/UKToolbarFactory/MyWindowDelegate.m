//
//  MyWindowDelegate.m
//  UKToolbarFactory
//
//  Created by Uli Kusterer on Sun Jan 18 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import "MyWindowDelegate.h"


@implementation MyWindowDelegate

// I'm lazy, so I wired most of the items to this method. Of course, you can
//  have a different method for each item. Just specify its name as the "Action"
//  in the .plist file.

-(IBAction) doToolbarItem: (id)sender
{
	[status setStringValue: [@"Item Clicked: " stringByAppendingString: [sender label]]];
}

-(BOOL)	validateToolbarItem: (NSToolbarItem*)theItem
{
	return YES;
}

@end
