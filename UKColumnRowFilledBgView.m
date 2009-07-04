//
//  UKColumnRowFilledBgView.m
//  ValueConverter
//
//  Created by Uli Kusterer on 26.04.08.
//  Copyright 2008 The Void Software. All rights reserved.
//

#import "UKColumnRowFilledBgView.h"


@implementation UKColumnRowFilledBgView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
        // Initialization code here.
    }
    return self;
}

-(void)	drawRect: (NSRect)rect
{
	NSRect		currBox = [self bounds];
	int			rowColorIndexX = 0, rowColorIndexY = 0;
	NSArray*	rowCols = [NSColor controlAlternatingRowBackgroundColors];
	int			numRowCols = [rowCols count];
	NSColor*	darkeningColor = [NSColor colorWithCalibratedRed: 0.1 green: 0.2 blue: 0.7 alpha: 1.0];
	
	currBox.size.width = 0;
	
	for( int x = 0; x < COL_ROW_COUNT && colWidths[x] != 0; x++ )
	{
		rowColorIndexY = 0;
		currBox.origin.y = [self bounds].size.height;
		currBox.size.height = 0;
		
		NSColor*	currColX = [rowCols objectAtIndex: rowColorIndexX];
		if( rowColorIndexX < (numRowCols -1) )
			rowColorIndexX++;
		else
			rowColorIndexX = 0;
		currBox.origin.x += currBox.size.width;
		currBox.size.width = colWidths[x];
		
		for( int y = 0; y < COL_ROW_COUNT && rowHeights[y] != 0; y++ )
		{
			currBox.origin.y -= rowHeights[y];
			currBox.size.height = rowHeights[y];
			NSColor*	currCol = [rowCols objectAtIndex: rowColorIndexY];
			if( rowColorIndexY < (numRowCols -1) )
				rowColorIndexY++;
			else
				rowColorIndexY = 0;
			if( x % 2 != 0 )
				currCol = [darkeningColor blendedColorWithFraction: 0.9 ofColor: currCol];
			[currCol set];
			[NSBezierPath fillRect: currBox];
		}
	}
}

-(void)	setColumnWidth: (float)w atIndex: (int)n
{
	if( n >= COL_ROW_COUNT )
		return;
	
	colWidths[n] = w;
}


-(void)	setRowHeight: (float)h atIndex: (int)n
{
	if( n >= COL_ROW_COUNT )
		return;
	
	rowHeights[n] = h;
}

-(BOOL)	isFlipped
{
	return NO;
}

@end
