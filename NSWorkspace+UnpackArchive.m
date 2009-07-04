//
//  NSWorkspace+UnpackArchive.m
//  Shovel
//
//  Created by Uli Kusterer on Wed Mar 31 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import "NSWorkspace+UnpackArchive.h"
#import "NSFileManager+NameForTempFile.h"


@implementation NSWorkspace (UKUnpackArchive)

// -----------------------------------------------------------------------------
//	unpackZipArchive:
//		Unpack a Zipped archive. The files are unpacked into the folder that
//		held the archive and then the archive is deleted. Note that this tries
//		to use Apple's resource fork-aware BOMArchiveHelper (10.3 and up) if it
//		is present. Otherwise, it falls back on /usr/bin/unzip, which royally
//		screws up any resource forks.
//
//		Returns the application's exit status.
//
//	REVISIONS:
//		2004-03-21	witness	Moved here from UKShovelAppDelegate.
// -----------------------------------------------------------------------------

-(int)		unpackZipArchive: (NSString*)fpath
{
	NSString*		appPath = @"/System/Library/CoreServices/BOMArchiveHelper.app/Contents/MacOS/BOMArchiveHelper";
	if( ![[NSFileManager defaultManager] fileExistsAtPath: appPath] )
		appPath = @"/usr/bin/unzip";
	NSTask* theTask = [[[NSTask alloc] init] autorelease];
	[theTask setLaunchPath: appPath];
	[theTask setArguments: [NSArray arrayWithObjects: @"-qq", @"-n", fpath, nil]];  // -q means quiet. -n means never replace, which forestalls complaints caused by res fork files.
	[theTask setCurrentDirectoryPath: [fpath stringByDeletingLastPathComponent]];
	[theTask launch];
	[theTask waitUntilExit];
	
	[[NSFileManager defaultManager] removeFileAtPath: fpath handler:nil];
	
	return [theTask terminationStatus];
}


// -----------------------------------------------------------------------------
//	unpackTgzArchive:
//		Unpack a GZipped (and optionally tarred) archive. The files are unpacked
//		into the folder that held the archive and then the archive is deleted.
//
//	REVISIONS:
//		2004-03-21	witness	Moved here from UKShovelAppDelegate.
// -----------------------------------------------------------------------------

-(int)		unpackTgzArchive: (NSString*)fpath
{
	NSTask* theTask = [[[NSTask alloc] init] autorelease];
	[theTask setLaunchPath: @"/usr/bin/tar"];
	[theTask setArguments: [NSArray arrayWithObjects: @"xfz", fpath, nil]];
	[theTask setCurrentDirectoryPath: [fpath stringByDeletingLastPathComponent]];
	[theTask launch];
	[theTask waitUntilExit];
	[[NSFileManager defaultManager] removeFileAtPath: fpath handler:nil];
	
	return [theTask terminationStatus];
}


// -----------------------------------------------------------------------------
//	unpackBz2Archive:
//		Unpack a BZip2 archive. The files are unpacked into the folder that held
//      the archive and then the archive is deleted.
//
//	REVISIONS:
//		2004-12-18	witness	Created based on unpackTgzArchive.
// -----------------------------------------------------------------------------

-(int)		unpackBz2Archive: (NSString*)fpath
{
	NSTask* theTask = [[[NSTask alloc] init] autorelease];
	[theTask setLaunchPath: @"/usr/bin/bunzip2"];
	[theTask setArguments: [NSArray arrayWithObjects: @"--quiet", @"--", fpath, nil]];
	[theTask setCurrentDirectoryPath: [fpath stringByDeletingLastPathComponent]];
	[theTask launch];
	[theTask waitUntilExit];
	[[NSFileManager defaultManager] removeFileAtPath: fpath handler:nil];
	
	return [theTask terminationStatus];
}


// -----------------------------------------------------------------------------
//	unpackDmgArchive:
//		This takes a disk image file and "unpacks" all visible files from it.
//		It does that by mounting the image, copying the files out and then
//		unmounting and deleting the original image. The files are unpacked
//		into the folder that held the archive and then the archive is deleted.
//
//		This was a piece of work. I can't believe there is no call in hdiutil
//		for doing this.
//
//	REVISIONS:
//		2004-03-21	witness	Moved here from UKShovelAppDelegate.
// -----------------------------------------------------------------------------

-(int)		unpackDmgArchive: (NSString*)fpath
{
	// Run hdiutil to mount the disk image, capturing its output (a plist) to a file:
	NSString*   tempFile = [[NSFileManager defaultManager] nameForTempFile];
	NSTask*		theTask = [[[NSTask alloc] init] autorelease];
	[theTask setLaunchPath: @"/usr/bin/hdiutil"];
	[theTask setArguments: [NSArray arrayWithObjects: @"attach", fpath, @"-plist", @"-private", @"-nobrowse", nil]];
	[[NSFileManager defaultManager] createFileAtPath: tempFile contents:[NSData data] attributes: nil];

	[theTask setStandardOutput: [NSFileHandle fileHandleForWritingAtPath: tempFile]];
	[theTask launch];
	[theTask waitUntilExit];
	
	// Get hdiutil's output so we know where the files are:
	NSDictionary*   hdiinfo = [NSDictionary dictionaryWithContentsOfFile: tempFile];	// dev-entry and mount-point in system-entities.
	hdiinfo = [[hdiinfo objectForKey: @"system-entities"] objectAtIndex: 0];
	
	// Copy the files off the disk image:
	if( [theTask terminationStatus] == 0 )
	{
		NSString*					baseDestPath = [fpath stringByDeletingLastPathComponent];
		NSString*					basePath = [hdiinfo objectForKey: @"mount-point"];
		NSDirectoryEnumerator*		dirEnny = [[NSFileManager defaultManager] enumeratorAtPath: basePath];
		NSString*					currPath = nil;
		
		while( (currPath = [dirEnny nextObject]) )
		{
			NSString*		currName = [currPath lastPathComponent];
			if( [currName characterAtIndex: 0] != '.' ) // Only copy visible files.
			{
				[[NSFileManager defaultManager] copyPath: [basePath stringByAppendingPathComponent: currPath]
												toPath: [baseDestPath stringByAppendingPathComponent: currPath]
												handler: nil];
			}
			
			// copyPath copies the entire folder plus contents, no need for a deep search:
			if( [[[dirEnny fileAttributes] objectForKey: NSFileType] isEqualToString: NSFileTypeDirectory] )
				[dirEnny skipDescendents];
		}
		
		// Run hdiutil again to unmount the image:
		theTask = [[[NSTask alloc] init] autorelease];
		[theTask setLaunchPath: @"/usr/bin/hdiutil"];
		[theTask setArguments: [NSArray arrayWithObjects: @"detach", [hdiinfo objectForKey: @"dev-entry"], @"-quiet", nil]];
		[theTask launch];
		[theTask waitUntilExit];
	}
	
	// Clean up by deleting the files:
	[[NSFileManager defaultManager] removeFileAtPath: tempFile handler:nil];
	[[NSFileManager defaultManager] removeFileAtPath: fpath handler:nil];
	
	return [theTask terminationStatus];
}


@end
