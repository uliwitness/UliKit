//
//  NSFileManager+VisibleDirectoryContents.h
//  Shovel
//
//  Created by Uli Kusterer on 01.10.04.
//  Copyright 2004 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSFileManager (UKVisibleDirectoryContents)

// Same as directoryContentsAtPath, but filters out files whose names start with ".":
-(NSArray*)	visibleDirectoryContentsAtPath: (NSString*)path;

@end
