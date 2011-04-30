//
//  NSBezierPath+ULIRegularPolygon.h
//  Stacksmith
//
//  Created by Uli Kusterer on 30.04.11.
//  Copyright 2011 Uli Kusterer. All rights reserved.
//

#import <AppKit/AppKit.h>


@interface NSBezierPath (ULIRegularPolygon)

-(void)	appendRegularPolygonAroundPoint: (NSPoint)centre startPoint: (NSPoint)startCorner cornerCount: (NSInteger)numCorners;

@end
