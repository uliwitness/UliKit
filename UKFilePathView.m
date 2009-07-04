//
//  UKFilePathView.m
//  Shovel
//
//  Created by Uli Kusterer on Thu Mar 25 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import "UKFilePathView.h"
#import "UKGraphics.h"


static	NSImage*	gUKFPVPathArrowImage = nil;

@implementation UKFilePathView

-(id)	initWithFrame: (NSRect)frame
{
    self = [super initWithFrame:frame];
    if( self )
	{
        filePath = nil;			// Means "none".
		noDisplayNames = NO;	// Show display names by default.
		canChooseFiles = YES;
		canChooseDirectories = NO;
		treatsFilePackagesAsDirectories = NO;
		placeholderString = [NSLocalizedString(@"<None>", @"default UKFilePathView placeholder") retain];
		
		if( !gUKFPVPathArrowImage )
			gUKFPVPathArrowImage = [[self pathArrowImage] retain];
    }
    return self;
}


-(void)	dealloc
{
	[filePath release];
	[placeholderString release];
	[types release];
	
	[super dealloc];
}


// -----------------------------------------------------------------------------
//	pathArrowImage:
//		Generate a "triangle" image for use as a right-pointing arrow that
//		is used to delimit our path components during display. This removes the
//		need for a separate image file containing the triangle.
// -----------------------------------------------------------------------------

-(NSImage*)	pathArrowImage;
{
	NSImage*	parrowImg = nil;
	
	parrowImg = [[[NSImage alloc] initWithSize: NSMakeSize(16,16)] autorelease];
	[parrowImg lockFocus];
		NSBezierPath*	path = [NSBezierPath bezierPath];
		
		[path moveToPoint: NSMakePoint(2,2)];
		[path lineToPoint: NSMakePoint(2,14)];
		[path lineToPoint: NSMakePoint(16,9)];
		[path lineToPoint: NSMakePoint(2,4)];
		
		[[NSColor darkGrayColor] set];
		[path fill];
	[parrowImg unlockFocus];
	
	return parrowImg;
}


// -----------------------------------------------------------------------------
//	fullPathAsDisplayString:
//		Return the path as a unicode string. This doesn't look as good as
//		our display inside the window, but is used for the tool tip to allow
//		seeing even truncated text fields' full path.
// -----------------------------------------------------------------------------

-(NSString*)	fullPathAsDisplayString
{
	if( !filePath )
		return nil;
	
	NSString*			triStr = [NSString stringWithFormat: @"%C ", 0x25B6];
	NSMutableString*	str = nil;
	NSArray*			pathComponents = [[NSFileManager defaultManager] componentsToDisplayForPath: filePath];
	NSEnumerator*		enny = [pathComponents objectEnumerator];
	NSString*			currComponent = nil;
	int					tabCount = 0, x;
	
	str = [[[enny nextObject] mutableCopy] autorelease];
	while( (currComponent = [enny nextObject]) )
	{
		[str appendString: @"\n"];
		tabCount++;
		for( x = 0; x < tabCount; x++ )
			[str appendString: @" "];
		[str appendString: triStr];
		[str appendString: currComponent];
	}
	
	return str;
}


