//
//  UKFilePathView.m
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

#import "UKFilePathView.h"
#import "UKGraphics.h"
#import "UKFadedDrawing.h"


static	NSImage*	gUKFPVPathArrowImage = nil;


@interface UKFilePathEntry : NSObject
{
	NSString*		path;
	NSString*		displayName;
	NSImage*		icon;
	BOOL			hidden;
	CGFloat			width;
	CGFloat			displayWidth;
}

-(void)			setPath: (NSString*)str;
-(NSString*)	path;

-(void)			setDisplayName: (NSString*)str;
-(NSString*)	displayName;

-(void)			setIcon: (NSImage*)img;
-(NSImage*)		icon;

-(void)			setHidden: (BOOL)state;
-(BOOL)			isHidden;

-(void)			setWidth: (CGFloat)wd;
-(CGFloat)		width;

-(void)			setDisplayWidth: (CGFloat)wd;
-(CGFloat)		displayWidth;

@end


@implementation UKFilePathEntry

-(id)	init
{
	if(( self = [super init] ))
	{
		hidden = NO;
	}
	
	return self;
}

-(void)			setPath: (NSString*)str
{
	if( path != str )
	{
		[path release];
		path = [str retain];
	}
}


-(NSString*)	path
{
	return path;
}

-(void)			setDisplayName: (NSString*)str
{
	if( displayName != str )
	{
		[displayName release];
		displayName = [str retain];
	}
}


-(NSString*)	displayName
{
	return displayName;
}

-(void)			setIcon: (NSImage*)img
{
	if( icon != img )
	{
		[icon release];
		icon = [img retain];
	}
}


-(NSImage*)		icon
{
	return icon;
}


-(void)			setHidden: (BOOL)state
{
	hidden = state;
}


-(BOOL)			isHidden
{
	return hidden;
}

-(void)			setWidth: (CGFloat)wd
{
	width = wd;
}


-(CGFloat)		width
{
	return width;
}


-(void)			setDisplayWidth: (CGFloat)wd
{
	displayWidth = wd;
}


-(CGFloat)		displayWidth
{
	return displayWidth;
}


-(NSString*)	description
{
	return [NSString stringWithFormat: @"%@ <%p> { displayName = %@, width = %f, displayWidth = %f, hidden = %s, path = %@, icon = %@ }", NSStringFromClass([self class]), self, displayName, width, displayWidth, (hidden?"YES":"NO"), path, icon];
}

@end




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
		borderType = NSBezelBorder;
		acceptDrops = YES;
		selectedPathEntry = NSNotFound;
		pathEntries = [[NSMutableArray alloc] init];
		textAttributes = [[NSDictionary alloc] initWithObjectsAndKeys: [NSFont systemFontOfSize: [NSFont systemFontSize]], NSFontAttributeName, [NSColor controlTextColor], NSForegroundColorAttributeName, nil];
		
		if( !gUKFPVPathArrowImage )
			gUKFPVPathArrowImage = [[self pathArrowImage] retain];
    }
    return self;
}


