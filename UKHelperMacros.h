//
//  UKHelperMacros.h
//
//  Created by Uli Kusterer on 09.08.07.
//  Copyright 2007 M. Uli Kusterer. All rights reserved.
//	
//	Use, modify and distribute freely, as long as you mark modified versions as
//	having been modified. I don't like getting bug reports for code I did not
//	write.

//	DIRECTIONS:
//		You'd generally #import this file in your project's prefix header.

//
//	Use UKLog() instead of NSLog() to output debug-only messages that you don't
//	want in release builds. You'll have to add DEBUG=1 to the preprocessor macros
//	in your target's compiler settings for the Development build configuration.
//
//	This prefixes the method or function name to the message.
//

#if DEBUG
#define	UKLog(args...)			NSLog( @"%s: %@", __PRETTY_FUNCTION__, [NSString stringWithFormat: args])
#else
#define	UKLog(args...)			// stubbed out
#endif


//	The following use the same syntax as the ones in GNUstep. Just cuz that's
//	the closest we have to a standard for stuff like this.
//
//	Create a pool around some code by doing:
//		CREATE_AUTORELEASE_POOL(myPool);
//			// Use the pool.
//		DESTROY(myPool);
//
//	ASSIGN() is a neat macro to use inside mutators, DESTROY() is a shorthand
//	that lets you release an object and clear its variable in one go.
//
//	The do/while(0) stuff is just there so the macro behaves just like any other
//	function call, as far as if/else etc. are concerned.

#define CREATE_AUTORELEASE_POOL(pool)		NSAutoreleasePool*	(pool) = [[NSAutoreleasePool alloc] init]

#define ASSIGN(targ,newval)					do {\
												id __UKHELPERMACRO_OLDTARG = (id)(targ);\
												(targ) = [(newval) retain];\
												[__UKHELPERMACRO_OLDTARG release];\
											} while(0)
											
#define DESTROY(obj)						do {\
												[obj release];\
												obj = nil;\
											} while(0)