-(void) drawRect:(NSRect)rect
{
	NSPoint			pos = { 0, 0 };
	NSDictionary*   attribs = [NSDictionary dictionaryWithObjectsAndKeys: [NSFont systemFontOfSize: [NSFont systemFontSize]], NSFontAttributeName, [NSColor controlTextColor], NSForegroundColorAttributeName, nil];
	NSDictionary*   disAttribs = [NSDictionary dictionaryWithObjectsAndKeys: [NSFont systemFontOfSize: [NSFont systemFontSize]], NSFontAttributeName, [NSColor disabledControlTextColor], NSForegroundColorAttributeName, nil];
    NSMutableArray* components = [NSMutableArray array];
    NSMutableArray* icons = [NSMutableArray array];
    NSMutableArray* paths = [NSMutableArray array];
	NSSize			theSize = [@"foo" sizeWithAttributes: attribs];
	NSEnumerator*   enny = nil;
	NSString*		currName;
	NSImage*		emptyImg = [[[NSImage alloc] initWithSize: NSMakeSize(1,1)] autorelease];
	
	// Draw border and make sure text is vertically centered:
	UKDrawDropHighlightedEditableWhiteBezel( drawDropHighlight, action != 0, [self bounds], [self bounds] );
	pos.y += truncf(([self bounds].size.height -theSize.height) /2);
	
	// If no path specified, show "none":
	if( filePath == nil )
	{
		[placeholderString drawAtPoint: NSMakePoint(pos.x +4, pos.y +2) withAttributes: disAttribs];
		return;
	}
	
	// Build the display path and list our icons:
	enny = [[filePath pathComponents] objectEnumerator];
	NSMutableString*	currPath = [NSMutableString string];
	while( (currName = [enny nextObject]) )
	{
		int pln = [currPath length];
		if( pln == 0 || [currPath characterAtIndex: pln -1] != '/' )
			[currPath appendString: @"/"];
		if( ![currName isEqualToString: @"/"] )
			[currPath appendString: currName];
		[icons addObject: [[NSWorkspace sharedWorkspace] iconForFile: currPath]];
		[paths addObject: [[currPath copy] autorelease]];
		if( !noDisplayNames )	// We're showing display names?
		{
			[components addObject: [[NSFileManager defaultManager] displayNameAtPath: currPath]];
			if( [currPath isEqualToString: @"/Volumes"] )
			{
				[components removeObjectsInRange: NSMakeRange(0,2)];
				[icons removeObjectsInRange: NSMakeRange(0,2)];
				[paths removeObjectsInRange: NSMakeRange(0,2)];
			}
		}
        else
			[components addObject: currName];
	}

	enny = [components objectEnumerator];
	int				componentsToGo = [components count];
	
	// Calculate width of displayed path:
	theSize.width = 0;
	theSize.height = 0;
	while( (currName = [enny nextObject]) )
	{
		theSize.width += [currName sizeWithAttributes: attribs].width +UK_PATH_NAME_TOTAL_HMARGIN
							+UK_PATH_ICON_IMG_WIDTH +UK_PATH_ICON_NAME_HDISTANCE;
		if( --componentsToGo > 0 )
			theSize.width += UK_PATH_ARROW_IMG_WIDTH;
	}
	
	// If it's wider than our box, start taking components out of the middle:
	if( [components count] > 2 && (theSize.width > [self bounds].size.width) )
	{
		int middleEntry = ([components count] /2) -1;
		
		if( (middleEntry * 2) < [components count] )
			middleEntry++;
		
		// Replace the middle-most entry with an ellipsis ("..."):
		theSize.width -= [[components objectAtIndex: middleEntry] sizeWithAttributes: attribs].width +UK_PATH_NAME_TOTAL_HMARGIN +UK_PATH_ICON_IMG_WIDTH +UK_PATH_ICON_NAME_HDISTANCE;
		[components replaceObjectAtIndex: middleEntry withObject: UK_PATH_ELLIPSIS];
		theSize.width += [UK_PATH_ELLIPSIS sizeWithAttributes: attribs].width +UK_PATH_NAME_TOTAL_HMARGIN;
		
		while( [components count] > 3 && (theSize.width > [self bounds].size.width) )
		{
			[components removeObjectAtIndex: middleEntry];  // Remove "...".
			[icons removeObjectAtIndex: middleEntry];  // Remove empty icon for ellipsis.
			[paths removeObjectAtIndex: middleEntry];  // Remove empty path for ellipsis.
			middleEntry = ([components count] /2);
			theSize.width -= [[components objectAtIndex: middleEntry] sizeWithAttributes: attribs].width +UK_PATH_NAME_TOTAL_HMARGIN +UK_PATH_ARROW_IMG_WIDTH +UK_PATH_ICON_IMG_WIDTH +UK_PATH_ICON_NAME_HDISTANCE;
			[components replaceObjectAtIndex: middleEntry withObject: UK_PATH_ELLIPSIS];
			[icons replaceObjectAtIndex: middleEntry withObject: emptyImg];
			[paths replaceObjectAtIndex: middleEntry withObject: @""];
		}
	}
	
	if( [components count] == 3 && theSize.width > [self bounds].size.width )	// Still wider?
	{
		// Remove final two components so we only show file icon and name:
		[components removeObjectAtIndex: 1];
		[icons removeObjectAtIndex: 1];
		[paths removeObjectAtIndex: 1];
		[components removeObjectAtIndex: 0];
		[icons removeObjectAtIndex: 0];
		[paths removeObjectAtIndex: 0];
	}
	
	// Draw components that are left:
	NSImage*			theIcon = nil;
	NSEnumerator*		iconEnny = [icons objectEnumerator];
    NSString*           thePath = nil;
	NSEnumerator*		pathEnny = [paths objectEnumerator];
	enny = [components objectEnumerator];
	componentsToGo = [components count];
	while( (currName = [enny nextObject]) )
	{
		theIcon = [iconEnny nextObject];
		thePath = [pathEnny nextObject];
		
		theSize = [currName sizeWithAttributes: attribs];
		theSize.width += UK_PATH_NAME_TOTAL_HMARGIN;
		theSize.height += UK_PATH_NAME_TOTAL_VMARGIN;
		
        BOOL        exists = [[NSFileManager defaultManager] fileExistsAtPath: thePath];
        
        //NSLog(@"%d %@ (%@)", (int)exists, currName, thePath );
        
		if( ![UK_PATH_ELLIPSIS isEqualToString: currName] )
		{
			[theIcon setSize: NSMakeSize(UK_PATH_ICON_IMG_WIDTH,UK_PATH_ICON_IMG_WIDTH)];
			[theIcon dissolveToPoint: NSMakePoint(pos.x +UK_PATH_NAME_LEFT_MARGIN, pos.y +UK_PATH_NAME_BOTTOM_MARGIN) fraction: (exists ? 1 : 0.3)];
			
			pos.x += UK_PATH_ICON_IMG_WIDTH +UK_PATH_ICON_NAME_HDISTANCE;
		}
		
		[currName drawAtPoint: NSMakePoint(pos.x +UK_PATH_NAME_LEFT_MARGIN, pos.y +UK_PATH_NAME_BOTTOM_MARGIN) withAttributes: (exists ? attribs : disAttribs)];
		
		pos.x += theSize.width;
		if( --componentsToGo > 0 )
		{
			[gUKFPVPathArrowImage dissolveToPoint: pos fraction: 1];
			pos.x += UK_PATH_ARROW_IMG_WIDTH;
		}
	}
}

