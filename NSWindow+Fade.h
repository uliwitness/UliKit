//
//  NSWindow+Fade.h
//  TalkingMoose
//
//  Created by Uli Kusterer on 22.06.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSWindow (UKFade)

-(void)     fadeInWithDuration: (NSTimeInterval)duration;
-(void)     fadeOutWithDuration: (NSTimeInterval)duration;
-(void)		fadeToLevel: (int)lev withDuration: (NSTimeInterval)duration;

// Private:
-(void)     fadeInOneStep: (NSTimer*)timer;
-(void)     fadeOutOneStep: (NSTimer*)timer;

@end
