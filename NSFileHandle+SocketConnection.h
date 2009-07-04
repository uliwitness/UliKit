//
//  NSFileHandle+SocketConnection.m
//  thiSwaY
//
//  Created by Sander Niemeijer on Sun Dec 23 2001.
//	Reformatted and commented by M. Uli Kusterer, 2003-09-21.
//

#import <Foundation/Foundation.h>


@interface NSFileHandle (UKFileHandleSocketConnection)

+(id)	fileHandleForConnectionToHost: (NSString*)hostname atPort: (unsigned short)port;
+(id)	fileHandleForDatagramToHost: (NSString*)hostname atPort: (unsigned short)port;
+(id)	fileHandleForConnectionToHost: (NSString*)hostname atPort: (unsigned short)port type: (int)typ;

@end 
