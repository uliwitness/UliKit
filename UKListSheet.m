//
//  UKListSheet.m
//  Shovel
//
//  Created by Uli Kusterer on Tue Mar 23 2004.
//  Copyright (c) 2004 Uli Kusterer.
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
