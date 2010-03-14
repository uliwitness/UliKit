//
//  NSAffineTransform+Shearing.h
//  Propaganda
//
//  Created by Uli Kusterer on 14.03.10.
//  Copyright 2010 The Void Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSAffineTransform (UKShearing)

-(void)	shearXBy: (CGFloat)xFraction yBy: (CGFloat)yFraction;

@end
