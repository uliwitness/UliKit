//
//  NSFileManager+CreateDirectoriesForPath.m
//  CocoaMoose
//
//  Created by Uli Kusterer on 13.01.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
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
