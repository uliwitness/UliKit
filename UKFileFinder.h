//
//  UKFileFinder.h
//  Shovel
//
//  Created by Uli Kusterer on Wed Mar 24 2004.
//  Copyright (c) 2004 Uli Kusterer.
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
