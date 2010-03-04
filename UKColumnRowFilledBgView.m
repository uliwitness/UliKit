//
//  UKColumnRowFilledBgView.m
//  ValueConverter
//
//  Created by Uli Kusterer on 26.04.08.
//  Copyright 2008 Uli Kusterer.
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

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

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
