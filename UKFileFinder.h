//
//  UKFileFinder.h
//  Shovel
//
//  Created by Uli Kusterer on Wed Mar 24 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UKFileFinder : NSObject
{
	NSMutableString*		tempBuffer;		// Buffer where we capture find's output.
	NSTask*					findTask;		// Task we use for running "find".
	NSPipe*					findPipe;		// Pipe for output.
	NSString*				lastPath;		// The last path fetched using nextObject;
}

+(id)			fileFinderForFolder: (NSString*)folder withPattern: (NSString*)pattern;

-(id)			initForFolder: (NSString*)folder withPattern: (NSString*)pattern;

-(NSString*)		nextObject;
-(NSDictionary*)	fileAttributes;

// Private:
-(void)		captureOutput: (id)sender;

@end
