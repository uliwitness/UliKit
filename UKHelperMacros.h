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
												NSObject* __UKHELPERMACRO_OLDTARG = (NSObject*)(targ);\
												(targ) = [(newval) retain];\
												[__UKHELPERMACRO_OLDTARG release];\
											} while(0)
											
#define DESTROY(targ)						do {\
												NSObject* __UKHELPERMACRO_OLDTARG = (NSObject*)(targ);\
												(targ) = nil;\
												[__UKHELPERMACRO_OLDTARG release];\
											} while(0)

//	The following macro is for specifying property (ivar) names to KVC or KVO methods.
//	These methods generally take strings, but strings don't get checked for typos
//	by the compiler. If you write PROPERTY(fremen) instead of PROPERTY(frame),
//	the compiler will immediately complain that it doesn't know the selector
//	'fremen', and thus point out the typo. For this to work, you need to make
//	sure the warning -Wunknown-selector is on.
//
//	The code that checks here is (theoretically) slower than just using a string
//	literal, so what we do is we only do the checking in debug builds. In
//	release builds, we use the identifier-stringification-operator "#" to turn
//	the given property name into an ObjC string literal.

#if DEBUG
#define PROPERTY(propName)	NSStringFromSelector(@selector(propName))
#else
#define PROPERTY(propName)	@#propName
#endif
