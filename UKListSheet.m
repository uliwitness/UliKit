//
//  UKListSheet.m
//  Shovel
//
//  Created by Uli Kusterer on Tue Mar 23 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import "UKListSheet.h"


@implementation UKListSheet

-(int)		runList: (NSArray*)l modalForWindow: (NSWindow*)owner
{
	int		dialogResult = 0;
	
	list = [l retain];
	[listView reloadData];
	
	[NSApp beginSheet: [listView window] modalForWindow: owner
			modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
			contextInfo: &dialogResult];
	
	while( dialogResult == 0 )
	{
		NSEvent* evt = [NSApp nextEventMatchingMask: NSAnyEventMask
			untilDate:[NSDate dateWithTimeIntervalSinceNow: 1]  // 1 second so we get to check whether the flag was set.
			inMode: NSModalPanelRunLoopMode dequeue: YES];
		if( evt )
			[NSApp sendEvent: evt];
	}
	
	[[listView window] orderOut: self];
	
	[list release];
	list = nil;
	
	return dialogResult;
}

-(IBAction) sheetButtonClicked: (id)sender
{
	[NSApp endSheet: [listView window] returnCode: NSAlertFirstButtonReturn +[sender tag] -1];
}

-(void) sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(int*)dialogResult
{
	*dialogResult = returnCode;
}


-(int)  numberOfRowsInTableView: (NSTableView*)tableView
{
	return [list count];
}


-(id)   tableView: (NSTableView*)tableView objectValueForTableColumn: (NSTableColumn*)tableColumn row: (int)row
{
	NSDictionary*			dict = [list objectAtIndex: row];
	
	return [dict valueForKey: [tableColumn identifier]];
}


-(void) tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	NSMutableDictionary*	dict = nil;
	id						dCell = [tableColumn dataCellForRow: row];
	
	// If single selection and this is button column, uncheck all others:
	if( singleSelection && [dCell isKindOfClass: [NSButtonCell class]] ) // Sadly, can't detect NSButtonType :-(
	{
		NSEnumerator*   enny = [list objectEnumerator];
		
		while( (dict = [enny nextObject]) )
			[dict setObject: [NSNumber numberWithInt: 0] forKey: [tableColumn identifier]];
		
		[listView setNeedsDisplay: YES];
	}
	
	// Now find and select this one:
	dict = [list objectAtIndex: row];
	[dict setObject: object forKey: [tableColumn identifier]];
}


-(BOOL)		singleSelection
{
	return singleSelection;
}

-(void)		setSingleSelection: (BOOL)n
{
	singleSelection = n;
}


@end
