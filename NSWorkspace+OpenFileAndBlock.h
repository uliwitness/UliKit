//
//  NSWorkspace+OpenFileAndBlock.h
//  Shovel
//
//  Created by Uli Kusterer on Wed Mar 31 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSWorkspace (UKOpenFileAndBlock)

-(BOOL) openFileAndBlock: (NSString*)path;
-(BOOL) openFileAndBlock: (NSString*)path withApplication: (NSString*)appPath;

@end
