//
//  Controller.m
//  Zathras
//
//  Created by Matthieu Cormier on 7/16/11.
//  Copyright 2011 Preen and Prune Software. All rights reserved.
//

#import "Controller.h"


@implementation Controller



-(void)awakeFromNib {
  forCrashingApp = [[NSMutableString alloc] initWithCapacity:10];
  [forCrashingApp release];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishLaunching:) 
                                               name:NSApplicationDidFinishLaunchingNotification object:nil];  
}

-(IBAction) crashApplication:(id)sender {
  //Releasing an already released object will crash the app
  [forCrashingApp release];
}

- (void)didFinishLaunching:(NSNotification*)notification {
  // Check for crashes on startup.
  UKCrashReporterCheckForCrash();
}  

@end
