//
//  NSFileManager+CreateDirectoriesForPath.m
//  CocoaMoose
//
//  Created by Uli Kusterer on 13.01.05.
//  Copyright 2005 M. Uli Kusterer.
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

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import "NSFileManager+CreateDirectoriesForPath.h"


@implementation NSFileManager (CreateDirectoriesForPath)

// -----------------------------------------------------------------------------
//  createDirectoriesForPath:
//      Takes a path to a directory and creates all folders in this path that
//      do not exist. E.g. if you need /Applications/Tools/MyCompany/Foo but
//      only /Applications exists, this will create Tools, MyCompany and Foo.
//
//      Returns YES if it could create all directories, NO if it failed (e.g.
//      due to write-only media, insufficient permissions etc.).
//
//  REVISIONS:
//      2005-03-20  UK  Documented.
// -----------------------------------------------------------------------------

-(BOOL) createDirectoriesForPath: (NSString*)str
{
    NSAutoreleasePool*  pool = [[NSAutoreleasePool alloc] init];
    NSMutableArray*     pathsToCreate = [NSMutableArray array];
    NSString*           path = str;
    NSEnumerator*       enny;
    BOOL                success = YES;
    
    // Walk path backwards and find all components that don't exist,
    //  put their names in an array:
    while( ![[NSFileManager defaultManager] fileExistsAtPath: path] )
    {
        [pathsToCreate addObject: path];
        path = [path stringByDeletingLastPathComponent];
    }
    
    // Loop backwards over our array and thus go down the hierarchy and
    //  create all those folders:
    enny = [pathsToCreate reverseObjectEnumerator];
    while( success && (path = [enny nextObject]) )
        success = [[NSFileManager defaultManager] createDirectoryAtPath: path attributes: [NSDictionary dictionary]];
    
    [pool release];
    
    return success;
}

@end
