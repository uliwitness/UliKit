/*
 *  RemoveLoginItem.c
 *  UlisMoose X
 *
 *  Created by Uli Kusterer on Sun Jun 29 2003.
 *  Copyright (c) 2003 M. Uli Kusterer. All rights reserved.
 *
 */

#include "RemoveLoginItem.h"

#include <string.h>


int		RemoveLoginItem( CFStringRef whosePreferencesToChange, const char* pathName )
{
	int x = GetLoginItemIndex( whosePreferencesToChange, pathName );
	
	if( x == -1 )
		return false;
	
	return RemoveLoginItemAtIndex( whosePreferencesToChange, x );
}


int		GetLoginItemIndex( CFStringRef whosePreferencesToList, const char* pathName )
{
	int		count = GetCountOfLoginItems( whosePreferencesToList ),
			x;
	char*	currItemName;
	
	for( x = 0; x < count; x++ )
	{
		currItemName = ReturnLoginItemPropertyAtIndex( whosePreferencesToList,
														kFullPathInfo,
														x );
		if( currItemName && strcasecmp( currItemName, pathName ) == 0 )
			return x;
	}
	
	return -1;
}