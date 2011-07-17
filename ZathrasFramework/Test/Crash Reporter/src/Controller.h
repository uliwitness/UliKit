//
//  Controller.h
//  Zathras
//
//  Created by Matthieu Cormier on 7/16/11.
//  Copyright 2011 Preen and Prune Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Zathras/Zathras.h>

@interface Controller : NSObject {

  NSMutableString* forCrashingApp;
}

-(IBAction) crashApplication:(id)sender;

@end
