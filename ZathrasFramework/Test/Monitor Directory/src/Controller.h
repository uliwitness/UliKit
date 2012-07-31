//
//  Controller.h
//  Zathras
//
//  Created by Matthieu Cormier on 1/23/10.
//  Copyright 2010 Preen and Prune Software and Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Zathras/Zathras.h>

@interface Controller : NSObject <UKFileWatcherDelegate> {
  
  @private
  NSString *desktopPath, *homePath;
}


@end
