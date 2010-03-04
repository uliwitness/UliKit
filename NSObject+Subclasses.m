//
//  NSObject+Subclasses.m
//  AngelTemplate
//
//  Created by Uli Kusterer on 18.01.05.
//  Copyright 2005 M. Uli Kusterer.
//  Based on a CocoaDev.com posting by Neil A. Van Note.
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

#import "NSObject+Subclasses.h"
#import <objc/objc-runtime.h>

@implementation NSObject (UKSubclasses)

+(NSArray*)    subclasses
{
    NSMutableArray    *tempArray;
    NSArray           *resultArray;
    Class             *classes;
    struct objc_class *superClass;
    Class             *current;
    int                count, newCount, index;

    tempArray   = [[NSMutableArray allocWithZone:nil] initWithCapacity:12];
    resultArray = nil;

    if (tempArray)
    {
        classes = NULL;
        count   = objc_getClassList(NULL, 0);
        if (count)
        {
            classes = malloc(sizeof(Class) * count);
            if (classes)
            {
                newCount = objc_getClassList(classes, count);
                while (count < newCount)
                {
                    count = newCount;
                    free(classes);
                    classes = malloc(sizeof(Class) * count);
                    if (classes)
                        newCount = objc_getClassList(classes, count);
                }
                count = newCount;
            }
        }

        if (classes)
        {
            const Class thisClass = [self class];
            current = classes;

            for (index = 0; index < count; ++index)
            {
                superClass = (*current)->super_class;
                if (superClass)
                {
                    do
                    {
                        if (superClass == thisClass)
                        {
                            [tempArray addObject:*current];
                            break;
                        }
                        superClass = superClass->super_class;
                    } while (superClass);
                }

                ++current;
            }

            free(classes);
        }

        resultArray = [NSArray arrayWithArray:tempArray];
        [tempArray release];
    }

    return resultArray;
}

+(NSArray*)     directSubclasses
{
    NSMutableArray *tempArray;
    NSArray        *resultArray;
    Class          *classes;
    Class          *current;
    int             count, newCount, index;

    tempArray   = [[NSMutableArray allocWithZone:nil] initWithCapacity:12];
    resultArray = nil;

    if (tempArray)
    {
        classes = NULL;
        count   = objc_getClassList(NULL, 0);
        if (count)
        {
            classes = malloc(sizeof(Class) * count);
            if (classes)
            {
                newCount = objc_getClassList(classes, count);
                while (count < newCount)
                {
                    count = newCount;
                    free(classes);
                    classes = malloc(sizeof(Class) * count);
                    if (classes)
                        newCount = objc_getClassList(classes, count);
                }
                count = newCount;
            }
        }

        if (classes)
        {
            const Class thisClass = [self class];
            current = classes;

            for (index = 0; index < count; ++index)
            {
                if ((*current)->super_class == thisClass)
                    [tempArray addObject:*current];
                ++current;
            }

            free(classes);
        }

        resultArray = [NSArray arrayWithArray:tempArray];
        [tempArray release];
    }

    return resultArray;
}


+(NSEnumerator*)    subclassEnumerator
{
    return [[self subclasses] objectEnumerator];
}


+(NSEnumerator*)    directSubclassEnumerator
{
    return [[self directSubclasses] objectEnumerator];
}

@end
