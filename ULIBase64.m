//
//	ULIBase64.m
//	thiS waY
//
//	Created by Uli Kusterer on 22.11.2003
//	Copyright 2003 by Uli Kusterer, based on code by Dave Winer
//		from <http://www.scripting.com/midas/base64/source.html>, (c) 1997.
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

#include "ULIBase64.h"


// Lookup table:

static char ULIBase64EncodingTable[64] =
{ 
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
    
    'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
    
    'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
    
    'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'
};


NSString*   ULIBase64Encode( NSData* inData, short linelength )
{
	NSMutableString*		outStr = [[[NSMutableString alloc] init] autorelease];
	unsigned long			ixtext = 0;
	unsigned long			lentext = [inData length];
	long					ctremaining;
	unsigned char			inbuf[3],
							outbuf[4];
	short					i;
	short					charsonline = 0,
							ctcopy;
	
	while( YES )
	{
		ctremaining = lentext - ixtext;
		
		if( ctremaining <= 0 )
			break;
	
		// Get the first three characters to convert:
		for( i = 0; i < 3; i++ )
		{ 
			unsigned long   ix = ixtext + i;
	
			if( ix < lentext )  // Still text available?
				[inData getBytes: &(inbuf[i]) range: NSMakeRange(ix,1)];
			else				// Text length not a multiple of four.
				inbuf[i] = 0;   // Stash a zero here so the code below doesn't have anything to do.
		}
		
		// Extract the four 6-bit-parts of our three bytes:
		outbuf[0] = (inbuf[0] & 0xFC) >> 2;
		outbuf[1] = ((inbuf[0] & 0x03) << 4) | ((inbuf[1] & 0xF0) >> 4);
		outbuf[2] = ((inbuf[1] & 0x0F) << 2) | ((inbuf[2] & 0xC0) >> 6);
		outbuf[3] = inbuf[2] & 0x3F;
				
		// Determine how many characters there are to go:
		ctcopy = 4;
		
		switch( ctremaining )
		{
			case 1: 
				ctcopy = 2; 
				break;
		
			case 2: 
				ctcopy = 3; 
				break;
		}
		
		// Now write the encoded versions of these characters out:
		for( i = 0; i < ctcopy; i++ )
			[outStr appendFormat: @"%c", ULIBase64EncodingTable[outbuf[i]] ];
		
		// If less than four, write "equals" signs as placeholders:
		for( i = ctcopy; i < 4; i++ )
			[outStr appendString: @"="];
		
		ixtext += 3;		// Move counter so we continue reading after the three chars read.
		charsonline += 4;   // Update counter to remember how many chars we just wrote to the current line.
		
		if( linelength > 0 ) // 0 means no line breaks.
		{
			if( charsonline >= linelength )		// The line is full?
			{
				charsonline = 0;				// Reset "chars on line" counter.
				[outStr appendString: @"\n"];   // Append a line break.
			}
		}
	}
	
	return outStr;
}


NSData*   ULIBase64Decode( NSString* str )
{
	NSMutableData   *	outData = [[[NSMutableData alloc] init] autorelease];
	unsigned long		ixtext = 0;
	unsigned long		lentext = [str length];
	unsigned char		ch = '\0';
	unsigned char		inbuf[4] = {},
						outbuf[4] = {};
	short				ixinbuf = 0;
	BOOL				flignore = NO;
	BOOL				flendtext = NO;
	
	while( YES )
	{
		flignore = NO;
		
		if( ixtext >= lentext )
			break;
		
		ch = [str characterAtIndex: ixtext++];
	
		// Convert the base64 characters to their corresponding integer values:
		if( (ch >= 'A') && (ch <= 'Z') )
			ch = ch - 'A';
		else if( (ch >= 'a') && (ch <= 'z') )
			ch = ch - 'a' + 26;
		else if ((ch >= '0') && (ch <= '9'))
			ch = ch - '0' + 52;
		else if (ch == '+')
			ch = 62;
		else if (ch == '=') // no op -- can't fl-ignore this one.
			flendtext = YES;
		else if (ch == '/')
			ch = 63;
		else	// fl-ignore all other characters (e.g. line feeds):
			flignore = YES;
	
		if( !flignore )
		{
			short		ctcharsinbuf = 3;
			BOOL		flbreak = NO;
			
			// Are at end of text? Flush out the remaining chars:
			if( flendtext )
			{
				if( ixinbuf == 0 )
					break;
				
				if( (ixinbuf == 1) || (ixinbuf == 2) )
					ctcharsinbuf = 1;
				else
					ctcharsinbuf = 2;
		
				ixinbuf = 3;
				flbreak = YES;
			}
	
			// Add this char to our buffer:
			inbuf[ixinbuf++] = ch;
	
			// Input buffer is full? Write the current three chars out:
			if( ixinbuf == 4 )
			{
				ixinbuf = 0;
		
				outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
				outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
				outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);

				[outData appendBytes: outbuf length: ctcharsinbuf ];
			}
	
			if( flbreak )
				break;
		}
	}
	
	return outData;
}


// Convenience methods for use by SMTP code etc:

NSString*   ULIBase64EncodeString( NSString* inData, short linelength )
{
	return ULIBase64Encode( [inData dataUsingEncoding: NSISOLatin1StringEncoding], linelength );
}


NSString*   ULIBase64DecodeString( NSString* str )
{
	return [[[NSString alloc] initWithData: ULIBase64Decode(str) encoding: NSISOLatin1StringEncoding] autorelease];
}