-(NSString *)	filePath
{
    return filePath;
}

-(void)	setFilePath: (NSString *)newFilePath
{
    if( filePath != newFilePath )
	{
		[filePath release];
		filePath = [newFilePath retain];
		[self setNeedsDisplay: YES];
		
		[self setToolTip: [self fullPathAsDisplayString]];
	}
}


-(void) reshowDisplayNames: (id)sender
{
	noDisplayNames = NO;
	[self setNeedsDisplay: YES];
}


-(void)	showRealNames: (id)sender
{
	if( !noDisplayNames )
	{
		noDisplayNames = YES;
		[self setNeedsDisplay: YES];
		[NSTimer scheduledTimerWithTimeInterval: 5  // 5 secs should be enough.
					target: self selector:@selector(reshowDisplayNames:)
					userInfo:nil repeats: NO];
	}
}

-(void)	toggleShowRealNames: (id)sender
{
	noDisplayNames = !noDisplayNames;
	[self setNeedsDisplay: YES];
}


-(void)	revealInFinder: (id)sender
{
	[[NSWorkspace sharedWorkspace] selectFile: filePath inFileViewerRootedAtPath: @""];
}


-(BOOL)	validateMenuItem: (id<NSMenuItem>)item
{
	if( [item action] == @selector(revealInFinder:)
		|| [item action] == @selector(showRealNames:) )
		return filePath != nil;
	else if( [item action] == @selector(toggleShowRealNames:) )
	{
		[item setState: noDisplayNames];
		return filePath != nil;
	}
	else
		return NO;
}


