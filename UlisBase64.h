/*
 *  UlisBase64.h
 *  thiSwaY
 *
 *  Created by Uli Kusterer on Sat Nov 22 2003.
 *  Copyright (c) 2003 M. Uli Kusterer. All rights reserved.
 *  Based on code by Dave Winer <dwiner@well.com>, found at
 *  <http://www.scripting.com/midas/base64/source.html>, (c) 1997.
 *
 */

/* Takes the specified string (must consist of 8-bit characters) and converts
	it to Base64. Also wraps the line to linelength characters per line (not
	counting the line break itself), which must be a multiple of four. */
NSString*   UKBase64Encode( NSData* inData, short linelength );

/* Takes the specified Base64 string and converts it back to Whatever it was
	originally. */
NSData*		UKBase64Decode( NSString* str );


/* Convenience: String variants of above functions:
	These encode/decode the string as ISO Latin-1, which is what you'll most
	frequently encounter when you get text from the net. */
NSString*   UKBase64EncodeString( NSString* inData, short linelength );
NSString*   UKBase64DecodeString( NSString* str );



