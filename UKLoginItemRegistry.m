//
//  UKLoginItemRegistry.m
//  TalkingMoose (XC2)
//
//  Created by Uli Kusterer on 14.03.06.
//  Copyright 2006 Uli Kusterer.
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


#import "UKLoginItemRegistry.h"


@implementation UKLoginItemRegistry

+(NSArray*)	allLoginItems
{
	NSArray*	itemsList = nil;
	OSStatus	err = LIAECopyLoginItems( (CFArrayRef*) &itemsList );	// Take advantage of toll-free bridging.
	if( err != noErr )
	{
		UKLog(@"Couldn't list login items error %ld", err);
		return nil;
	}
	
	return [itemsList autorelease];
}

+(BOOL)		addLoginItemWithURL: (NSURL*)url hideIt: (BOOL)hide			// Main bottleneck for adding a login item.
{
	OSStatus err = LIAEAddURLAtEnd( (CFURLRef) url, hide );	// CFURLRef is toll-free bridged to NSURL.
	
	if( err != noErr )
		UKLog(@"Couldn't add login item error %ld", err);
	
	return( err == noErr );
}


+(BOOL)		removeLoginItemAtIndex: (int)idx			// Main bottleneck for getting rid of a login item.
{
	OSStatus err = LIAERemove( idx );
	
	if( err != noErr )
		UKLog(@"Couldn't remove login item error %ld", err);
	
	return( err == noErr );
}


+(int)		indexForLoginItemWithURL: (NSURL*)url		// Main bottleneck for finding a login item in the list.
{
	NSArray*		loginItems = [self allLoginItems];
	NSEnumerator*	enny = [loginItems objectEnumerator];
	NSDictionary*	currLoginItem = nil;
	int				x = 0;
	
	while(( currLoginItem = [enny nextObject] ))
	{
		if( [[currLoginItem objectForKey: UKLoginItemURL] isEqualTo: url] )
			return x;
		
		x++;
	}
	
	return -1;
}

+(int)		indexForLoginItemWithPath: (NSString*)path
{
	NSURL*	url = [NSURL fileURLWithPath: path];
	
	return [self indexForLoginItemWithURL: url];
}

+(BOOL)		addLoginItemWithPath: (NSString*)path hideIt: (BOOL)hide
{
	NSURL*	url = [NSURL fileURLWithPath: path];
	
	return [self addLoginItemWithURL: url hideIt: hide];
}


+(BOOL)		removeLoginItemWithPath: (NSString*)path
{
	int		idx = [self indexForLoginItemWithPath: path];
	
	return (idx != -1) && [self removeLoginItemAtIndex: idx];	// Found item? Remove it and return success flag. Else return NO.
}


+(BOOL)		removeLoginItemWithURL: (NSURL*)url
{
	int		idx = [self indexForLoginItemWithURL: url];
	
	return (idx != -1) && [self removeLoginItemAtIndex: idx];	// Found item? Remove it and return success flag. Else return NO.
}

@end
