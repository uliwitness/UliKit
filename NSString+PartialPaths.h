//
//  NSString+PathCombiningExtensions.h
//  VerpackIt
//
//  Created by Uli Kusterer on 18.09.04.
//  Copyright 2004 Uli Kusterer.
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


@interface NSString (UKPartialPaths)

-(NSString*)	stringByCombiningWithPartialPath: (NSString*)inPartial;
-(NSString*)	stringBySubtractingBasePath: (NSString*)basePath;

-(int)			upwardsDepth;

@end

@interface NSArray (UKPartialPaths)

// If any entry in an array of paths contains "../" 'go-up entries', this returns how many there are.
// Use this to find out how many folders you have to create around this one not to run out of paths.
-(int)			maxUpwardsDepth;	// Calls upwardsDepth on each path and returns the maximum.

@end