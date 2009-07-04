//
//  NSView+SizeWindowForViewSize.h
//  MovieTheatre
//
//  Created by Uli Kusterer on 25.06.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSView (UKSizeWindowForViewSize)

// Resize our containing window so this view gets the desired size. Only works if this view is set to maintain distance with containing window on all four sides.
-(void)     sizeWindowForViewSize: (NSSize)sz;

-(NSSize)   windowSizeForViewSize: (NSSize)sz;

@end
