//
//  SCParamBlock.m
//  xDownload
//
//  Created by Uli Kusterer on 20.01.07.
//  Copyright 2007 Uli Kusterer.
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

#import "SCParamBlock.h"


@implementation SCParamBlock

-(id)	initWithXCmdBlock: (XCmdPtr)pblock
{
	self = [super init];
	if( self )
	{
		paramPtr = pblock;
	}
	
	return self;
}


-(int)	parameterCount
{
	return paramPtr->paramCount;
}


-(NSString*)	parameterAtIndex: (int)ind
{
	if( ind >= paramPtr->paramCount )
		return nil;
	
	if( paramPtr->params[ind] == NULL )
		return nil;
	
	return [NSString stringWithCString: *paramPtr->params[ind] encoding: NSMacOSRomanStringEncoding];
}


-(void)	setParameterAtIndex: (int)ind to: (NSString*)str
{
	NSData*		textData = [str dataUsingEncoding: NSMacOSRomanStringEncoding];
	
	[self setParameterDataAtIndex: ind to: textData];
}


-(void)	setParameterDataAtIndex: (int)ind to: (NSData*)theData
{
	if( ind >= paramPtr->paramCount )
		[NSException raise: @"SCParamBlockNotEnoughParamsException" format: @"Tried to change parameter %ld, but only got %d parameters.", ind, paramPtr->paramCount];
		
	SetHandleSize( paramPtr->params[ind], [theData length] );
	if( MemError() != noErr )
		[NSException raise: @"SCParamBlockNotEnoughMemoryException" format: @"Not enough memory to resize parameter %d.",ind];
	
	memmove( *paramPtr->params[ind], [theData bytes], [theData length] );
}


-(NSData*)	parameterDataAtIndex: (int)ind
{
	if( ind >= paramPtr->paramCount )
		return nil;
	
	if( paramPtr->params[ind] == NULL )
		return nil;
	
	return [NSData dataWithBytes: *paramPtr->params[ind] length: GetHandleSize(paramPtr->params[ind])];
}


-(void)	setReturnValue: (NSString*)str
{
	if( paramPtr->returnValue )
	{
		DisposeHandle( paramPtr->returnValue );
		paramPtr->returnValue = NULL;
	}
	paramPtr->returnValue = [SCParamBlock stringHandleFromString: str];
}


-(void)			sendCardMessage: (NSString*)superTalkStatement
{
	Str255		theMessage;
	[SCParamBlock setStringPtr: theMessage toString: superTalkStatement];
	SendCardMessage( paramPtr, theMessage );
}


-(void)			sendSCMessage: (NSString*)superTalkStatement
{
	Str255		theMessage;
	[SCParamBlock setStringPtr: theMessage toString: superTalkStatement];
	SendHCMessage( paramPtr, theMessage );
}


-(NSString*)	evaluateExpression: (NSString*)superTalkExpression
{
	Str255		theMessage;
	NSString*	retVal = nil;
	
	[SCParamBlock setStringPtr: theMessage toString: superTalkExpression];
	Handle	theString = EvalExpr( paramPtr, theMessage );
	if( theString )
	{
		retVal = [SCParamBlock stringFromStringHandle: theString];
		DisposeHandle(theString);
	}
	
	return retVal;
}



-(NSString*)	valueForGlobal: (NSString*)globalName
{
	Str255		theName;
	NSString*	retVal = nil;
	
	[SCParamBlock setStringPtr: theName toString: globalName];
	Handle	theString = GetGlobal( paramPtr, theName );
	if( theString )
	{
		retVal = [SCParamBlock stringFromStringHandle: theString];
		DisposeHandle(theString);
	}
	
	return retVal;
}


-(void)			setValue: (NSString*)var forGlobal: (NSString*)globalName
{
	Str255		theName;
	
	[SCParamBlock setStringPtr: theName toString: globalName];
	Handle	theString = [SCParamBlock stringHandleFromString: var];
	if( theString )
	{
		SetGlobal( paramPtr, theName, theString );
		DisposeHandle(theString);
	}
}



-(NSString*)	valueOfFieldNamed: (NSString*)fieldName onCardLayer: (BOOL)yorn
{
	Str255		theName;
	NSString*	retVal = nil;
	
	[SCParamBlock setStringPtr: theName toString: fieldName];
	Handle	theString = GetFieldByName( paramPtr, yorn, theName );
	if( theString )
	{
		retVal = [SCParamBlock stringFromStringHandle: theString];
		DisposeHandle(theString);
	}
	
	if( paramPtr->result != xresSucc )
		[NSException raise: @"SCParamBlockNoSuchFieldException" format: @"No %s field with name \"%@\" exists.", yorn?"card":"background", fieldName];

	return retVal;
}


