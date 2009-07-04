//
//  NSDictionary+LocalizedObjectForKey.h
//  Shovel
//
//  Created by Uli Kusterer on Tue Sep 07 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

/*
	Category on NSDictionary that allows looking up different entries depending
	on the preferred language. Only useful if your user data may contain data
	tagged with ISO language codes and you want to know which one is the
	preferred one. If you've localized your app, you should just use
	NSLocalizedString() and specify the different keys in the .strings file
	instead.
*/

#import <Foundation/Foundation.h>


@interface NSDictionary (UKLocalizedObjectForKey)

-(id)			localizedObjectForKey: (NSString*)key;	///< Takes the dictionary at key in this dictionary and returns the object at the former's preferredLocalizedKey.
-(id)			localizedObject;						///< Returns the object at the preferredLocalizedKey of this object.
-(NSString*)	preferredLocalizedKey;					///< Assumes all keys in this dictionary are ISO language codes and returns the key that is closest to the top in the system's list of preferred languages.

// These are analogous to the above, but composed keys are not in a dictionary in the entry, but rather are in the containing dictionary with the same key and the language code appended. E.g. "foo.de", "foo.en" etc.
-(id)			localizedObjectForComposedKey: (NSString*)key;
-(NSString*)	preferredLocalizedComposedKeyForKey: (NSString*)key;
-(NSArray*)		availableComposedKeysForKey: (NSString*)key;

@end


@interface NSString (UKLocalizedObjectForKey)

-(NSString*)	stringByDecomposingComposedKey;
-(NSString*)	stringByGeneratingComposedKeyForKey: (NSString*)key;

@end
