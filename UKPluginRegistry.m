//
//  UKPluginRegistry.m
//  UliKit
//
//  Created by Uli Kusterer on 24.10.04.
//  Copyright 2004 M. Uli Kusterer. All rights reserved.
//

#import "UKPluginRegistry.h"


@implementation UKPluginRegistry

static UKPluginRegistry* sSharedPluginRegistry = nil;
	
+(id)	sharedRegistry
{
	if( !sSharedPluginRegistry )
		[[UKPluginRegistry alloc] init];	// Sets sSharedPluginRegistry.
	
	return sSharedPluginRegistry;
}


-(id)	init
{
	if(( self = [super init] ))
	{
		if( sSharedPluginRegistry )
		{
			[self autorelease];
			return nil;
		}
		plugins = [[NSMutableArray alloc] init];
		pluginPaths = [[NSMutableDictionary alloc] init];
		
		sSharedPluginRegistry = self;
	}
	
	return self;
}


-(void)	dealloc
{
	[plugins release];
	[pluginPaths release];
	
	if( sSharedPluginRegistry && sSharedPluginRegistry == self )
		sSharedPluginRegistry = nil;
	
	[super dealloc];
}


-(void)	loadPluginsOfType: (NSString*)ext
{
	NSEnumerator*	enny = [NSSearchPathForDirectoriesInDomains( NSLibraryDirectory, NSAllDomainsMask, YES ) objectEnumerator];
	NSString*		path;
	NSString*		appName = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleExecutable"];
	NSString*		pluginsDir = [[@"Application Support" stringByAppendingPathComponent: appName] stringByAppendingPathComponent: @"PlugIns"];
	
	while( (path = [enny nextObject]) )
	{
		[self loadPluginsFromPath: [path stringByAppendingPathComponent: pluginsDir] ofType: ext];
	}
	[self loadPluginsFromPath: [[NSBundle mainBundle] builtInPlugInsPath] ofType: ext];
}


-(void)	loadPluginsFromPath: (NSString*)folder ofType: (NSString*)ext
{
	NSDirectoryEnumerator*	enny = [[NSFileManager defaultManager] enumeratorAtPath: folder];
	NSString*				currFile = nil;
	
	while( (currFile = [enny nextObject]) )
	{
		[enny skipDescendents];	// Ignore subfolders and don't search in packages.
		
		// Skip invisible files:
		if( [currFile characterAtIndex: 0] == '.' )
			continue;
		
		// Only process ones that have the right suffix:
		if( ![[currFile pathExtension] isEqualToString: ext] )
			continue;
		
		NS_DURING
			// Get path, bundle and display name:
			NSString*			currPath = [folder stringByAppendingPathComponent: currFile];
			
			[self loadPluginForPath: currPath];
		NS_HANDLER
			NSLog(@"Error while listing PlugIn: %@", localException);
		NS_ENDHANDLER
	}
}


-(NSMutableDictionary*)	loadPluginForPath: (NSString*)currPath
{
	NSMutableDictionary*	info = [pluginPaths objectForKey: currPath];
	
	if( !info )
	{
		NSBundle*			currBundle = [NSBundle bundleWithPath: currPath];
		NSString*			pluginName = [[currBundle infoDictionary] objectForKey: @"CFBundleName"];
		if( pluginName == nil )
			pluginName = @"Unknown";
		
		// Get icon, falling back on file icon when needed, or in worst case using our app icon:
		NSString*			iconFileName = [[currBundle infoDictionary] objectForKey: @"NSPrefPaneIconFile"];
		if( !iconFileName )
			iconFileName = [[currBundle infoDictionary] objectForKey: @"CFBundleIconFile"];
		NSString*			imgFName = (iconFileName == nil) ? nil : [currBundle pathForResource: iconFileName ofType: @""];
		NSImage*			currImage = (imgFName == nil) ? [NSImage imageNamed: @"NSApplicationIcon"] : [[[NSImage alloc] initWithContentsOfFile: imgFName] autorelease];
		
		// Add a new entry for this pane to our list:
		info = [NSMutableDictionary dictionaryWithObjectsAndKeys:
												currBundle, @"bundle",
												currImage, @"image",
												pluginName, @"name",
												currPath, @"path",
												[currBundle principalClass], @"class",
												[currBundle localizedInfoDictionary], @"info.plist",
												nil];
        if( instantiate )
        {
            id      obj = [[[[currBundle principalClass] alloc] init] autorelease];
            [info setObject: obj forKey: @"instance"];
        }
		[plugins addObject: info];
		[pluginPaths setObject: info forKey: currPath];
	}
	
	return info;
}


-(NSArray*)				loadedPlugins
{
	return plugins;
}


-(BOOL)                 instantiate
{
    return instantiate;
}


-(void)                 setInstantiate: (BOOL)n
{
    instantiate = n;
}

@end
