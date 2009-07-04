//
//  NSObject+Subclasses.h
//  AngelTemplate
//
//  Created by Uli Kusterer on 18.01.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//  Based on a CocoaDev.com posting by Neil A. Van Note.
//

#import <Foundation/Foundation.h>


@interface NSObject (UKSubclasses)

+(NSArray*)         subclasses;
+(NSArray*)         directSubclasses;

+(NSEnumerator*)    subclassEnumerator;
+(NSEnumerator*)    directSubclassEnumerator;

@end
