//
//  UKFirstResponder.h
//  Shovel
//
//  Created by Uli Kusterer on 04.10.04.
//  Copyright 2004 M. Uli Kusterer. All rights reserved.
//

/*
	This is a nice little object that lets you send messages up the responder
	chain as if it was just another object to send messages to.
*/


#import <Cocoa/Cocoa.h>


@interface UKFirstResponder : NSObject {}

+(id)	firstResponder;

-(BOOL)	respondsToSelector: (SEL)itemAction;
-(id)	performSelector: (SEL)itemAction;
-(id)	performSelector: (SEL)itemAction withObject: (id)obj;

@end
