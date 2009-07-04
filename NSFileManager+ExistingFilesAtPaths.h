//
//  NSFileManager+ExistingFilesAtPaths.h
//  SVNBrowser
//
//  Created by Uli Kusterer on 14.10.04.
//  Copyright 2004 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSFileManager (UKExistingFilesAtPaths)

-(NSArray*)		existingFilesAtPaths: (NSArray*)paths;
-(NSString*)	firstExistingFileAtPaths: (NSArray*)paths;

@end
