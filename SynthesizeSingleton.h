//
//  SynthesizeSingleton.h
//
//  Created by Matt Gallagher on 20/10/08.
//	Copyright 2008 Matt Gallagher.
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

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
 \
static classname *shared##classname = nil; \
 \
+ (classname *)shared##classname \
{ \
	@synchronized(self) \
	{ \
		if (shared##classname == nil) \
		{ \
			[[self alloc] init]; \
		} \
	} \
	 \
	return shared##classname; \
} \
 \
+ (id)allocWithZone:(NSZone *)zone \
{ \
	@synchronized(self) \
	{ \
		if (shared##classname == nil) \
		{ \
			shared##classname = [super allocWithZone:zone]; \
			return shared##classname; \
		} \
	} \
	 \
	return nil; \
} \
 \
- (id)copyWithZone:(NSZone *)zone \
{ \
	return self; \
} \
 \
- (id)retain \
{ \
	return self; \
} \
 \
- (NSUInteger)retainCount \
{ \
	return NSUIntegerMax; \
} \
 \
- (void)release \
{ \
} \
 \
- (id)autorelease \
{ \
	return self; \
}
