//
//  UKHelperMacros.h
//
//  Created by Uli Kusterer on 09.08.07.
//  Copyright 2007-2014 Uli Kusterer.
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
	You'd generally #import this file in your project's prefix header.
*/

//
//	Use UKLog() instead of NSLog() to output debug-only messages that you don't
//	want in release builds. You'll have to add DEBUG=1 to the preprocessor macros
//	in your target's compiler settings for the Development build configuration.
//
//	This prefixes the method or function name to the message.
//

#ifndef UKLog
#if DEBUG
#define	UKLog(args...)			NSLog( @"%s: %@", __PRETTY_FUNCTION__, [NSString stringWithFormat: args])
#else
#define	UKLog(args...)			while(0) // stubbed out
#endif
#endif	// UKLog


// A pointer value that is guaranteed to cause a crash when a message is sent to it.
//	Handy for assigning to instance variables in dealloc to catch talking to released objects.
#if __LP64__
#define	UKInvalidPointer		((id)0x5555555555555555)
#else
#define	UKInvalidPointer		((id)0x55555555)
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

#ifndef ASSIGN	// SenTest declares its own macro of this name.
// ASSIGN(ivar,val)
//	Releases the current value in ivar and assigns val to it, retaining it. Doesn't release
//	ivar's value until the new value has been assigned.
#define ASSIGN(targ,newval)					do {\
												NSObject* __UKHELPERMACRO_OLDTARG = (NSObject*)(targ);\
												(targ) = [(newval) retain];\
												[__UKHELPERMACRO_OLDTARG release];\
											} while(0)
#endif // !defined(ASSIGN)

// ASSIGNMUTABLECOPY(ivar,val)
//	Releases the current value in ivar and assigns [val mutableCopy] to it. Doesn't release
//	ivar's value until the new value has been assigned.
#define ASSIGNMUTABLECOPY(targ,newval)		do {\
												NSObject* __UKHELPERMACRO_OLDTARG = (NSObject*)(targ);\
												(targ) = [(newval) mutableCopy];\
												[__UKHELPERMACRO_OLDTARG release];\
											} while(0)
// ASSIGNCOPY(ivar,val)
//	Releases the current value in ivar and assigns [val copy] to it. Doesn't release
//	ivar's value until the new value has been assigned.
#define ASSIGNCOPY(targ,newval)				do {\
												NSObject* __UKHELPERMACRO_OLDTARG = (NSObject*)(targ);\
												(targ) = [(newval) copy];\
												[__UKHELPERMACRO_OLDTARG release];\
											} while(0)

// DESTROY(ivar)
//	Releases the variable 'ivar' and sets its value to NIL even *before* the release.
#define DESTROY(targ)						do {\
												NSObject* __UKHELPERMACRO_OLDTARG = (NSObject*)(targ);\
												(targ) = nil;\
												[__UKHELPERMACRO_OLDTARG release];\
											} while(0)
// DESTROY_DEALLOC(ivar)
//	Releases the variable 'ivar' and sets its value to UKInvalidPointer even *before* the release.
#define DESTROY_DEALLOC(targ)				do {\
												NSObject* __UKHELPERMACRO_OLDTARG = (NSObject*)(targ);\
												(targ) = UKInvalidPointer;\
												[__UKHELPERMACRO_OLDTARG release];\
											} while(0)

// PROPERTY(propertyName) --> @"propertyName"
//	The following macro is for specifying property (ivar) names to KVC or KVO methods.
//	These methods generally take strings, but strings don't get checked for typos
//	by the compiler. If you write PROPERTY(fremen) instead of PROPERTY(frame),
//	the compiler will immediately complain that it doesn't know the selector
//	'fremen', and thus point out the typo. For this to work, you need to make
//	sure the warning -Wunknown-selector is on.
//
//	Thanks to the NO ? trick goes to Rob Rix. This means that the NSStringFromSelector()
//	is compiled (and causes errors with invalid selectors) but is never used at runtime
//	(so performance of debug and non-debug builds stays identical).

#if DEBUG
#define PROPERTY(propName)	(YES ? @ # propName : NSStringFromSelector(@selector(propName)))
#else
#define PROPERTY(propName)	@#propName
#endif


// KEYPATH(obj,key.path.on.object) --> @"key.path.on.object"
//	The following macro is like PROPERTY, but for entire key paths. Thanks to
//	Rob Rix for donating this. The else case essentially returns NIL cast to NSString*,
//	but in the process of determining the type happens to validate our path as a side effect.
//	Since the else case is unreachable, this has the same runtime effect as specifying a string
//	constant, but it is type-checked.
//	You only pass in 'obj' to allow determining the type. It doesn't actually call anything.

#if DEBUG
#define KEYPATH(OBJ, PATH) (YES ? @ # PATH : (__typeof__(^ NSString * { (void)((__typeof__(OBJ))nil).PATH; return nil; }())) nil)
#else
#define KEYPATH(OBJ, PATH) (@ # PATH)
#endif
