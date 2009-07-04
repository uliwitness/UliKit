//
//  UKDropTableView.m
//  CocoaMediator
//
//  Created by Uli Kusterer on Sun May 11 2003.
//  Copyright (c) 2003 M. Uli Kusterer. All rights reserved.
//

#import "UKDropTableView.h"


@implementation UKDropTableView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
        // Initialization code here.
    }
    return self;
}

-(NSDragOperation)	draggingSourceOperationMaskForLocal: (BOOL)isLocal
{
	return [[self delegate] draggingSourceOperationMaskForLocal: isLocal];
}


@end
