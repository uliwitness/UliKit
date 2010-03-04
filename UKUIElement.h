//
//  UKUIElement.h
//  TalkingMoose
//
//  Created by Uli Kusterer on 03.07.05.
//  Copyright 2005 Uli Kusterer.
//	
//	This software is provided 'as-is', without any express or implied
//	warranty. In no event will the authors be held liable for any damages
//	arising from the use of this software.
//
//	Permission is granted to anyone to use this software for any purpose,
//	including commercial applications, and to alter it and redistribute it
//	freely, subject to the following restrictions:
//
//	   1. The origin of this software must not be misrepresented; you must not
//	   claim that you wrote the original software. If you use this software
//	   in a product, an acknowledgment in the product documentation would be
//	   appreciated but is not required.
//
//	   2. Altered source versions must be plainly marked as such, and must not be
//	   misrepresented as being the original software.
//
//	   3. This notice may not be removed or altered from any source
//	   distribution.
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