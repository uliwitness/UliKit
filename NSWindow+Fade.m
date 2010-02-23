//
//  NSWindow+Fade.m
//  TalkingMoose
//
//  Created by Uli Kusterer on 22.06.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import "NSWindow+Fade.h"
#import "UKHelperMacros.h"

static NSMutableDictionary*     pendingFades = nil;


@implementation NSWindow (UKFade)

-(void)     fadeInWithDuration: (NSTimeInterval)duration
{
    if( !pendingFades )
        pendingFades = [[NSMutableDictionary alloc] init];
    
    NSString*       key = [NSString stringWithFormat: @"%lx", self];
    NSDictionary*   fade = [pendingFades objectForKey: key];
    
    if( fade )      // Currently fading that window? Abort that fade:
        [[fade objectForKey: @"timer"] invalidate];  // No need to remove from pendingFades, we'll replace it in a moment.
    
    [self setAlphaValue: 0];
    [self orderFront: nil];
    
    NSTimeInterval  interval = duration / 0.1;
    float           stepSize = 1 / interval;
    NSTimer*        timer = [NSTimer scheduledTimerWithTimeInterval: 0.1				// scheduled since we also want "normal" run loop mode.
                                target: self selector: @selector(fadeInOneStep:)
                                userInfo: nil repeats: YES];
    [[NSRunLoop currentRunLoop] addTimer: timer forMode: NSModalPanelRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer: timer forMode: NSEventTrackingRunLoopMode];
    [pendingFades setObject: [NSMutableDictionary dictionaryWithObjectsAndKeys: timer, @"timer",
                                                [NSNumber numberWithFloat: stepSize], @"stepSize",
                                                nil] forKey: key];    // Releases of any old fades.
}


-(void) fadeInOneStep: (NSTimer*)timer
{
    NSString*   key = [NSString stringWithFormat: @"%lx", self];
    float       newAlpha = [self alphaValue] + [[[pendingFades objectForKey: key] objectForKey: @"stepSize"] floatValue];
    
    if( newAlpha >= 1.0 )
    {
        newAlpha = 1;
        [timer invalidate];
        [pendingFades removeObjectForKey: key];
    }
    
    //UKLog(@"Fading in: %f", newAlpha);
    [self setAlphaValue: newAlpha];
}


-(void)     fadeOutWithDuration: (NSTimeInterval)duration
{
    if( !pendingFades )
        pendingFades = [[NSMutableDictionary alloc] init];
    
    NSString*       key = [NSString stringWithFormat: @"%lx", self];
    NSDictionary*   fade = [pendingFades objectForKey: key];
    
    if( fade )      // Currently fading that window? Abort that fade:
        [[fade objectForKey: @"timer"] invalidate];  // No need to remove from pendingFades, we'll replace it in a moment.
    
    [self setAlphaValue: 1.0];
    
    NSTimeInterval  interval = duration / 0.1;
    float           stepSize = 1 / interval;
    NSTimer*        timer = [NSTimer scheduledTimerWithTimeInterval: 0.1				// scheduled since we also want "normal" run loop mode.
                                target: self selector: @selector(fadeOutOneStep:)
                                userInfo: nil repeats: YES];
    [pendingFades setObject: [NSMutableDictionary dictionaryWithObjectsAndKeys: timer, @"timer",
                                                [NSNumber numberWithFloat: stepSize], @"stepSize",
                                                nil] forKey: key];    // Releases of any old fades.
    [[NSRunLoop currentRunLoop] addTimer: timer forMode: NSModalPanelRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer: timer forMode: NSEventTrackingRunLoopMode];
}

-(void) fadeOutOneStep: (NSTimer*)timer
{
    NSString*				key = [NSString stringWithFormat: @"%lx", self];
	NSMutableDictionary*	currFadeDict = [[[pendingFades objectForKey: key] retain] autorelease];	// Make sure it doesn't go away in case we're cross-fading layers.
    float					newAlpha = [self alphaValue] - [[currFadeDict objectForKey: @"stepSize"] floatValue];
    
    if( newAlpha <= 0 )
    {
        [timer invalidate];
		
		[pendingFades removeObjectForKey: key];
		
		NSNumber*	newLevel = [currFadeDict objectForKey: @"newLevel"];
		if( newLevel )
		{
			NSTimer*        timer = [NSTimer scheduledTimerWithTimeInterval: 0.1				// scheduled since we also want "normal" run loop mode.
                                target: self selector: @selector(fadeInOneStep:)
                                userInfo: nil repeats: YES];
			[currFadeDict setObject: timer forKey: @"timer"];
			[pendingFades setObject: currFadeDict forKey: key];
			[[NSRunLoop currentRunLoop] addTimer: timer forMode: NSModalPanelRunLoopMode];
			[[NSRunLoop currentRunLoop] addTimer: timer forMode: NSEventTrackingRunLoopMode];
			
			[self setLevel: [newLevel intValue]];
			//UKLog(@"Changing level to %u", [newLevel unsignedIntValue]);
			
			newAlpha = 0;
		}
		else
		{
			newAlpha = 1;           // Make opaque again so non-fading showing of window doesn't look unsuccessful.
			[self orderOut: nil];   // Hide so setAlphaValue below doesn't cause window to fade out, then pop in again.
		}
    }

	//UKLog(@"Fading out: %f", newAlpha);		// DEBUG ONLY!
	[self setAlphaValue: newAlpha];
}


-(void)	fadeToLevel: (int)lev withDuration: (NSTimeInterval)duration
{
    if( !pendingFades )
        pendingFades = [[NSMutableDictionary alloc] init];
    
    NSString*       key = [NSString stringWithFormat: @"%lx", self];
    NSDictionary*   fade = [pendingFades objectForKey: key];
    
    if( fade )      // Currently fading that window? Abort that fade:
        [[fade objectForKey: @"timer"] invalidate];  // No need to remove from pendingFades, we'll replace it in a moment.
    
    [self setAlphaValue: 1.0];
    
    NSTimeInterval  interval = (duration /2) / 0.1;
    float           stepSize = 1 / interval;
    NSTimer*        timer = [NSTimer scheduledTimerWithTimeInterval: 0.1				// scheduled since we also want "normal" run loop mode.
                                target: self selector: @selector(fadeOutOneStep:)
                                userInfo: nil repeats: YES];
    [pendingFades setObject: [NSMutableDictionary dictionaryWithObjectsAndKeys: timer, @"timer",
                                                [NSNumber numberWithFloat: stepSize], @"stepSize",
                                                [NSNumber numberWithInt: lev], @"newLevel",
                                                nil] forKey: key];    // Releases of any old fades.
    [[NSRunLoop currentRunLoop] addTimer: timer forMode: NSModalPanelRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer: timer forMode: NSEventTrackingRunLoopMode];
}


@end
