//
//  UKPluginRegistry.h
//  UliKit
//
//  Created by Uli Kusterer on 24.10.04.
//  Copyright 2004 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface UKPluginRegistry : NSObject
{
	NSMutableArray*			plugins;		// List of available plugins, with dictionaries for each.
	NSMutableDictionary*	pluginPaths;	// Key is file path, value is entry in plugins.
    BOOL                    instantiate;    // Instantiate the principal class of each plugin.
}

+(id)					sharedRegistry;

// The following loads from all Application Support/AppName/PlugIns/ folders as well as the PlugIns folder in the app bundle:
-(void)					loadPluginsOfType: (NSString*)ext;  // Usually you only need to call this.
-(void)					loadPluginsFromPath: (NSString*)folder ofType: (NSString*)ext;
-(NSMutableDictionary*)	loadPluginForPath: (NSString*)currPath; // Returns dictionary for loaded plugin.

-(NSArray*)				loadedPlugins;      // Array of plugin dictionaries.

-(BOOL)                 instantiate;
-(void)                 setInstantiate: (BOOL)n;

@end

/*
    Each plugin is represented by an NSMutableDictionary to which you can add your
    own entries as needed. The keys UKPluginRegistry adds to this dictionary are:
    
    bundle		-   NSBundle instance for this plugin.
    image		-   Icon (NSImage) of the plugin (for display in toolbars etc.)
    name		-   Display name of the plugin (for display in lists, toolbars etc.)
    path		-   Full path to the bundle.
    class		-   The principal class (type "Class") for this bundle, so you
					can instantiate it.
    instance	-	If instantiate == YES, this contains an instance of the
					principal class, instantiated using alloc+init.
	info.plist	-	The keys from the bundle's Info.plist file, localized.
*/