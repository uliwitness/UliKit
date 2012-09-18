//
//  UKDockProgressIndicator.m
//  Doublette
//
//  Created by Uli Kusterer on 30.04.05.
//  Copyright 2005 Uli Kusterer.
//
// Updated by Dan Wood to actually hide the thing in the dock if it's supposed to be hidden.
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

#import "UKDockProgressIndicator.h"


@implementation UKDockProgressIndicator

- (id) init
{
	self = [super init];
	if ( self != nil )
	{
		savedDockIcon = [[NSApp applicationIconImage] copy];
		[savedDockIcon setScalesWhenResized:YES];
	}
	return self;
}

- (void)dealloc;
{
    [self unbind:NSValueBinding];
    
    [super dealloc];
}

- (oneway void) release
{
	[NSApp setApplicationIconImage: savedDockIcon];
	[savedDockIcon release]; savedDockIcon = nil;
	[self setHidden:YES];
	[super release];
}

-(void)     setMinValue: (double)mn
{
    min = mn;
    [progress setMinValue: mn];

    [self updateDockTile];
}

-(double)   minValue
{
    return min;
}


-(void)     setMaxValue: (double)mn
{
    max = mn;
    [progress setMaxValue: mn];

    [self updateDockTile];
}

-(double)   maxValue
{
    return max;
}


-(void)     setDoubleValue: (double)mn
{
    current = mn;
    [progress setDoubleValue: mn];
    [self updateDockTile];
}

-(double)   doubleValue
{
    return current;
}


-(void)     setNeedsDisplay: (BOOL)mn
{
    [progress setNeedsDisplay: mn];
}


-(void)     display
{
    [progress display];
}


-(void)     setHidden: (BOOL)flag
{
    [progress setHidden: flag];
    if( flag && !hidden) // Progress indicator is being hidden? Reset dock tile to regular icon again:
        [NSApp setApplicationIconImage: savedDockIcon];
	hidden = flag;
}

-(BOOL)     isHidden
{
	return hidden;
}


-(void) updateDockTile
{
	if (hidden) return;

    NSImage*    dockIcon = [[[NSImage alloc] initWithSize: NSMakeSize(256,256)] autorelease];
    
    
    [dockIcon lockFocus];
	{{
#define RADIUS 10		// 10 pixels leaves a 4-pixel gap betweeen tablet outline and filled progress
        NSRect      box = { {8, 8}, {240, 32} };		// 32 pixels tall. 8 pixels for border & gap, so 24 pixels inner height.

        static NSImage *sApplicationIconImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sApplicationIconImage = [[NSImage imageNamed:NSImageNameApplicationIcon] copy];
            // Copy so that we can adjust size without affecting other clients of this image.
            [sApplicationIconImage setSize:NSMakeSize(256,256)];
        });
        // App icon:
        [sApplicationIconImage drawInRect:NSMakeRect(0,0,256,256) fromRect:NSMakeRect(0,0,256,256) operation:NSCompositeSourceOver fraction:1.0];
        
        // Track & Outline:

		NSBezierPath *tablet = [NSBezierPath bezierPathWithRoundedRect:box xRadius:16 yRadius:16];
		[[NSColor blackColor] set];
		[tablet fill];
		[[NSColor whiteColor] set];
		[tablet stroke];

		// gap between border and line
        box = NSInsetRect( box, (box.size.height - (2*RADIUS))/2, (box.size.height - (2*RADIUS))/2 );

        // Fill in semicircle on left side for the zero amount
		NSBezierPath *leftArc = [[[NSBezierPath alloc] init] autorelease];		
		[leftArc appendBezierPathWithArcWithCenter:NSMakePoint(box.origin.x+RADIUS, box.origin.y+RADIUS)
											radius:RADIUS
										startAngle:90
										  endAngle:270];
		[leftArc fill];
		box = NSInsetRect(box,RADIUS, 0);	// avoid the semicircles on both ends

		CGFloat oldWidth = box.size.width;
        box.size.width = (box.size.width / (max -min)) * (current -min);

		NSRectFill( box );

		if (oldWidth - box.size.width < 1.0)	// add cap if we are essentially at the end
		{
			NSBezierPath *rightArc = [[[NSBezierPath alloc] init] autorelease];			
			[rightArc appendBezierPathWithArcWithCenter:NSMakePoint(box.origin.x+box.size.width, box.origin.y+RADIUS)
												radius:RADIUS
											startAngle:270
											  endAngle:90];
			[rightArc fill];
		}
	}}
    [dockIcon unlockFocus];

    [NSApp setApplicationIconImage: dockIcon];
}

#pragma mark Bindings

+ (void)initialize; { [self exposeBinding:NSValueBinding]; }

- (id)valueForUndefinedKey:(NSString *)key;
{
    if ([key isEqualToString:NSValueBinding])
    {
        return [self valueForKey:@"doubleValue"];
    }
    else
    {
        return [super valueForUndefinedKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key;
{
    if ([key isEqualToString:NSValueBinding])
    {
        return [self setValue:value forKey:@"doubleValue"];
    }
    else
    {
        return [super setValue:value forUndefinedKey:key];
    }
}

@end
