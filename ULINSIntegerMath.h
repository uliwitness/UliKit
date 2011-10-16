//
//  ULINSIntegerMath.h
//  Stacksmith
//
//  Created by Uli Kusterer on 16.10.11.
//  Copyright (c) 2011 Uli Kusterer. All rights reserved.
//

#ifndef Stacksmith_ULINSIntegerMath_h
#define Stacksmith_ULINSIntegerMath_h

#include <Foundation/Foundation.h>

#if __cplusplus
extern "C" {
#endif

static inline NSInteger ULINSIntegerMinimum( NSInteger a, NSInteger b );	
	
static inline NSInteger ULINSIntegerMinimum( NSInteger a, NSInteger b )
{
	return ((a < b) ? a : b);
}


static inline NSInteger ULINSIntegerMaximum( NSInteger a, NSInteger b );

static inline NSInteger ULINSIntegerMaximum( NSInteger a, NSInteger b )
{
	return ((a > b) ? a : b);
}

#if __cplusplus
}
#endif

#endif
