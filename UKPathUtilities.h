//
//  UKPathUtilities.h
//  Shovel
//
//  Created by Uli Kusterer on Thu Mar 25 2004.
//  Copyright (c) Uli Kusterer.
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

#import <AppKit/AppKit.h>


// Gives the "download folder" as set up in Internet Config:
NSString*	UKDownloadDirectory();

// Shorthands for various variants of UKFindFolder:
NSArray*    UKApplicationSupportDirectory( BOOL create );
NSArray*    UKDesktopDirectory( BOOL create );
NSArray*    UKSingleUserTrashDirectory( BOOL create );
NSArray*    UKFontsDirectory( BOOL create );
NSArray*    UKPreferencesDirectory( BOOL create );
NSArray*    UKTrashedTemporaryDirectory( BOOL create );
NSArray*    UKTrashingTemporaryDirectory( BOOL create );
NSArray*    UKDeletingTemporaryDirectory( BOOL create );
NSArray*    UKApplicationsDirectory( BOOL create );
NSArray*    UKDocumentsDirectory( BOOL create );
NSArray*    UKInternetPlugInDirectory( BOOL create );
NSArray*    UKUtilitiesDirectory( BOOL create );
NSArray*    UKContextualMenuItemsDirectory( BOOL create );
NSArray*    UKFavoritesDirectory( BOOL create );
NSArray*    UKInstallerLogsDirectory( BOOL create );

// Cocoa version of FindFolder:
//  Returns an array of paths for each domain in preferred search order:
NSArray*    UKFindFolder( OSType folderType, BOOL create );
