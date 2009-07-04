//
//  UKPathUtilities.h
//  Shovel
//
//  Created by Uli Kusterer on Thu Mar 25 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
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
