//
//  UKPluginRegistry.h
//  UliKit
//
//  Created by Uli Kusterer on 24.10.04.
//  Copyright 2004 Uli Kusterer.
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