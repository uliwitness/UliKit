//
//  UKUIElement.h
//  TalkingMoose
//
//  Created by Uli Kusterer on 03.07.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface UKUIElement : NSObject
{
    AXUIElementRef      theUIElement;
}

+(BOOL)             makeSureAccessibilityIsEnabled;
+(BOOL)             isAccessibilityEnabled;

+(UKUIElement*)     systemWideUIElement;                            // The "system wide" UI Element.
+(UKUIElement*)     uiElementForApplicationWithPID: (pid_t)thepid;  // UI Element for another app.
+(UKUIElement*)     applicationUIElement;                           // UI Element for current app.

-(id)               initWithUIElementRef: (AXUIElementRef)ref;

-(NSArray*)         allKeys;                                        // List of all attribute names.
-(id)               objectForKey: (NSString*)keyStr;                // Get an attribute's value.
-(NSArray*)         arrayForKey: (NSString*)keyStr;
-(void)             setObject: (id)val forKey: (NSString*)keyStr;   // CHange an attribute's value.

-(pid_t)            owningAppPID;

-(AXUIElementRef)   uiElementRef;

@end


@interface UKUINotificationCenter : NSObject
{
    AXObserverRef           theObserver;
}

-(id)   initWithPID: (pid_t)thepid;

-(void) addObserver: (id)object selector: (SEL)sel name: (NSString*)nm object: (UKUIElement*)ele;
-(void) removeObserver: (id)object;


@end