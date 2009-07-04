//
//  NSWorkspace+TypeOfVolumeAtPath.h
//  MovieTheatre
//
//  Created by Uli Kusterer on 12.06.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// Possible return values for typeOfVolumeAtPath:, and values for param of mountedMediaOfType:
#define UKVolumeDVDMediaType            @"IODVDMedia"
#define UKVolumeCDMediaType             @"IOCDMedia"
#define UKVolumeUnknownMediaType        @"IOMedia"


@interface NSWorkspace (TypeOfVolumeAtPath)

-(NSArray*)     mountedMediaOfType: (NSString*)mediaType;

-(NSString*)    typeOfVolumeAtPath: (NSString*)path;

@end
