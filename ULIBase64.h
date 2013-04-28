//
//	ULIBase64.h
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

#import <Foundation/Foundation.h>

/* Takes the specified string (must consist of 8-bit characters) and converts
	it to Base64. Also wraps the line to linelength characters per line (not
	counting the line break itself), which must be a multiple of four. */
NSString*   ULIBase64Encode( NSData* inData, short linelength );

/* Takes the specified Base64 string and converts it back to Whatever it was
	originally. */
NSData*		ULIBase64Decode( NSString* str );


/* Convenience: String variants of above functions:
	These encode/decode the string as ISO Latin-1, which is what you'll most
	frequently encounter when you get text from the net. */
NSString*   ULIBase64EncodeString( NSString* inData, short linelength );
NSString*   ULIBase64DecodeString( NSString* str );