// Upon a click, we shortly toggle from display to file names and back:
-(void) mouseDown: (NSEvent*)evt
{
	if( filePath && [evt clickCount] == 2 )
		[[NSWorkspace sharedWorkspace] selectFile: filePath inFileViewerRootedAtPath: @""];
}


// -----------------------------------------------------------------------------
//	defaultMenu:
//		Return the contextual menu to use when right-clicking this view.
// -----------------------------------------------------------------------------

+(NSMenu*)	defaultMenu
{
	NSMenu*		theMenu = [[[NSMenu alloc] initWithTitle: @"Contextual Menu"] autorelease];
	
	[theMenu addItemWithTitle: NSLocalizedString(@"Reveal in Finder",@"UKFilePathView contextual menu item")
				action: @selector(revealInFinder:) keyEquivalent: @""];
	[theMenu addItemWithTitle: NSLocalizedString(@"Show Real File Names",@"UKFilePathView contextual menu item")
				action: @selector(toggleShowRealNames:) keyEquivalent: @""];
	
	return theMenu;
}


// -----------------------------------------------------------------------------
//	pickFile:
//		Button action for showing an open panel to fill this field with the
//		path of any already existing file.
// -----------------------------------------------------------------------------

-(IBAction)			pickFile: (id)sender
{
	NSOpenPanel*	op = [NSOpenPanel openPanel];
	
	[op setAllowsMultipleSelection: NO];
	[op setCanChooseFiles: canChooseFiles];
	[op setCanChooseDirectories: canChooseDirectories];
	[op setTreatsFilePackagesAsDirectories: treatsFilePackagesAsDirectories];
	
	[op beginSheetForDirectory: [filePath stringByDeletingLastPathComponent]
			file: filePath types: types modalForWindow: [self window]
			modalDelegate: self didEndSelector: @selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo: self];

}


// -----------------------------------------------------------------------------
//	pickNewFile:
//		Button action for showing a save panel to fill this field with a
//		not yet existing file path.
// -----------------------------------------------------------------------------

-(IBAction)			pickNewFile: (id)sender
{
	NSSavePanel*	op = [NSSavePanel savePanel];
	
	[op setTreatsFilePackagesAsDirectories: treatsFilePackagesAsDirectories];
	
	[op beginSheetForDirectory: [filePath stringByDeletingLastPathComponent]
			file: filePath modalForWindow: [self window]
			modalDelegate: self didEndSelector: @selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo: self];

}

-(void)	openPanelDidEnd: (NSOpenPanel*)sheet returnCode: (int)returnCode contextInfo: (void*)contextInfo
{
	if( returnCode == NSOKButton )
	{
		[self setFilePath: [sheet filename]];
		
		if( [target respondsToSelector: action] )
			[target performSelector: action withObject: self];
	}
}


// -----------------------------------------------------------------------------
//	pickNoFile:
//		Button action for clearing this field and thus specifying no file.
// -----------------------------------------------------------------------------

-(IBAction)		pickNoFile: (id)sender
{
	[self setFilePath: nil];
	
	if( [target respondsToSelector: action] )
		[target performSelector: action withObject: self];
}


// ---------------------------------------------------------- 
// - types:
// ---------------------------------------------------------- 
- (NSArray *) types
{
    return types; 
}

// ---------------------------------------------------------- 
// - setTypes:
// ---------------------------------------------------------- 
- (void) setTypes: (NSArray *) theTypes
{
    if (types != theTypes) {
        [types release];
        types = [theTypes retain];
    }
}


// ---------------------------------------------------------- 
// - canChooseFiles:
// ---------------------------------------------------------- 
- (BOOL) canChooseFiles
{

    return canChooseFiles;
}

// ---------------------------------------------------------- 
// - setCanChooseFiles:
// ---------------------------------------------------------- 
- (void) setCanChooseFiles: (BOOL) flag
{
        canChooseFiles = flag;
}