-(NSString*)	valueOfFieldNumber: (int)num onCardLayer: (BOOL)yorn
{
	NSString*	retVal = nil;
	
	Handle	theString = GetFieldByNum( paramPtr, yorn, num );
	if( theString )
	{
		retVal = [SCParamBlock stringFromStringHandle: theString];
		DisposeHandle(theString);
	}
	
	if( paramPtr->result != xresSucc )
		[NSException raise: @"SCParamBlockNoSuchFieldException" format: @"No %s field with number %d exists.", yorn?"card":"background", num];

	return retVal;
}


-(NSString*)	valueOfFieldID: (int)num onCardLayer: (BOOL)yorn
{
	NSString*	retVal = nil;
	
	Handle	theString = GetFieldByID( paramPtr, yorn, num );
	if( theString )
	{
		retVal = [SCParamBlock stringFromStringHandle: theString];
		DisposeHandle(theString);
	}

	if( paramPtr->result != xresSucc )
		[NSException raise: @"SCParamBlockNoSuchFieldException" format: @"No %s field with ID %d exists.", yorn?"card":"background", num];
	
	return retVal;
}



-(void)			setValue: (NSString*)val forFieldNamed: (NSString*)fieldName onCardLayer: (BOOL)yorn
{
	Str255		theName;
	
	[SCParamBlock setStringPtr: theName toString: fieldName];
	Handle	theString = [SCParamBlock stringHandleFromString: val];
	if( theString )
	{
		SetFieldByName( paramPtr, yorn, theName, theString );
		DisposeHandle(theString);
	}

	if( paramPtr->result != xresSucc )
		[NSException raise: @"SCParamBlockNoSuchFieldException" format: @"No %s field with name \"%@\" exists.", yorn?"card":"background", fieldName];
}


-(void)			setValue: (NSString*)val forFieldNumber: (int)num onCardLayer: (BOOL)yorn
{
	Handle	theString = [SCParamBlock stringHandleFromString: val];
	if( theString )
	{
		SetFieldByNum( paramPtr, yorn, num, theString );
		DisposeHandle(theString);
	}

	if( paramPtr->result != xresSucc )
		[NSException raise: @"SCParamBlockNoSuchFieldException" format: @"No %s field with number %d exists.", yorn?"card":"background", num];
}


-(void)			setValue: (NSString*)val forFieldID: (int)num onCardLayer: (BOOL)yorn
{
	Handle	theString = [SCParamBlock stringHandleFromString: val];
	if( theString )
	{
		SetFieldByID( paramPtr, yorn, num, theString );
		DisposeHandle(theString);
	}

	if( paramPtr->result != xresSucc )
		[NSException raise: @"SCParamBlockNoSuchFieldException" format: @"No %s field with ID %d exists.", yorn?"card":"background", num];
}



+(Handle)	stringHandleFromString: (NSString*)str
{
	NSData*		textData = [str dataUsingEncoding: NSMacOSRomanStringEncoding];
	return [SCParamBlock stringHandleFromData: textData];
}


+(void)	setStringPtr: (StringPtr)theString toString: (NSString*)str
{
	NSData*		textData = [str dataUsingEncoding: NSMacOSRomanStringEncoding];
	if( [textData length] > 255 )
		[NSException raise: @"SCParamBlockStringTooLongException" format: @"Can't turn a string longer than 255 character into a StringPtr."];
	else
		theString[0] = [textData length];
	memmove( theString +1, [textData bytes], theString[0] );
}


+(Handle)	stringHandleFromData: (NSData*)theData
{
	Handle		theHd = NewHandle( [theData length] );
	
	if( theHd && MemError() == noErr )
	{
		memmove( *theHd, [theData bytes], [theData length] );
	
		return theHd;
	}
	else
		return NULL;
}


+(NSString*)	stringFromStringHandle: (Handle)theHd
{
	return [NSString stringWithCString: *theHd encoding: NSMacOSRomanStringEncoding];
}


+(NSData*)	dataFromStringHandle: (Handle)theHd
{
	return [NSData dataWithBytes: *theHd length: GetHandleSize(theHd)];
}



@end