-(void)	dealloc
{
	[filePath release];
	filePath = nil;
	[placeholderString release];
	placeholderString = nil;
	[types release];
	types = nil;
	[pathEntries release];
	pathEntries = nil;
	[textAttributes release];
	textAttributes = nil;
	[directoryURL release];
	directoryURL = nil;
	[message release];
	message = nil;
	
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
		
		[path moveToPoint: NSMakePoint(4,4)];
		[path lineToPoint: NSMakePoint(4,12)];
		[path lineToPoint: NSMakePoint(12,8)];
		[path lineToPoint: NSMakePoint(4,4)];
		
		[[NSColor lightGrayColor] set];
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
	
	NSString*			triStr = [NSString stringWithFormat: @"%C ", (unichar) 0x25B6];
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


-(NSDictionary*)	textAttributes
{
	return textAttributes;
}



-(void)	setTextAttributes: (NSDictionary*)dict
{
	if( textAttributes != dict )
	{
		[textAttributes release];
		textAttributes = [dict retain];
		[self setNeedsDisplay: YES];
	}
}


-(NSDictionary*)	disabledTextAttributes	// Disabled attributes *must* measure the same as regular text attributes. Only change color or so.
{
	NSMutableDictionary*	disAttribs = [NSMutableDictionary dictionaryWithDictionary: [self textAttributes]];
	[disAttribs setObject: [NSColor disabledControlTextColor] forKey: NSForegroundColorAttributeName];
	return disAttribs;
}



-(CGFloat)	ellipsisWidth
{
	return UK_PATH_ARROW_IMG_WIDTH +[[NSString stringWithFormat: @"%C", (unichar) 0x2026] sizeWithAttributes: [self textAttributes]].width;
}


-(CGFloat)	widthOfVisiblePathEntries
{
	NSEnumerator*		enny = [pathEntries objectEnumerator];
	UKFilePathEntry*	currEntry = nil;
	CGFloat				totalWidth = 0;
	int					numVisible = 0;
	BOOL				lastEntryWasHidden = NO;	// Usually, all are visible.
	CGFloat				ellipsisWidth = [self ellipsisWidth];
	
	while( (currEntry = [enny nextObject]) )
	{
		if( ![currEntry isHidden] )
		{
			if( lastEntryWasHidden )
				totalWidth += ellipsisWidth;
			
			totalWidth += [currEntry displayWidth];
			numVisible++;
			lastEntryWasHidden = NO;
		}
		else
			lastEntryWasHidden = YES;
	}
	
	if( numVisible > 0 )
		totalWidth -= UK_PATH_ARROW_IMG_WIDTH;
	
	return totalWidth;
}


-(NSInteger)	indexOfPathEntryAtPoint: (NSPoint)pos
{
	if( NSPointInRect( pos, [self bounds] ) )
	{
		NSEnumerator*		enny = [pathEntries objectEnumerator];
		UKFilePathEntry	*	currEntry = nil;
		CGFloat				currentRightEdge = 0;
		NSInteger			numVisible = 0;
		BOOL				lastEntryWasHidden = NO;	// Usually, all are visible.
		CGFloat				ellipsisWidth = [self ellipsisWidth];
		NSUInteger			x = 0;
		
		while( (currEntry = [enny nextObject]) )
		{
			if( ![currEntry isHidden] )
			{
				if( lastEntryWasHidden )
					currentRightEdge += ellipsisWidth;
				
				currentRightEdge += [currEntry displayWidth];
				numVisible++;
				lastEntryWasHidden = NO;
				
				if( pos.x <= currentRightEdge )
				{
					if( pos.x <= (currentRightEdge -UK_PATH_ARROW_IMG_WIDTH) )
						return x;
					else
						break;	// Hit triangle arrow between items, ignore.
				}
			}
			else
				lastEntryWasHidden = YES;
			
			x++;
		}
	}
	
	return NSNotFound;
}


-(UKFilePathEntry*)	lastVisiblePathEntry
{
	NSEnumerator*		enny = [pathEntries reverseObjectEnumerator];
	UKFilePathEntry*	currEntry = nil;
	UKFilePathEntry*	lastVis = nil;
	
	while( (currEntry = [enny nextObject]) )
	{
		if( ![currEntry isHidden] )
		{
			lastVis = currEntry;
			break;
		}
	}
	
	return lastVis;
}


-(void)	rebuildPathComponentArray
{
	NSEnumerator*		enny = nil;
	UKFilePathEntry*	currEntry = nil;
	NSDictionary*		attribs = [self textAttributes];
	
	[pathEntries removeAllObjects];
	
	// If no path specified, show "none":
	if( filePath != nil )
	{
		// Build the display path and list our icons:
		enny = [[filePath pathComponents] objectEnumerator];
		NSMutableString*	currPath = [NSMutableString string];
		NSString*			currName = nil;
		while( (currName = [enny nextObject]) )
		{
			NSUInteger pln = [currPath length];
			if( pln == 0 || [currPath characterAtIndex: pln -1] != '/' )
				[currPath appendString: @"/"];
			if( ![currName isEqualToString: @"/"] )
				[currPath appendString: currName];
			currEntry = [[[UKFilePathEntry alloc] init] autorelease];
			[pathEntries addObject: currEntry];
			[currEntry setIcon: [[NSWorkspace sharedWorkspace] iconForFile: currPath]];
			[currEntry setPath: [[currPath copy] autorelease]];
			if( !noDisplayNames )	// We're showing display names?
			{
				[currEntry setDisplayName: [[NSFileManager defaultManager] displayNameAtPath: currPath]];
				if( [currPath isEqualToString: @"/Volumes"] )
					[pathEntries removeObjectsInRange: NSMakeRange(0,2)];
			}
			else
				[currEntry setDisplayName: currName];
			CGFloat entryWidth = ceilf([[currEntry displayName] sizeWithAttributes: attribs].width +UK_PATH_NAME_TOTAL_HMARGIN
									+UK_PATH_ICON_IMG_WIDTH +UK_PATH_ICON_NAME_HDISTANCE +UK_PATH_ARROW_IMG_WIDTH);
			[currEntry setWidth: entryWidth];
			[currEntry setDisplayWidth: entryWidth];
		}
	}

	// Truncate some URLs that start at well-known folders:
	NSArray*	desktopFolders = NSSearchPathForDirectoriesInDomains( NSDesktopDirectory, NSUserDomainMask, YES );
	NSString*	desktopFolderPath = ([desktopFolders count] > 0) ? [desktopFolders objectAtIndex: 0] : nil;
	if( desktopFolderPath && [desktopFolderPath characterAtIndex: [desktopFolderPath length] -1] != '/' )
		desktopFolderPath = [desktopFolderPath stringByAppendingString: @"/"];
	if( desktopFolderPath && [desktopFolderPath length] <= [filePath length] && [filePath hasPrefix: desktopFolderPath] )
	{
		int		numSlashes = 0, x = 0;
        NSUInteger len = [desktopFolderPath length];
		
		for( x = 0; x < len; x++ )
		{
			if( [desktopFolderPath characterAtIndex: x] == '/' )
				numSlashes++;
		}
		
		// Is desktop folder? Remove folders before that and start at desktop folder right away:
		if( [pathEntries count] > (numSlashes -1) )
		{
			for( x = 0; x < (numSlashes -1); x++ )
				[pathEntries removeObjectAtIndex: 0];
		}
	}
	else
	{
		if( [pathEntries count] > 2 )
		{
			NSString* usersPath = @"/Users/";
			if( [usersPath length] < [filePath length] && [filePath hasPrefix: usersPath] )
			{
				[pathEntries removeObjectAtIndex: 0];
				[pathEntries removeObjectAtIndex: 0];
			}
		}
	}

	[self relayoutPathComponents];
	if( [self respondsToSelector: @selector(invalidateIntrinsicContentSize)] )
		[(id)self invalidateIntrinsicContentSize];
}


-(void)	relayoutPathComponents
{
	if( filePath != nil )
	{
		NSEnumerator*		enny = [pathEntries objectEnumerator];
		UKFilePathEntry*	currEntry = nil;
		while(( currEntry = [enny nextObject] ))
		{
			[currEntry setHidden: NO];
			[currEntry setDisplayWidth: [currEntry width]];
		}
		
		// If it's wider than our box, start taking components out of the middle:
		if( [pathEntries count] > 2 && ([self widthOfVisiblePathEntries] > [self bounds].size.width) )
		{
			NSInteger			middleOffset = 0;
			NSInteger			middleIndex = ([pathEntries count] -1) / 2;
			
			while( (middleOffset <= middleIndex) && ([self widthOfVisiblePathEntries] > [self bounds].size.width) )
			{
				NSInteger		currIdx = middleIndex -middleOffset;
				if( currIdx >= 0 && ![[pathEntries objectAtIndex: currIdx] isHidden] && [[pathEntries objectAtIndex: currIdx] displayWidth] == [[pathEntries objectAtIndex: currIdx] width] )
				{
					currEntry = [pathEntries objectAtIndex: currIdx];
					[currEntry setHidden: YES];
					CGFloat	usedWidth = [self widthOfVisiblePathEntries];
					if( usedWidth < [self bounds].size.width )	// We don't have to fully hide this entry?
					{
						CGFloat	unusedWidth = [self bounds].size.width -usedWidth;
						unusedWidth -= UK_PATH_NAME_TOTAL_HMARGIN +UK_PATH_ARROW_IMG_WIDTH +UK_PATH_ICON_IMG_WIDTH +UK_PATH_ICON_NAME_HDISTANCE;
						if( unusedWidth > 0 )
						{
							if( unusedWidth < UK_MIN_TEXT_WIDTH )
								unusedWidth = 0;
							[currEntry setHidden: NO];
							[currEntry setDisplayWidth: unusedWidth +UK_PATH_NAME_TOTAL_HMARGIN +UK_PATH_ARROW_IMG_WIDTH +UK_PATH_ICON_IMG_WIDTH +UK_PATH_ICON_NAME_HDISTANCE];
						}
					}
				}
				else
				{
					currIdx = middleIndex +middleOffset;
					if( (currIdx < ([pathEntries count] -1)) && ![[pathEntries objectAtIndex: currIdx] isHidden] )	// -1 so we never eliminate the actual file we're supposed to show.
					{
						currEntry = [pathEntries objectAtIndex: currIdx];
						[currEntry setHidden: YES];
						SInt16	usedWidth = [self widthOfVisiblePathEntries];
						if( usedWidth < [self bounds].size.width )	// We don't have to fully hide this entry?
						{
							SInt16	unusedWidth = [self bounds].size.width -usedWidth;
							unusedWidth -= UK_PATH_NAME_TOTAL_HMARGIN +UK_PATH_ARROW_IMG_WIDTH +UK_PATH_ICON_IMG_WIDTH +UK_PATH_ICON_NAME_HDISTANCE;
							if( unusedWidth > 0 )
							{
								if( unusedWidth < UK_MIN_TEXT_WIDTH )
									unusedWidth = 0;
								[currEntry setHidden: NO];
								[currEntry setDisplayWidth: unusedWidth +UK_PATH_NAME_TOTAL_HMARGIN +UK_PATH_ARROW_IMG_WIDTH +UK_PATH_ICON_IMG_WIDTH +UK_PATH_ICON_NAME_HDISTANCE];
							}
						}
						middleOffset ++;
					}
					else
						middleOffset ++;
				}
			}
		}
	}
}


-(void) drawRect:(NSRect)rect
{
	NSPoint			pos = { 0, 0 };
	NSDictionary*   attribs = [self textAttributes];
	NSDictionary*   disAttribs = [self disabledTextAttributes];
	NSEnumerator*   enny = nil;
	NSString*		currName;
	NSSize			lineHeight = [@"foo" sizeWithAttributes: attribs];
	
	// Draw border and make sure text is vertically centered:
	if( borderType == NSBezelBorder )
		UKDrawDropHighlightedEditableWhiteBezel( drawDropHighlight, action != 0, [self bounds], [self bounds] );
	else if( drawDropHighlight )
	{
        NSRect	drawBox = NSInsetRect( [self bounds], 1, 1 );
        
        [[[NSColor selectedControlColor] colorWithAlphaComponent: 0.8] set];
        [NSBezierPath setDefaultLineWidth: 2];
        [NSBezierPath strokeRect: drawBox];
        [[NSColor blackColor] set];
	}
	pos.y += truncf(([self bounds].size.height -lineHeight.height) /2);
	
	// If no path specified, show "none":
	if( filePath == nil )
	{
		[placeholderString drawAtPoint: NSMakePoint(pos.x +4, pos.y +2) withAttributes: disAttribs];
		return;
	}
	
	// Draw components that are left:
	UKFilePathEntry *	currEntry = nil,
					*	lastEntry = [self lastVisiblePathEntry];
	BOOL				lastEntryWasHidden = NO;	// Usually, all are visible.
	int					x = 0;
	CGFloat				ellipsisWidth = [self ellipsisWidth];
	enny = [pathEntries objectEnumerator];

	while( (currEntry = [enny nextObject]) )
	{
		if( ![currEntry isHidden] )
		{
			if( lastEntryWasHidden )	// Draw ellipsis.
			{
				[[NSString stringWithFormat: @"%C", 0x2026] drawAtPoint: pos withAttributes: [self textAttributes]];
				pos.x += ellipsisWidth;
				[gUKFPVPathArrowImage dissolveToPoint: NSMakePoint(pos.x -UK_PATH_ARROW_IMG_WIDTH,pos.y) fraction: 1];
			}
			
			NSPoint		originalPos = pos;
			BOOL        exists = [[NSFileManager defaultManager] fileExistsAtPath: [currEntry path]];
			
			pos.x += UK_PATH_NAME_LEFT_MARGIN;
			[[currEntry icon] setSize: NSMakeSize(UK_PATH_ICON_IMG_WIDTH,UK_PATH_ICON_IMG_WIDTH)];
			[[currEntry icon] dissolveToPoint: NSMakePoint( pos.x, pos.y +UK_PATH_NAME_BOTTOM_MARGIN) fraction: (exists ? 1 : 0.3)];
			if( x == selectedPathEntry && exists )
				[[currEntry icon] compositeToPoint: NSMakePoint( pos.x, pos.y +UK_PATH_NAME_BOTTOM_MARGIN) operation: NSCompositePlusDarker];
			
			pos.x += UK_PATH_ICON_IMG_WIDTH +UK_PATH_ICON_NAME_HDISTANCE;
			
			[NSGraphicsContext saveGraphicsState];
				NSRect		clipBox = [self bounds];
				clipBox.origin.x = originalPos.x;
				clipBox.size.width = [currEntry displayWidth] -UK_PATH_ARROW_IMG_WIDTH -UK_PATH_NAME_RIGHT_MARGIN;
				BOOL	areTruncating = [currEntry width] != [currEntry displayWidth];
				if( areTruncating )
					UKSetUpOpposingFades( clipBox, 0, 20, YES );
						[[currEntry displayName] drawAtPoint: NSMakePoint(pos.x, pos.y +UK_PATH_NAME_BOTTOM_MARGIN) withAttributes: (exists ? attribs : disAttribs)];
				if( areTruncating )
					UKTearDownFades();
			[NSGraphicsContext restoreGraphicsState];
			
			pos.x = originalPos.x +[currEntry displayWidth] -UK_PATH_ARROW_IMG_WIDTH;
			if( currEntry != lastEntry )
				[gUKFPVPathArrowImage dissolveToPoint: pos fraction: 1];
			pos.x += UK_PATH_ARROW_IMG_WIDTH;
			
			lastEntryWasHidden = NO;
		}
		else
			lastEntryWasHidden = YES;
		
		x++;
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
		[self rebuildPathComponentArray];
		if( [self respondsToSelector: @selector(invalidateIntrinsicContentSize)] )
			[(id)self invalidateIntrinsicContentSize];
		[self setNeedsDisplay: YES];
		
		[self setToolTip: [self fullPathAsDisplayString]];
		[self accessibilitySetOverrideValue: NSAccessibilityTextFieldRole forAttribute: NSAccessibilityRoleAttribute];
		[self accessibilitySetOverrideValue: [self fullPathAsDisplayString] forAttribute: NSAccessibilityTitleAttribute];
	}
}


-(void) reshowDisplayNames: (id)sender
{
	noDisplayNames = NO;
	if( [self respondsToSelector: @selector(invalidateIntrinsicContentSize)] )
		[(id)self invalidateIntrinsicContentSize];
	[self setNeedsDisplay: YES];
}


-(void)	showRealNames: (id)sender
{
	if( !noDisplayNames )
	{
		noDisplayNames = YES;
		if( [self respondsToSelector: @selector(invalidateIntrinsicContentSize)] )
			[(id)self invalidateIntrinsicContentSize];
		[self setNeedsDisplay: YES];
		[NSTimer scheduledTimerWithTimeInterval: 5  // 5 secs should be enough.
					target: self selector:@selector(reshowDisplayNames:)
					userInfo:nil repeats: NO];
	}
}

-(void)	toggleShowRealNames: (id)sender
{
	noDisplayNames = !noDisplayNames;
	[self rebuildPathComponentArray];
	if( [self respondsToSelector: @selector(invalidateIntrinsicContentSize)] )
		[(id)self invalidateIntrinsicContentSize];
	[self setNeedsDisplay: YES];
}


-(void)	revealInFinder: (id)sender
{
	[[NSWorkspace sharedWorkspace] selectFile: filePath inFileViewerRootedAtPath: @""];
}


-(BOOL)	validateMenuItem: (NSMenuItem*)item
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


-(void) mouseDown: (NSEvent*)evt
{
	if( filePath )
	{
		NSPoint				pos = [evt locationInWindow];
		pos = [self convertPoint: pos fromView: nil];
		NSEvent*			currEvt = nil;
		NSAutoreleasePool*	pool = [[NSAutoreleasePool alloc] init];
		
		selectedPathEntry = [self indexOfPathEntryAtPoint: pos];
		[self setNeedsDisplay: YES];
		
		while( true )
		{
			currEvt = [NSApp nextEventMatchingMask: NSMouseMovedMask | NSLeftMouseDraggedMask | NSLeftMouseUpMask | NSAppKitDefined
														untilDate: [NSDate distantFuture] inMode: NSEventTrackingRunLoopMode dequeue: YES];
			
			if( currEvt )
			{
				pos = [currEvt locationInWindow];
				pos = [self convertPoint: pos fromView: nil];
				selectedPathEntry = [self indexOfPathEntryAtPoint: pos];
				[self setNeedsDisplay: YES];
				
				if( [currEvt type] == NSLeftMouseUp )
					break;
				else if( [currEvt type] == NSAppKitDefined )
					[NSApp sendEvent: currEvt];
				
				[pool release];
				pool = [[NSAutoreleasePool alloc] init];
			}
		}
		
		[pool release];
		
		if( selectedPathEntry != NSNotFound )
		{
			[[NSWorkspace sharedWorkspace] selectFile: [[pathEntries objectAtIndex: selectedPathEntry] path] inFileViewerRootedAtPath: @""];
			
			selectedPathEntry = NSNotFound;
			[self setNeedsDisplay: YES];
		}
	}
	else
		selectedPathEntry = NSNotFound;
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


-(NSMenu*)	menuForEvent: (NSEvent*)evt
{
	if( !allowContextMenu )
		return nil;
	else
		return [super menuForEvent: evt];
}


-(NSWindow*)	windowForSheet
{
	NSWindow*		theWindow = [self window];
	NSDocument*		currDoc = [[NSDocumentController sharedDocumentController] documentForWindow: theWindow];
	if( currDoc )
		theWindow = [currDoc windowForSheet];
	
	return theWindow;
}


// -----------------------------------------------------------------------------
//	pickFile:
//		Button action for showing an open panel to fill this field with the
//		path of any already existing file.
// -----------------------------------------------------------------------------

-(IBAction)			pickFile: (id)sender
{
	NSOpenPanel*	op = [NSOpenPanel openPanel];
	
	[op setAllowsMultipleSelection: allowsMultipleSelection];
	[op setCanChooseFiles: canChooseFiles];
	[op setCanChooseDirectories: canChooseDirectories];
	[op setTreatsFilePackagesAsDirectories: treatsFilePackagesAsDirectories];
	if( message )
		[op setMessage: message];
	
	[op beginSheetForDirectory: [filePath stringByDeletingLastPathComponent]
			file: filePath types: types modalForWindow: [self windowForSheet]
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
	
	if( directoryURL )
		[op setDirectoryURL: directoryURL];
	if( message )
		[op setMessage: message];
	[op setTreatsFilePackagesAsDirectories: treatsFilePackagesAsDirectories];
	
	[op beginSheetForDirectory: [filePath stringByDeletingLastPathComponent]
			file: filePath modalForWindow: [self windowForSheet]
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


-(BOOL)				allowsMultipleSelection
{
	return allowsMultipleSelection;
}


-(void)				setAllowsMultipleSelection: (BOOL)flag
{
	allowsMultipleSelection = flag;
}

-(NSURL*)			directoryURL
{
	return directoryURL;
}


-(void)				setDirectoryURL: (NSURL*)url
{
	if( directoryURL != url )
	{
		[directoryURL release];
		directoryURL = [url retain];
	}
}


-(NSString*)		message
{
	return message;
}


-(void)				setMessage: (NSString*)msg
{
	if( message != msg )
	{
		[message release];
		message = [msg retain];
	}
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
	NSDragOperation		op = NSDragOperationNone;
	if( acceptDrops )
	{
		drawDropHighlight = YES;
		[self setNeedsDisplay: YES];
		
		op = NSDragOperationLink;
	}

	return op;
}

-(BOOL)	prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	return acceptDrops;
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
	if( acceptDrops )
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
	}
	
	return acceptDrops;
}


-(void)	draggingExited:(id <NSDraggingInfo>)sender
{
	drawDropHighlight = NO;
	[self setNeedsDisplay: YES];
}


-(void)	setFrame: (NSRect)box
{
	[super setFrame: box];
	[self relayoutPathComponents];
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


-(void)			setBorderType: (NSBorderType)aType
{
	borderType = aType;
	[self setNeedsDisplay: YES];
}


-(NSBorderType)	borderType
{
	return borderType;
}


-(void)	setAcceptDrops: (BOOL)inAccept
{
	acceptDrops = inAccept;
}


-(BOOL)	acceptDrops
{
	return acceptDrops;
}


-(void)	setAllowContextMenu: (BOOL)doCMM
{
	allowContextMenu = doCMM;
}


-(BOOL)			allowContextMenu
{
	return allowContextMenu;
}


-(BOOL)	accessibilityIsIgnored
{
	return NO;
}


-(NSSize)	intrinsicContentSize
{
	NSSize	theSize = NSZeroSize;
	
	for( UKFilePathEntry*	entry in pathEntries )
	{
		theSize.width += [entry width];
	}
	
	theSize.height = [@"AgÜٳفשּׂי兩一" sizeWithAttributes: textAttributes].height;	// Measure a height that works with filenames from any country, even mixed.
	
	return theSize;
}


//- (NSArray *)accessibilityAttributeNames
//{
//
//}
//
//
//- (id)accessibilityAttributeValue:(NSString *)attribute;
//{
//	
//}

@end
