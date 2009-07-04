/* =============================================================================
	FILE:		UKFSEventsWatcher.h
    
    COPYRIGHT:  (c) 2008 Peter Baumgartner, all rights reserved.
    
	AUTHORS:	Peter Baumgartner
    
    LICENSES:   MIT License

	REVISIONS:
		2008-06-09	PB Created.
   ========================================================================== */

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
