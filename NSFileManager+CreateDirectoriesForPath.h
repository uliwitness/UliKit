//
//  NSFileManager+CreateDirectoriesForPath.h
//  CocoaMoose
//
//  Created by Uli Kusterer on 13.01.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>


// -----------------------------------------------------------------------------
//  Categories:
// -----------------------------------------------------------------------------

@interface NSFileManager (CreateDirectoriesForPath)

-(BOOL) createDirectoriesForPath: (NSString*)str;   // Create all directories up to and including the specified directory.

@end
