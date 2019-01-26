//
//	UKAboutBox.m
//	Filie
//
//	Created by Uli Kusterer on 2003-12-29
//	Copyright 2003 Uli Kusterer.
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

#import "UKAboutBox.h"
#import "UKHelperMacros.h"
#import "svn_version.h"
#include <time.h>


@implementation UKAboutBox

-(void) awakeFromNib
{
    // Load Credits.html file:
	NSError *err = nil;
    NSDictionary *dict = nil;
	NSAttributedString *credits = [[[NSAttributedString alloc] initWithURL: [NSBundle.mainBundle URLForResource: @"Credits" withExtension: @"html"] options: @{} documentAttributes: &dict error: &err] autorelease];
	if( !credits ) {
		credits = [[[NSAttributedString alloc] initWithURL: [[NSBundle mainBundle] URLForResource: @"Credits" withExtension: @"rtf"] options: @{} documentAttributes: &dict error: &err] autorelease];
	}
    [[creditsTextView textStorage] setAttributedString: credits];
	
	NSMutableDictionary*	linkAttribs = [[[creditsTextView linkTextAttributes] mutableCopy] autorelease];
	[linkAttribs setObject: [NSCursor pointingHandCursor] forKey: NSCursorAttributeName];
	[creditsTextView setLinkTextAttributes: linkAttribs];
	
    NSString*   vers = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
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
