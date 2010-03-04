//
//  UKViewBrowser.m
//  HoratioSings
//
//  Created by Uli Kusterer on 10.06.05.
//  Copyright 2005 Uli Kusterer.
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

#import "UKViewBrowser.h"


@implementation UKViewBrowser

-(id)   init
{
    self = [super init];
    if( self )
    {
        // Make sure we find out when the main window changes or when it gets closed:
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(windowBecameMain:) name: NSWindowDidBecomeMainNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(windowWillClose:) name: NSWindowWillCloseNotification object: nil];
    }
    
    return self;
}

// A new window became main, rebuild our list:
-(void) windowBecameMain: (NSNotification*)notif
{
    currentWindow = [notif object];
    [listView reloadData];
}

// A window is closing. If it's our current window, get rid of our reference before we access stale memory:
-(void) windowWillClose: (NSNotification*)notif
{
    if( currentWindow == [notif object] )
        currentWindow = nil;
    [listView reloadData];
}


// Find the root view in the window being watched:
-(NSView*)  bottomMostView
{
    NSView* currView = [currentWindow contentView];
    NSView* prevView = currView;
    
    while( (currView = [currView superview]) )
        prevView = currView;
    
    return prevView;
}


- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
    if( item == nil )
        return [self bottomMostView];
    else
        return [[item subviews] objectAtIndex: index];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if( item == nil )
        return( YES );
    else
        return( [[item subviews] count] > 0 );
}


- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if( item == nil )
        return( 1 );
    else
        return( [[item subviews] count] );

}


- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    NSString*   ident = [tableColumn identifier];
    
    if( [ident isEqualToString: @"class"] )
        return NSStringFromClass( [item class] );
    else if( [ident isEqualToString: @"hidden"] )
        return [NSNumber numberWithBool: [item isHidden]];
    else if( [ident isEqualToString: @"frame"] )
        return NSStringFromRect( [item frame] );
    else if( [ident isEqualToString: @"flipped"] )
        return [NSNumber numberWithBool: [item isFlipped]];
    else if( [ident isEqualToString: @"opaque"] )
        return [NSNumber numberWithBool: [item isOpaque]];
    else if( [ident isEqualToString: @"name"] )
    {
        if( [item respondsToSelector: @selector(stringValue)] )
            return [item stringValue];
        else if( [item respondsToSelector: @selector(string)] )
            return [item string];
        else if( item == [currentWindow contentView] )
            return @"CONTENT VIEW <===";
        else
            return @"--";
    }
    else
        return @"???";
}


@end
