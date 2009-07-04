//
//  SCParamBlock.h
//  xDownload
//
//  Created by Uli Kusterer on 20.01.07.
//  Copyright 2007 M. Uli Kusterer. All rights reserved.
//

/* Nice little Cocoa wrapper around the XCmdPtr. */

#import <Cocoa/Cocoa.h>
#import "SuperXCmd.h"


// Make our class name unique. SuperCard can't unload Cocoa classes, and
//	there can only be one class of a particular name. The #define below will
//	make sure that we can use the name SCParamBlock everywhere, but the compiler
//	will actually call it SCParamBlock_xDownload. You may also want to append
//	the version number here, so newer versions of your XCmd don't get the old
//	classes if two projects are using different versions of your XCmd.
//	You also may have to do the same for your other classes.

// Change this to your external's name:
#define SCParamBlock		SCParamBlock_xHttpPost


@interface SCParamBlock : NSObject
{
	XCmdPtr		paramPtr;
}

-(id)			initWithXCmdBlock: (XCmdPtr)pblock;

// Parameters:
-(int)			parameterCount;

-(NSString*)	parameterAtIndex: (int)ind;
-(void)			setParameterAtIndex: (int)ind to: (NSString*)str;	// For pass-by-reference parameters.

-(NSData*)		parameterDataAtIndex: (int)ind;
-(void)			setParameterDataAtIndex: (int)ind to: (NSData*)theData;	// For pass-by-reference parameters.

// Return value:
-(void)			setReturnValue: (NSString*)str;


// Callbacks:
-(void)			sendCardMessage: (NSString*)superTalkStatement;
-(void)			sendSCMessage: (NSString*)superTalkStatement;
-(NSString*)	evaluateExpression: (NSString*)superTalkExpression;

-(NSString*)	valueForGlobal: (NSString*)globalName;
-(void)			setValue: (NSString*)var forGlobal: (NSString*)globalName;

-(NSString*)	valueOfFieldNamed: (NSString*)fieldName onCardLayer: (BOOL)yorn;
-(NSString*)	valueOfFieldNumber: (int)num onCardLayer: (BOOL)yorn;
-(NSString*)	valueOfFieldID: (int)num onCardLayer: (BOOL)yorn;

-(void)			setValue: (NSString*)val forFieldNamed: (NSString*)fieldName onCardLayer: (BOOL)yorn;
-(void)			setValue: (NSString*)val forFieldNumber: (int)num onCardLayer: (BOOL)yorn;
-(void)			setValue: (NSString*)val forFieldID: (int)num onCardLayer: (BOOL)yorn;

// Low-level utility stuff:
+(Handle)		stringHandleFromString: (NSString*)str;
+(Handle)		stringHandleFromData: (NSData*)theData;

+(NSString*)	stringFromStringHandle: (Handle)theHd;
+(NSData*)		dataFromStringHandle: (Handle)theHd;

+(void)			setStringPtr: (StringPtr)theString toString: (NSString*)str;	// theString must be a variable of type Str255.

@end
