//
//  NSDictionary+LocalizedObjectForKey.m
//  Shovel
//
//  Created by Uli Kusterer on Tue Sep 07 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import "NSDictionary+LocalizedObjectForKey.h"


@implementation NSDictionary (UKLocalizedObjectForKey)

// -----------------------------------------------------------------------------
//  localizedObjectForKey:
///		Returns an entry from a sub-dictionary in this dictionary. The sub-
///		dictionary is assumed to contain a list of localized entries, where
///		the key for each entry is the ISO two-character language code.
///		This will try to fetch the entry for the current language from the sub-
///		dictionary, or if that isn't present, will try other languages according
///		to the user's preferred languages list as set in System Preferences.
///		If none of these is present, it will fall back on various other English
///		variants, or failing that, will simply return the first one.
// -----------------------------------------------------------------------------

-(id)   localizedObjectForKey: (NSString*)key
{
	NSDictionary*   localizedEntry = [self objectForKey: key];
	
	// If this isn't a localizable entry, i.e. there's no dictionary at that key, we behave just like objectForKey:
	if( ![localizedEntry isKindOfClass: [NSDictionary class]] )
		return localizedEntry;
	else
		return [localizedEntry localizedObject];
}

-(id)   localizedObject
{
	NSDictionary*   globalDomain = [[NSUserDefaults standardUserDefaults] persistentDomainForName: NSGlobalDomain];
	NSArray*		preferredLocalizations = [globalDomain objectForKey: @"AppleLanguages"];
	NSEnumerator*   enny = [preferredLocalizations objectEnumerator];
	NSString*		currLang;
	id				obj;
	
	while( (currLang = [enny nextObject]) )
	{
		if( (obj = [self objectForKey: currLang]) != nil )
			return obj;
	}
	
	obj = [self objectForKey: @"en"];
	if( !obj )
		obj = [self objectForKey: @"en_US"];
	if( !obj )
		obj = [self objectForKey: @"en_GB"];
	if( !obj )
		obj = [self objectForKey: [[self allKeys] objectAtIndex:0]];
	
	return obj;
}






-(NSString*)   preferredLocalizedKey
{
	NSDictionary*   globalDomain = [[NSUserDefaults standardUserDefaults] persistentDomainForName: NSGlobalDomain];
	NSArray*		preferredLocalizations = [globalDomain objectForKey: @"AppleLanguages"];
	NSEnumerator*   enny = [preferredLocalizations objectEnumerator];
	NSString*		currLang;
	NSString*		obj;
	
	while( (currLang = [enny nextObject]) )
	{
		if( (obj = [self objectForKey: currLang]) != nil )
			return currLang;
	}
	
	if( [self objectForKey: @"en"] )
		return @"en";
	if( [self objectForKey: @"en_US"] )
		return @"en_US";
	if( [self objectForKey: @"en_US"] )
		return @"en_GB";
	
	return [[self allKeys] objectAtIndex:0];
}


// -----------------------------------------------------------------------------
//  Same as localizedObjectForKey, but instead of assuming there's a dictionary
//	inside the dictionary, it simply assumes that translations are in the same
//	dictionary and simply have the ISO language code appended to the key. E.g.
//	"myKey.de", "myKey.us" etc.
// -----------------------------------------------------------------------------

-(id)   localizedObjectForComposedKey: (NSString*)key
{
	NSDictionary*   globalDomain = [[NSUserDefaults standardUserDefaults] persistentDomainForName: NSGlobalDomain];
	NSArray*		preferredLocalizations = [globalDomain objectForKey: @"AppleLanguages"];
	NSEnumerator*   enny = [preferredLocalizations objectEnumerator];
	NSString*		currLang;
	id				obj = nil;
	
	while( (currLang = [enny nextObject]) )
	{
		if( (obj = [self objectForKey: [key stringByAppendingFormat: @".%@", currLang]]) != nil )
			return obj;
		else if( [currLang isEqualToString: @"en"]		// "en" can also be ...
				&& (obj = [self objectForKey: key]) )	// ... expressed by "no key".
			return obj;
	}
	
	obj = [self objectForKey: [key stringByAppendingString: @".en"]];
	if( !obj )
		obj = [self objectForKey: [key stringByAppendingString: @".en_US"]];
	if( !obj )
		obj = [self objectForKey: [key stringByAppendingString: @".en_GB"]];
	if( !obj )
		obj = [self objectForKey: key];	// One last try before the user gets NIL.
	
	return obj;
}



-(NSString*)   preferredLocalizedComposedKeyForKey: (NSString*)key
{
	NSDictionary*   globalDomain = [[NSUserDefaults standardUserDefaults] persistentDomainForName: NSGlobalDomain];
	NSArray*		preferredLocalizations = [globalDomain objectForKey: @"AppleLanguages"];
	NSEnumerator*   enny = [preferredLocalizations objectEnumerator];
	NSString*		currLang;
	NSString*		currKey;
	id				obj = nil;
	
	while( (currLang = [enny nextObject]) )
	{
		currKey = [key stringByAppendingFormat: @".%@", currLang];
		if( (obj = [self objectForKey: currKey]) != nil )
			return currKey;
		else if( [currLang isEqualToString: @"en"]
			&& (obj = [self objectForKey: key]) )	// "en" can also be ...
			return key;								// ... expressed by "no key".
	}
	
	currKey = [key stringByAppendingString: @".en"];
	if( (obj = [self objectForKey: currKey]) != nil )
		return currKey;
	currKey = [key stringByAppendingString: @".en_US"];
	if( (obj = [self objectForKey: currKey]) != nil )
		return currKey;
	currKey = [key stringByAppendingString: @".en_GB"];
	if( (obj = [self objectForKey: currKey]) != nil )
		return currKey;
	
	return key;
}


-(NSArray*)	availableComposedKeysForKey: (NSString*)key
{
	NSEnumerator*	enny = [self keyEnumerator];
	NSMutableArray*	list = [NSMutableArray array];
	NSString*		currKey = nil;
	NSString*		keyWithPeriod = [key stringByAppendingString: @"."];
	
	while( (currKey = [enny nextObject]) )
	{
		if( [currKey hasPrefix: keyWithPeriod]
			|| [currKey isEqualToString: key])
			[list addObject: currKey];
	}
	
	return list;
}

@end


@implementation NSString (UKLocalizedObjectForKey)

-(NSString*)	stringByDecomposingComposedKey
{
	NSString*	langCode = @"en";
	NSRange		range = [self rangeOfString: @"." options: NSBackwardsSearch];
	if( range.location != NSNotFound )
		langCode = [self substringFromIndex: (range.location +range.length)];
	
	return langCode;
}

-(NSString*)	stringByGeneratingComposedKeyForKey: (NSString*)key
{
	if( [self isEqualToString: @"en"] )
		return key;
	else
		return [key stringByAppendingFormat: @".%@", self];
}

@end