//
//  UKTabViewSwitchingSourceViewController.m
//  TalkingMoose
//
//  Created by Uli Kusterer on 22.01.10.
//  Copyright 2010 The Void Software. All rights reserved.
//

#import "UKTabViewSwitchingSourceViewController.h"


@implementation UKTabViewSwitchingSourceViewController

-(void)	awakeFromNib
{
	NSInteger	theIndex = [tabSwitcher indexOfTabViewItem: [tabSwitcher selectedTabViewItem]];
	[sourceView reloadData];
	[sourceView selectRow: theIndex byExtendingSelection: NO];
}


-(void)	tableViewSelectionDidChange: (NSNotification *)notification
{
	[tabSwitcher selectTabViewItemAtIndex: [sourceView selectedRow]];
}


-(NSInteger)	numberOfRowsInTableView: (NSTableView *)tableView
{
	return [tabSwitcher numberOfTabViewItems];
}


-(id) tableView: (NSTableView *)tableView objectValueForTableColumn: (NSTableColumn *)tableColumn
			row: (NSInteger)row
{
	return [[tabSwitcher tabViewItemAtIndex: row] label];
}

@end
