//
//  NSWindow+ULIZoomEffect.h
//  Stacksmith
//
//  Created by Uli Kusterer on 05.03.11.
//  Copyright 2011 Uli Kusterer. All rights reserved.
//

#import <AppKit/AppKit.h>


@interface NSWindow (ULIZoomEffect)

-(void)	makeKeyAndOrderFrontWithZoomEffectFromRect: (NSRect)globalStartPoint;
-(void)	orderFrontWithZoomEffectFromRect: (NSRect)globalStartPoint;
-(void)	orderOutWithZoomEffectToRect: (NSRect)globalEndPoint;

@end
