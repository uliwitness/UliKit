//
//	UKNibOwner.m
//	CocoaTADS
//
//	Created by Uli Kusterer on 13.11.2004.
//	Copyright 2004 Uli Kusterer.
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

#import "UKNibOwner.h"


@implementation UKNibOwner

// -----------------------------------------------------------------------------
//  init:
//      Create this object and load NIB file. Note that for subclasses, this
//      is called before your subclass has been fully constructed. I know this
//      sucks, because awakeFromNib can't rely on stuff that's done in the
//      constructor. I'll probably change this eventually.
//
//  REVISIONS:
//      2004-12-23  UK  Documented.
// -----------------------------------------------------------------------------

-(id)	init
{
	return [self initWithNibName: [self nibFilename] owner: self];
}

-(id)	initWithNibName: (NSString*)nibName
{
	return [self initWithNibName: nibName owner: self];
}

-(id)	initWithNibName: (NSString*)nibName owner: (id)owner
{
	if( (self = [super init]) )
	{
		NSBundle*		mainB = [NSBundle bundleForClass: [self class]];
		if( nibName )
		{
			[mainB loadNibNamed: nibName owner: owner topLevelObjects: &topLevelObjects];
			[topLevelObjects retain];
		}
		if( nibName && [topLevelObjects count] == 0 )
		{
			mainB = [NSBundle mainBundle];
			if( nibName )
				[mainB loadNibNamed: nibName owner: owner topLevelObjects: &topLevelObjects];
			[topLevelObjects retain];
		}
		if( nibName && [topLevelObjects count] == 0 )
		{
			NSLog(@"%@: Couldn't find NIB file \"%@.nib\".", NSStringFromClass([self class]), nibName);
			[self autorelease];
			return nil;
		}
		
		if( owner != self )
			[self awakeFromNib];
	}
	
	return self;
}


-(void)	dealloc
{
	[topLevelObjects release];
	topLevelObjects = nil;
	
	[super dealloc];
}


-(void)	releaseTopLevelObjects
{
	[proxyController setContent: nil];
	[topLevelObjects release];
	topLevelObjects = nil;
}


// -----------------------------------------------------------------------------
//  nibFilename:
//      Return the filename (minus ".nib" suffix) for the NIB file to load.
//      Note that, if you subclass this, it will use the subclass's name, and
//      if you subclass that, the sub-subclass's name. So, you *may* want to
//      override this to return a constant string if you don't expect subclasses
//      to have their own similar-but-different NIB file.
//
//  REVISIONS:
//      2004-12-23  UK  Documented.
// -----------------------------------------------------------------------------

-(NSString*)    nibFilename
{
    return NSStringFromClass([self class]);
}

@end
