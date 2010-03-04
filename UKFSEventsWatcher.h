//
//	UKFSEventsWatcher.h
//	
//
//	Created by Peter Baumgartner on 9.6.2008.
//	Copyright 2008 Peter Baumgartner.
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

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import "UKFileWatcher.h"
#import <Carbon/Carbon.h>

#if MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_4

// -----------------------------------------------------------------------------
//  Class declaration:
// -----------------------------------------------------------------------------

@interface UKFSEventsWatcher : NSObject <UKFileWatcher>
{
    id							delegate;           // Delegate must respond to UKFileWatcherDelegate protocol.
	CFTimeInterval				latency;			// Time that must pass before events are being sent.
	FSEventStreamCreateFlags	flags;				// See FSEvents.h
    NSMutableDictionary*		eventStreams;		// List of FSEventStreamRef pointers in NSValues, with the pathnames as their keys.
}

+ (id) sharedFileWatcher;

- (void) setLatency:(CFTimeInterval)latency;
- (CFTimeInterval) latency;

- (void) setFSEventStreamCreateFlags:(FSEventStreamCreateFlags)flags;
- (FSEventStreamCreateFlags) fsEventStreamCreateFlags;

// UKFileWatcher defines the methods: addPath: removePath: and delegate accessors.
- (void) removeAllPaths;

@end

#endif
