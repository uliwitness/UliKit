//
//  NSFileHandle+SocketConnection.m
//  thiSwaY
//
//  Created by Sander Niemeijer on Sun Dec 23 2001.
//	Copyright 2001-2003 by Uli Kusterer and Sander Niemeijer.
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

/* -----------------------------------------------------------------------------
	Headers:
   -------------------------------------------------------------------------- */

#import <netdb.h>
#import <netinet/in.h>
#import <sys/socket.h>
#import <unistd.h>
#import <fcntl.h>

#import "NSFileHandle+SocketConnection.h"


@implementation NSFileHandle (UKFileHandleSocketConnection)

/* -----------------------------------------------------------------------------
	fileHandleForConnectionToHost:atPort:
		Uses Unix socket APIs to create a file descriptor to a socket, and
		then generates an NSFileHandle for that file descriptor that can be
		used for actual asynchronous data transfer.
   -------------------------------------------------------------------------- */
   
+(id)	fileHandleForConnectionToHost: (NSString*)hostname atPort: (unsigned short)port
{
	return [self fileHandleForConnectionToHost: hostname atPort: port type: SOCK_STREAM];
}

+(id)	fileHandleForDatagramToHost: (NSString*)hostname atPort: (unsigned short)port
{
	return [self fileHandleForConnectionToHost: hostname atPort: port type: SOCK_DGRAM];
}

+(id)	fileHandleForConnectionToHost: (NSString*)hostname atPort: (unsigned short)port type: (int)typ
{
	struct hostent		*hostinfo;
	struct sockaddr_in	remoteAddr; 
	int					fd; 
	int					i; 
	
	// Resolve the hostname 
	hostinfo = gethostbyname( [hostname cString] ); 
	if( hostinfo == NULL ) 
	{ 
		[NSException	raise:@"NSFileHandleSocketConnection"
						format:@"Could not find host"]; 
	} 
	
	// Retrieve a socket 
	fd = socket( PF_INET, typ, 0 ); 
	if( fd == -1 ) 
	{ 
		[NSException	raise:@"NSFileHandleSocketConnection"
						format:@"Could not open a socket"]; 
	} 
	
	// Try to make a connection to the host by trying all possible addresses 
	bzero( (char*) &remoteAddr, sizeof(remoteAddr) ); 
	remoteAddr.sin_family = AF_INET; 
	remoteAddr.sin_port = htons(port);
	for( i=0; hostinfo->h_addr_list[i] != NULL; i++ )
	{
		remoteAddr.sin_addr = *(struct in_addr *)hostinfo->h_addr_list[i];
		if( connect(fd,(struct sockaddr *)&remoteAddr,sizeof(remoteAddr)) == 0 )
		{
			// Connection was succesful:
			return [[[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:YES] autorelease];
		}
	}
	
	// No connection could be made
	[NSException raise:@"NSFileHandleSocketConnection" format:@"Could not connect to host"];
	
	// Should never be reached
	return nil;
}


@end