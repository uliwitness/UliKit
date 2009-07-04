/*
 *  RemoveLoginItem.h
 *  UlisMoose X
 *
 *  Created by Uli Kusterer on Sun Jun 29 2003.
 *  Copyright (c) 2003 M. Uli Kusterer. All rights reserved.
 *
 */

#include "LoginItemAPI.h"
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif


int		RemoveLoginItem( CFStringRef whosePreferencesToChange, const char* pathName );
int		GetLoginItemIndex( CFStringRef whosePreferencesToChange, const char* pathName );


#ifdef __cplusplus
}
#endif

