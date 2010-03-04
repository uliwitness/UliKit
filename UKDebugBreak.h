//
//  UKDebugBreak.h
//  AngelDatabase
//
//  Created by Uli Kusterer on 18.10.08.
//  Copyright 2008 Uli Kusterer.
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

#ifndef UK_DEBUG_BREAK_H
#define	UK_DEBUG_BREAK_H	1

// UKDebugBreak()
//	Macro that breaks into the debugger, if a debugger is attached.
//	Macros by Matt Gallagher, from his Cocoa With Love blog, released into the
//	public domain.

#ifdef DEBUG
    #if __ppc64__ || __ppc__
        #define UKDebugBreak() \
            if(UKAmIBeingDebugged()) \
            { \
                __asm__("li r0, 20\nsc\nnop\nli r0, 37\nli r4, 2\nsc\nnop\n" \
                    : : : "memory","r0","r3","r4" ); \
            }
    #else
        #define UKDebugBreak() if(UKAmIBeingDebugged()) {__asm__("int $3\n" : : );}
    #endif

    int	UKAmIBeingDebugged(void);	// Returns a boolean.
#else
    #define UKDebugBreak()
#endif

#endif