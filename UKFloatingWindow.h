//
//  UKFloatingWindow.h
//  Filie
//
//  Created by Uli Kusterer on 20.02.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface UKFloatingWindow : NSPanel
{
	BOOL		canBecomeMainWindow;
	BOOL		canBecomeKeyWindow;
}

-(BOOL)			canBecomeMainWindow;
-(void)			setCanBecomeMainWindow: (BOOL)state;

-(BOOL)			canBecomeKeyWindow;
-(void)			setCanBecomeKeyWindow: (BOOL)state;

@end
