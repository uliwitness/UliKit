/* =============================================================================
	FILE:		UKAboutBox.m
	PROJECT:	Filie
    
    COPYRIGHT:  (c) 2003 M. Uli Kusterer, all rights reserved.
    
	AUTHORS:	M. Uli Kusterer - UK
    
    LICENSES:   GPL, Modified BSD

	REVISIONS:
		2003-12-29	UK	Created.
   ========================================================================== */

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import "UKAboutBox.h"
#ifndef SVN_VERSION // C string containing version number
#import "svn_version.h"
#endif
#include <time.h>


@implementation UKAboutBox

-(void) awakeFromNib
{
    // Load Credits.html file:
    NSDictionary*           dict = nil;
    NSAttributedString*     credits = [[[NSAttributedString alloc] initWithPath: [[NSBundle mainBundle] pathForResource: @"Credits" ofType: @"html"] documentAttributes: &dict] autorelease];
    if( !credits )
        credits = [[[NSAttributedString alloc] initWithPath: [[NSBundle mainBundle] pathForResource: @"Credits" ofType: @"rtf"] documentAttributes: &dict] autorelease];
    [[creditsTextView textStorage] setAttributedString: credits];
	
	#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_3
	if( [creditsTextView respondsToSelector: @selector(linkTextAttributes)] )
	{
		NSMutableDictionary*	linkAttribs = [[[creditsTextView linkTextAttributes] mutableCopy] autorelease];
		[linkAttribs setObject: [NSCursor pointingHandCursor] forKey: NSCursorAttributeName];
		[creditsTextView setLinkTextAttributes: linkAttribs];
	}
	#endif
	
    NSString*   vers = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"];
    NSString*   copyr = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"NSHumanReadableCopyright"];
    [versionTextField setStringValue: [NSString stringWithFormat: @"Version %@ (Build %s)\n%@", vers, SVN_VERSION, copyr]];

	[[creditsTextView window] center];
	[alternateAboutWindow center];
}

-(void) orderFront: (id)sender
{
	time_t		vTime;
	struct tm*	vTm;
	
	vTime = time(NULL);
	vTm = localtime( &vTime );
	
	NSImage*    img = nil;
	if( vTm->tm_hour < 4 || vTm->tm_hour > 20 )
		img = [NSImage imageNamed: ABOUT_NIGHTTIME_IMAGE];
	else if( vTm->tm_hour < 8 || vTm->tm_hour > 16 )
		img = [NSImage imageNamed: ABOUT_DUSKDAWN_IMAGE];
	else
		img = [NSImage imageNamed: ABOUT_DAYTIME_IMAGE];
	
	[aboutImageView setImage: img];

	[[creditsTextView window] makeKeyAndOrderFront: sender];
}

-(void)	orderFrontAlternate: (id)sender
{
	[alternateAboutWindow makeKeyAndOrderFront: sender];
}

-(BOOL) textView:(NSTextView *)textView clickedOnLink:(id)link atIndex:(unsigned)charIndex
{
    #if DEBUG
	NSRange     effRange;
    id theLink = [[textView textStorage] attribute: NSLinkAttributeName atIndex: charIndex effectiveRange: &effRange];
    UKLog( @"link: { %@, %@ }", link, theLink );
	#endif
    
    return YES;
}

@end
