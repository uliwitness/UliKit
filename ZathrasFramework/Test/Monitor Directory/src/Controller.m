//
//  Controller.m
//  Zathras
//
//  Created by Matthieu Cormier on 1/23/10.
//

#import "Controller.h"


@implementation Controller

-(id) init {
  self = [super init];
  if( !self ) 
    return nil;
 
  desktopPath = [@"~/Desktop/" stringByExpandingTildeInPath];
  [desktopPath retain];

  homePath = [@"~/" stringByExpandingTildeInPath];
  [homePath retain];

  
  return self;
}

-(void)awakeFromNib {

  id<UKFileWatcher> watcher;
  
  // A UKFNSubscribeFileWatcher will notify your
  // application when it has focus.
  // UKFNSubscribeFileWatcher can only monitor directories.
  watcher = [UKFNSubscribeFileWatcher sharedFileWatcher];
  [watcher addPath:desktopPath];
  [watcher setDelegate:self];

  // A UKKQueue will notify your application as soon
  // as the change occurs, whether you application is
  // currently focused or not.
  // UKKQueue can monitor files and directories.
  watcher = [UKKQueue sharedFileWatcher];
  [watcher addPath:homePath];
  
 
  [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(homeDirChanged:)                   
                                               name:UKFileWatcherWriteNotification object:nil]; 
  
  // NOTE:
  // Whether you monitor a directory with either type
  // of watcher you will only receive UKFileWatcherWriteNotification
  // for directories.
}

-(void)dealloc {
  [desktopPath release];
  [homePath release];
  [super dealloc];
}

-(void) watcher:(id<UKFileWatcher>)kq receivedNotification:(NSString*)nm 
        forPath: (NSString*)fpath {
     NSLog(@"Something in the Desktop folder changed.");
}

- (void)homeDirChanged:(NSNotification*)notification {
  NSLog(@"homeDir Changed");
}



@end
