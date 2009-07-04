//
//  UKFloatingWindow.m
//  Filie
//
//  Created by Uli Kusterer on 20.02.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import "UKFloatingWindow.h"


@implementation UKFloatingWindow

-(BOOL)			canBecomeMainWindow
{
	return canBecomeMainWindow;
}


-(void)			setCanBecomeMainWindow: (BOOL)state
{
	canBecomeMainWindow = state;
}


-(void)			setCanBecomeKeyWindow: (BOOL)state
{
	canBecomeKeyWindow = state;
}

-(BOOL)			canBecomeKeyWindow
{
	return canBecomeKeyWindow;
}

@end