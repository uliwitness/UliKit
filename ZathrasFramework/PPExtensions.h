//
//  PPExtensions.h
//  Zathras
//
//  Created by Matthieu Cormier on 7/16/11.
//  Copyright 2011 Preen and Prune Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UKFileWatcher.h"

// -----------------------------------------------------------------------------
//  Methods delegates need to provide:
// -----------------------------------------------------------------------------
@protocol UKFileWatcherDelegate
-(void) watcher: (id<UKFileWatcher>)kq receivedNotification: (NSString*)nm forPath: (NSString*)fpath;
@end