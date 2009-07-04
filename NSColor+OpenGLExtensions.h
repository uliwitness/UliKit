//
//  NSColor+OpenGLExtensions.h
//  TheBigRedButton
//
//  Created by Uli Kusterer on 02.09.07.
//  Copyright 2007 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSColor (UKOpenGLExtensions)

-(void)	setForGLContext;

-(void)	setForClearingGLContext;

@end
