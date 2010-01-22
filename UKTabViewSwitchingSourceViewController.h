//
//  UKTabViewSwitchingSourceViewController.h
//  TalkingMoose
//
//  Created by Uli Kusterer on 22.01.10.
//  Copyright 2010 The Void Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface UKTabViewSwitchingSourceViewController : NSObject
{
	IBOutlet NSTableView		*sourceView;	// List view to show the tab names in. This object should be its data source and delegate.
	IBOutlet NSTabView			*tabSwitcher;	// Tab view to switch according to list view selection.
}

@end
