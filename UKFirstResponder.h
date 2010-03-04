//
//  UKFirstResponder.h
//  Shovel
//
//  Created by Uli Kusterer on 04.10.04.
//  Copyright 2004 Uli Kusterer.
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

/*
	This is a nice little object that lets you send messages up the responder
	chain as if it was just another object to send messages to.
*/


#import <Cocoa/Cocoa.h>


@interface UKFirstResponder : NSObject
{
	
}

+(id)	firstResponder;

-(BOOL)	respondsToSelector: (SEL)itemAction;
-(id)	performSelector: (SEL)itemAction;
-(id)	performSelector: (SEL)itemAction withObject: (id)obj;

@end
