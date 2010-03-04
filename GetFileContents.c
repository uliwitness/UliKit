//
//	GetFileContents.h
//	Carlson
//	
//	Created by Uli Kusterer on 16.04.06.
//	Copyright 2006 Uli Kusterer.
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

#include "GetFileContents.h"
#include <stdio.h>
#include <stdlib.h>


char*	GetFileContents( const char* fname )
{
	// Open script to run:
	FILE*	theFile = fopen( fname, "r" );
	if( !theFile )
	{
		printf("ERROR: Can't open file \"%s\".\n", fname);
		return NULL;
	}
	
	// Find out file length:
	fseek( theFile, 0, SEEK_END );
	int		len = ftell( theFile ),
			readbytes;
	char*	codeStr = (char*) malloc( len +1 );
	
	// Rewind and read in whole file:
	fseek( theFile, 0, SEEK_SET );
	readbytes = fread( codeStr, 1, len, theFile );
	if( readbytes != len )
	{
		free( codeStr );
		fclose( theFile );
		printf("ERROR: Couldn't read from file \"%s\" (%d bytes read).\n",fname,readbytes);
		return NULL;
	}
	codeStr[len] = 0;	// Terminate string.
	fclose( theFile );
	
	return codeStr;
}


