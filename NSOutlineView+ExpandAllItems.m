//
//  NSOutlineView+ExpandAllItems.m
//  AngelTemplate
//
//  Created by Uli Kusterer on 21.10.06.
//  Copyright 2006 M. Uli Kusterer. All rights reserved.
//

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import "NSOutlineView+ExpandAllItems.h"


@implementation NSOutlineView (UKExpandAllItems)

// -----------------------------------------------------------------------------
//	expandAllItems:
// -----------------------------------------------------------------------------

-(void)	expandAllItems
{
	NSObject*	dataSource = [self dataSource];
	int			topItemCount = [dataSource outlineView: self numberOfChildrenOfItem: nil];
	int			x = 0;
	
	for( x = 0; x < topItemCount; x++ )
	{
		id	theItem = [dataSource outlineView: self child: x ofItem: nil];
		if( [self isExpandable: theItem] )
			[self expandItem: theItem expandChildren: YES];
	}
}

@end
