//
//  UKUIElement.m
//  TalkingMoose
//
//  Created by Uli Kusterer on 03.07.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import "UKUIElement.h"
#import <sys/types.h>
#import <unistd.h>

void    UKUIObserverCallback( AXObserverRef observer, AXUIElementRef element, CFStringRef notification, void *refcon );

@implementation UKUIElement

+(BOOL)     isAccessibilityEnabled
{
    return AXAPIEnabled();
}
    
+(BOOL)     makeSureAccessibilityIsEnabled
{
    BOOL        axOn = AXAPIEnabled();

    if( !axOn )
    {
        int ret = NSRunAlertPanel( @"This Feature requires that the Accessibility API be enabled.", @"Would you like me to launch System Preferences so that you can turn on \"Enable access for assistive devices\"?",
                                    @"OK", @"Quit", @"Cancel");
        
        switch (ret)
        {
            case NSAlertDefaultReturn:
                [[NSWorkspace sharedWorkspace] openFile:@"/System/Library/PreferencePanes/UniversalAccessPref.prefPane"];
                while( !(axOn = AXAPIEnabled()) )
                    ;   // Wait for accessibility to be turned on.
                break;
                
            case NSAlertAlternateReturn:
                [NSApp terminate: self];
                return NO;
                break;
                
            case NSAlertOtherReturn: // just continue
            default:
                break;
        }
    }
    
    return axOn;
}

+(UKUIElement*)     systemWideUIElement
{
    static UKUIElement*     sysWideUIElement = nil;
    
    if( !sysWideUIElement )
        sysWideUIElement = [[UKUIElement alloc] initWithUIElementRef: AXUIElementCreateSystemWide()];
    
    return sysWideUIElement;
}


+(UKUIElement*)     applicationUIElement
{
    return [self uiElementForApplicationWithPID: getpid()];
}


+(UKUIElement*)     uiElementForApplicationWithPID: (pid_t)thepid
{
    UKUIElement*    appUIElement = nil;
    AXUIElementRef  ref = AXUIElementCreateApplication( thepid );
    
    appUIElement = [[[UKUIElement alloc] initWithUIElementRef: ref] autorelease];
    
    CFRelease( ref );
    
    return appUIElement;
}


-(id)   initWithUIElementRef: (AXUIElementRef)ref
{
    if( (self = [super init]) )
    {
        theUIElement = ref;
        CFRetain( theUIElement );
    }
    
    return self;
}

-(void) dealloc
{
    CFRelease( theUIElement );
    
    [super dealloc];
}


-(NSArray*)     allKeys
{
    NSArray*        arr = nil;
    AXError         err = kAXErrorSuccess;
    
    err = AXUIElementCopyAttributeNames( theUIElement, (CFArrayRef*) &arr );
    if( err != kAXErrorSuccess )
    {
        UKLog( @"allKeys AXUIElementCopyAttributeNames: MacOS Error ID = %d", err );
        return nil;
    }
    
    return [arr autorelease];
}


-(pid_t)            owningAppPID
{
    pid_t       pid = 0;
    
    if( kAXErrorSuccess != AXUIElementGetPid( theUIElement, &pid ) )
        return 0;
    else
        return pid;
}


-(id)   objectForKey: (NSString*)keyStr
{
    AXError         err = kAXErrorSuccess;
    id              val = nil;
    
    err = AXUIElementCopyAttributeValue( theUIElement, (CFStringRef) keyStr, (CFTypeRef*) &val );
    if( err != kAXErrorSuccess )
    {
        UKLog( @"objectForKey AXUIElementCopyAttributeValue: MacOS Error ID = %d", err );
        return nil;
    }
    
    return [val autorelease];
}


-(NSArray*) arrayForKey: (NSString*)keyStr
{
    AXError         err = kAXErrorSuccess;
    NSArray*        val = nil;
    
    err = AXUIElementCopyAttributeValues( theUIElement, (CFStringRef) keyStr, 0, 1000000, (CFArrayRef*) &val );
    if( err != kAXErrorSuccess )
    {
        UKLog( @"objectForKey AXUIElementCopyAttributeValues: MacOS Error ID = %d", err );
        return nil;
    }
    
    return [val autorelease];
}


-(void) setObject: (id)val forKey: (NSString*)keyStr
{
    AXError         err = kAXErrorSuccess;
    
    err = AXUIElementSetAttributeValue( theUIElement, (CFStringRef) keyStr, (CFTypeRef)val );

    if( err != kAXErrorSuccess )
        UKLog( @"setObject:forKey: AXUIElementSetAttributeValue: MacOS Error ID = %d", err );
}


-(AXUIElementRef)   uiElementRef
{
    return theUIElement;
}


-(NSString*)    description
{
    return [(NSString*) CFCopyDescription(theUIElement) autorelease];
}


@end


@implementation UKUINotificationCenter

-(id)   initWithPID: (pid_t)thepid
{
    if( (self = [super init]) )
    {
        if( kAXErrorSuccess != AXObserverCreate( thepid, UKUIObserverCallback, &theObserver ) )
        {
            [self autorelease];
            return nil;
        }
    }
    
    return self;
}


-(void) addObserver: (id)object selector: (SEL)sel name: (NSString*)nm object: (UKUIElement*)ele
{
    AXObserverAddNotification( theObserver, [ele uiElementRef], (CFStringRef) nm, object );
}


-(void) removeObserver: (id)object name: (NSString*)nm object: (UKUIElement*)ele
{
    AXObserverRemoveNotification( theObserver, [ele uiElementRef], (CFStringRef) nm );
}

-(void) removeObserver: (id)object
{
    
}

@end

void    UKUIObserverCallback( AXObserverRef observer, AXUIElementRef element, CFStringRef notification, void *refcon )
{
    id      obj = (id)refcon;
    
    [obj accessibilityNotification];
}