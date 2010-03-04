//
//  RemoveLoginItem.c
//  UlisMoose X
//
//  Created by Uli Kusterer on Sun Jun 29 2003.
//  Copyright (c) 2003 Uli Kusterer.
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