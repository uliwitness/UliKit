//
//  NSDictionary+LocalizedObjectForKey.h
//  Shovel
//
//  Created by Uli Kusterer on Tue Sep 07 2004.
//  Copyright (c) 2004 M. Uli Kusterer.
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
