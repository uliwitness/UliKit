//
//  NSScreen+ScreenAtPoint.h
//  TalkingMoose (XC2)
//
//  Created by Uli Kusterer on 26.05.06.
//  Copyright 2006 Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSScreen (UKScreenAtPoint)

+(NSScreen*)	screenAtPoint: (NSPoint) pos;

@end
