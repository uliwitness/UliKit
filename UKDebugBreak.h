/*
 *  UKDebugBreak.h
 *  AngelDatabase
 *
 *  Created by Uli Kusterer on 18.10.08.
 *  Copyright 2008 The Void Software. All rights reserved.
 *
 */

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