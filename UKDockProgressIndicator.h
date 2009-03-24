//
//  UKDockProgressIndicator.h
//  Doublette
//
//  Created by Uli Kusterer on 30.04.05.
//  Copyright 2005 Uli Kusterer.
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

#import <Cocoa/Cocoa.h>


/* A class that displays a determinate progress indicator (progress bar)
    on top of the app's icon in the dock. Use it just like an NSProgressIndicator.
    You can even have it call through to another progress indicator if desired. */

@interface UKDockProgressIndicator : NSObject
{
    double                          max;
    double                          min;
    double                          current;
    IBOutlet NSProgressIndicator*   progress;
	BOOL							hidden;
}

// NSProgressIndicator compatibility stuff:
//  These forward to "progress" if you've hooked that up in IB.
-(void)     setMinValue: (double)mn;
-(double)   minValue;

-(void)     setMaxValue: (double)mn;
-(double)   maxValue;

-(void)     setDoubleValue: (double)mn;
-(double)   doubleValue;

-(void)     setNeedsDisplay: (BOOL)mn;
-(void)     display;

-(void)     setHidden: (BOOL)flag;
-(BOOL)     isHidden;

// private:
-(void)     updateDockTile;

@end
