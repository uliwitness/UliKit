//
//  UKKeyboardTableView.m
//  Noisee
//
//  Created by Uli Kusterer on 24.05.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import "UKKeyboardTableView.h"


@implementation UKKeyboardTableView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)keyDown:(NSEvent *)theEvent
{
    [[self delegate] keyDown: theEvent];
}

- (void)keyUp:(NSEvent *)theEvent
{
    [[self delegate] keyUp: theEvent];
}

@end
