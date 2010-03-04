//
//  NSWorkspace+TypeOfVolumeAtPath.m
//  MovieTheatre
//
//  Created by Uli Kusterer on 12.06.05.
//  Copyright 2005 M. Uli Kusterer.
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

#import "NSWorkspace+TypeOfVolumeAtPath.h"
#import "NSString+CarbonUtilities.h"
#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/storage/IOMedia.h>
#include <IOKit/storage/IOCDMedia.h>
#include <IOKit/storage/IODVDMedia.h>
#include <IOKit/storage/IOStorageDeviceCharacteristics.h>
#include <IOKit/usb/IOUSBLib.h>



NSString* IsWholeMedia(io_service_t service)
{
    //
    // Determine if the object passed in represents an IOMedia (or subclass) object.
    // If it does, retrieve the "Whole" property.
    // If this is the whole media object, find out if it is a CD, DVD, or something else.
    // If it isn't the whole media object, iterate across its parents in the IORegistry
    // until the whole media object is found.
    //
    // Note that media types other than CD and DVD are not distinguished by class name
    // but are generic IOMedia objects.
    //
    
    NSString*       mediaType = nil;
    Boolean 		isWholeMedia = false;
    io_name_t		className;
    kern_return_t	kernResult;

    if (IOObjectConformsTo(service, kIOMediaClass)) {
        
        CFTypeRef wholeMedia;
        
        // Find out whether it's a whole media:
        wholeMedia = IORegistryEntryCreateCFProperty(service, 
                                                     CFSTR(kIOMediaWholeKey), 
                                                     kCFAllocatorDefault, 
                                                     0);
                                                    
        if (NULL == wholeMedia) {
            printf("Could not retrieve Whole property\n");
        }
        else {                                        
            isWholeMedia = CFBooleanGetValue(wholeMedia);
            CFRelease(wholeMedia);
        }
    }
            
    if (isWholeMedia)
    {
        kernResult = IOObjectGetClass(service, className);
        mediaType = [NSString stringWithUTF8String: className];
    }

    return mediaType;
}

NSString* FindWholeMedia(io_service_t service)
{
    kern_return_t	kernResult;
    io_iterator_t	iter;
    NSString*       mediaType = nil;
    
    // Create an iterator across all parents of the service object passed in.
    kernResult = IORegistryEntryCreateIterator(service,
                                               kIOServicePlane,
                                               kIORegistryIterateRecursively | kIORegistryIterateParents,
                                               &iter);
    
    if (KERN_SUCCESS != kernResult) {
        printf("IORegistryEntryCreateIterator returned %d\n", kernResult);
    }
    else if (NULL == iter) {
        printf("IORegistryEntryCreateIterator returned a NULL iterator\n");
    }
    else {
        // A reference on the initial service object is released in the do-while loop below,
        // so add a reference to balance 
        IOObjectRetain(service);	
        
        do {
            mediaType = IsWholeMedia(service);
            IOObjectRelease(service);
        } while ((service = IOIteratorNext(iter)) && !mediaType);
                
        IOObjectRelease(iter);
    }
    
    return mediaType;
}


@implementation NSWorkspace (TypeOfVolumeAtPath)

-(NSArray*)     mountedMediaOfType: (NSString*)mediaType
{
    NSEnumerator*   enny = [[self mountedRemovableMedia] objectEnumerator];
    NSString*       path = nil;
    NSMutableArray* result = [NSMutableArray array];
    
    while( (path = [enny nextObject]) )
    {
        if( [[self typeOfVolumeAtPath: path] isEqualToString: mediaType] )
            [result addObject: path];
    }
    
    return result;
}

-(NSString*)    typeOfVolumeAtPath: (NSString*)path
{
    OSStatus                err;
    FSRef                   fileRef;
    FSCatalogInfo           catInfo;
    GetVolParmsInfoBuffer   volumeParms;
    HParamBlockRec          pb;
    kern_return_t           kernResult; 
    
    if( ![path getFSRef: &fileRef] )
        NSLog( @"Couldn't get FSRef" );
    
    err = FSGetCatalogInfo( &fileRef, kFSCatInfoVolume, &catInfo, NULL, NULL, NULL );
    if( err != noErr )
        NSLog( @"FSGetCatalogInfo returned %ld", err );

    // Use the volume reference number to retrieve the volume parameters. See the documentation
    // on PBHGetVolParmsSync for other possible ways to specify a volume.
    pb.ioParam.ioNamePtr = NULL;
    pb.ioParam.ioVRefNum = catInfo.volume;
    pb.ioParam.ioBuffer = (Ptr) &volumeParms;
    pb.ioParam.ioReqCount = sizeof(volumeParms);
    
    // A version 4 GetVolParmsInfoBuffer contains the BSD node name in the vMDeviceID field.
    // It is actually a char * value. This is mentioned in the header CoreServices/CarbonCore/Files.h.
    err = PBHGetVolParmsSync( &pb );
    if( err != noErr )
        NSLog( @"PBHGetVolParmsSync returned %ld", err );
    
    char *bsdName = (char *) volumeParms.vMDeviceID;
    CFMutableDictionaryRef	matchingDict;
    io_iterator_t           iter;
    io_service_t            service;
    NSString*               mediaType = nil;
	io_name_t				theName;
    
    static mach_port_t	gMasterPort = 0;
    if( gMasterPort == 0 )
    {
        kernResult = IOMasterPort(MACH_PORT_NULL, &gMasterPort);
        if (KERN_SUCCESS != kernResult)
            NSLog( @"IOMasterPort returned %d\n", kernResult);
    }
    
	NSLog(@"%s",bsdName);
    matchingDict = IOBSDNameMatching( gMasterPort, 0, bsdName );
    if (NULL == matchingDict) {
        printf("IOBSDNameMatching returned a NULL dictionary.\n");
    }
    else {
        // Return an iterator across all objects with the matching BSD node name. Note that there
        // should only be one match!
        kernResult = IOServiceGetMatchingServices(gMasterPort, matchingDict, &iter);    
    
        if (KERN_SUCCESS != kernResult) {
            printf("IOServiceGetMatchingServices returned %d\n", kernResult);
        }
        else if (NULL == iter) {
            printf("IOServiceGetMatchingServices returned a NULL iterator\n");
        }
        else {
            service = IOIteratorNext(iter);
            
            // Release this now because we only expect the iterator to contain
            // a single io_service_t.
            IOObjectRelease(iter);
            
            if (NULL == service) {
                printf("IOIteratorNext returned NULL\n");
            }
            else {
                mediaType = FindWholeMedia(service);
				NSMutableDictionary* propDict = nil;
				IORegistryEntryCreateCFProperties( service, (CFMutableDictionaryRef*) &propDict, kCFAllocatorDefault, 0 );
				[propDict autorelease];
				NSLog( @"%@",propDict );
                IOObjectRelease(service);
            }
        }
    }
    
    return mediaType;
}

@end
