//
//  UKPathUtilities.m
//  Shovel
//
//  Created by Uli Kusterer on Thu Mar 25 2004.
//  Copyright (c) 2004 Uli Kusterer.
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

#import "UKPathUtilities.h"
#import "NSString+CarbonUtilities.h"


NSString*	UKDownloadDirectory()
{
	ICInstance		inst = NULL;
	ICFileSpec		fSpec;
	long			length = kICFileSpecHeaderSize;
	FSRef			fref;
	unsigned char	fpath[PATH_MAX] = { 0 };

	if( ICStart( &inst, 0L ) != noErr )
		goto cleanup;

	ICGetPref( inst, kICDownloadFolder, NULL, &fSpec, &length );
	ICStop( inst );

	if( FSpMakeFSRef( &fSpec.fss, &fref ) != noErr )
		goto cleanup;

	if( FSRefMakePath( &fref, fpath, 1024 ) != noErr )
		goto cleanup;

cleanup:
	if( fpath[0] == 0 )
		return [@"~/Desktop" stringByExpandingTildeInPath];

	return [NSString stringWithUTF8String: (const char*) fpath];
}


NSArray*    UKApplicationSupportDirectory( BOOL create )
{
    return UKFindFolder( kApplicationSupportFolderType, create );
}


NSArray*    UKSingleUserTrashDirectory( BOOL create )
{
    return UKFindFolder( kTrashFolderType, create );
}


NSArray*    UKDesktopDirectory( BOOL create )
{
    return UKFindFolder( kDesktopFolderType, create );
}


NSArray*    UKFontsDirectory( BOOL create )
{
    return UKFindFolder( kFontsFolderType, create );
}


NSArray*    UKPreferencesDirectory( BOOL create )
{
    return UKFindFolder( kPreferencesFolderType, create );
}


NSArray*    UKTrashedTemporaryDirectory( BOOL create )
{
    return UKFindFolder( kTemporaryFolderType, create );
}


NSArray*    UKTrashingTemporaryDirectory( BOOL create )
{
    return UKFindFolder( kTemporaryFolderType, create );
}


NSArray*    UKDeletingTemporaryDirectory( BOOL create )
{
    return UKFindFolder( kChewableItemsFolderType, create );
}


NSArray*    UKApplicationsDirectory( BOOL create )
{
    return UKFindFolder( kApplicationsFolderType, create );
}


NSArray*    UKDocumentsDirectory( BOOL create )
{
    return UKFindFolder( kDocumentsFolderType, create );
}


NSArray*    UKInternetPlugInDirectory( BOOL create )
{
    return UKFindFolder( kInternetPlugInFolderType, create );
}


NSArray*    UKUtilitiesDirectory( BOOL create )
{
    return UKFindFolder( kUtilitiesFolderType, create );
}


NSArray*    UKContextualMenuItemsDirectory( BOOL create )
{
    return UKFindFolder( kContextualMenuItemsFolderType, create );
}


NSArray*    UKFavoritesDirectory( BOOL create )
{
    return UKFindFolder( kFavoritesFolderType, create );
}


NSArray*    UKInstallerLogsDirectory( BOOL create )
{
    return UKFindFolder( kInstallerLogsFolderType, create );
}


NSArray*    UKFindFolder( OSType folderType, BOOL create )
{
    int                 domains[4] = { kUserDomain, kLocalDomain,
                                        kNetworkDomain, kSystemDomain };
    int                 x;
    FSRef               currRef;
    NSMutableArray*     paths = [NSMutableArray array];
    
    for( x = 0; x < 4; x++ )
    {
        if( FSFindFolder( domains[x], folderType,
                        (create == YES), &currRef ) == noErr )
            [paths addObject: [NSString stringWithFSRef: &currRef]];
   }
   
   return paths;
}