// ---------------------------------------------------------- 
// - canChooseDirectories:
// ---------------------------------------------------------- 
- (BOOL) canChooseDirectories
{

    return canChooseDirectories;
}

// ---------------------------------------------------------- 
// - setCanChooseDirectories:
// ---------------------------------------------------------- 
- (void) setCanChooseDirectories: (BOOL) flag
{
        canChooseDirectories = flag;
}

// ---------------------------------------------------------- 
// - treatsFilePackagesAsDirectories:
// ---------------------------------------------------------- 
- (BOOL) treatsFilePackagesAsDirectories
{

    return treatsFilePackagesAsDirectories;
}

// ---------------------------------------------------------- 
// - setTreatsFilePackagesAsDirectories:
// ---------------------------------------------------------- 
- (void) setTreatsFilePackagesAsDirectories: (BOOL) flag
{
        treatsFilePackagesAsDirectories = flag;
}


-(NSString *)	stringValue
{
	return [self filePath];
}


-(void)			setStringValue: (NSString*)s
{
	[self setFilePath: s];
}


-(void)	concludeDragOperation: (id <NSDraggingInfo>)sender
{
	drawDropHighlight = NO;
	[self setNeedsDisplay: YES];
}

-(NSDragOperation)	draggingEntered: (id <NSDraggingInfo>)sender
{
	drawDropHighlight = YES;
	[self setNeedsDisplay: YES];

	return NSDragOperationLink;
}

-(BOOL)	prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	return YES;
}


// -----------------------------------------------------------------------------
//	performDragOperation:
//		Accept the drag. If the file that was dropped doesn't match our
//		criteria, we reject it here and just beep.
//
//	REVISIONS:
//		2006-07-22	UK	Added fix suggested by Derrick Bass that lets through
//						files and folders if the types array == nil.
// -----------------------------------------------------------------------------

-(BOOL)	performDragOperation: (id <NSDraggingInfo>)sender
{
	NSPasteboard*	pb = [sender draggingPasteboard];
	NSString*		type = [pb availableTypeFromArray: [NSArray arrayWithObjects: NSFilenamesPboardType, NSFilesPromisePboardType, nil]];
	NSArray*		arr = [pb propertyListForType: type];
	NSString*		thePath = [arr objectAtIndex: 0];
	NSString*		fileExtension = [thePath pathExtension];
	BOOL			isDir = NO;
	
	[[NSFileManager defaultManager] fileExistsAtPath: thePath isDirectory: &isDir];	// Find out if it's file or folder.
	if( (types == nil || [types containsObject: [fileExtension lowercaseString]])
		&& ((!isDir && canChooseFiles) || (isDir && canChooseDirectories)) )
	{
		[self setFilePath: thePath];
		[target performSelector: action withObject: self];
	}
	else
		NSBeep();
	
	return YES;
}


-(void)	draggingExited:(id <NSDraggingInfo>)sender
{
	drawDropHighlight = NO;
	[self setNeedsDisplay: YES];
}


// ---------------------------------------------------------- 
// - action:
// ---------------------------------------------------------- 
- (SEL) action
{
    return action;
}

// ---------------------------------------------------------- 
// - setAction:
// ---------------------------------------------------------- 
- (void) setAction: (SEL) theAction
{
	action = theAction;
	
	if( action != 0 )
		[self registerForDraggedTypes: [NSArray arrayWithObjects: NSFilenamesPboardType, NSFilesPromisePboardType, nil]];
	else
		[self unregisterDraggedTypes];
}

// ---------------------------------------------------------- 
// - target:
// ---------------------------------------------------------- 
- (id) target
{
    return target; 
}

// ---------------------------------------------------------- 
// - setTarget:
// ---------------------------------------------------------- 
- (void) setTarget: (id) theTarget
{
        target = theTarget;
}

-(void)			setPlaceholderString: (NSString*)string
{
	if( string != placeholderString )
	{
		[placeholderString release];
		placeholderString = [string retain];
	}
}

-(NSString*)	placeholderString
{
	return placeholderString;
}



@end
