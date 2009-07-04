/*
 *  GetFileContents.c
 *  Carlson
 *
 *  Created by Uli Kusterer on 16.04.06.
 *  Copyright 2006 Uli Kusterer. All rights reserved.
 *
 */

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


