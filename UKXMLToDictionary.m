//
//  UKXMLToDictionary.m
//  MobileMoose
//
//  Created by Uli Kusterer on 13.07.08.
//  Copyright 2008 Uli Kusterer.
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
//	Headers:
// -----------------------------------------------------------------------------

#import "UKXMLToDictionary.h"


// -----------------------------------------------------------------------------
//	Helper Class:
// -----------------------------------------------------------------------------

@interface UKXMLToDictionaryDelegate : NSObject
{
	NSMutableDictionary*	parsedReply;		// Intermediate storage where we build up the dictionary during parsing.
	NSMutableArray*			currentTagStack;	// NSDictionaries referencing entries in parsedReply. 
}

@property (retain) NSMutableDictionary*	parsedReply;
@property (retain) NSMutableArray*		currentTagStack;


@end


// -----------------------------------------------------------------------------
//	UKXMLDataToDictionary:
//		Main bottleneck, kicks off the parser.
// -----------------------------------------------------------------------------

NSDictionary*	UKXMLDataToDictionary( NSData* inXMLData )
{
	NSXMLParser*	parser = [[[NSXMLParser alloc] initWithData: inXMLData] autorelease];
	UKXMLToDictionaryDelegate*	dele = [[[UKXMLToDictionaryDelegate alloc] init] autorelease];
		
	[parser setDelegate: dele];
	[parser parse];
	
	#if DEBUG
	//NSLog(@"%@", [[[NSString alloc] initWithData: inXMLData encoding: NSUTF8StringEncoding] autorelease]);
	//NSLog(@"%@", parsedReply);
	#endif
	
	return [[[dele parsedReply] retain] autorelease];
}


// -----------------------------------------------------------------------------
//	UKXMLStringToDictionary:
//		Convenience wrapper.
// -----------------------------------------------------------------------------

NSDictionary*	UKXMLStringToDictionary( NSString* inXMLString )
{
	NSData*	theData = [inXMLString dataUsingEncoding: NSUTF8StringEncoding];
	return UKXMLDataToDictionary( theData );
}



// -----------------------------------------------------------------------------
//	UKXMLToDictionaryDelegate:
// -----------------------------------------------------------------------------

@implementation UKXMLToDictionaryDelegate

@synthesize parsedReply;
@synthesize currentTagStack;

-(id)	init
{
	if(( self = [super init] ))
	{
		[self setParsedReply: nil];
		[self setCurrentTagStack: [NSMutableArray array]];
	}
	
	return self;
}


-(void)	dealloc
{
	[self setParsedReply: nil];
	[self setCurrentTagStack: nil];
	
	[super dealloc];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	//NSLog(@"%s",__PRETTY_FUNCTION__);
}


- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	//NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	//NSLog(@"%@", parsedReply);
	
	// New element started. Push it on our tag stack, and add it to the output
	//	dictionary, so future parse callbacks can work with it:
	NSMutableDictionary*		currDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
															elementName, UKNameOfXMLTagKey,
															nil];
	if( !parsedReply )	// Topmost element?
	{
		[self setParsedReply: currDict];		// Make this the root dictionary.
		[currentTagStack addObject: currDict];
	}
	else	// Otherwise, add it to the current dictionary, with its tag name as the key:
	{
		NSMutableDictionary*	containerDict = [currentTagStack lastObject];
		NSMutableArray*			list = [containerDict objectForKey: elementName];
		if( list != nil )	// Already have this key?
		{
			if( ![list isKindOfClass: [NSArray class]] )	// Single item? Create an array to hold existing item and new one.
			{
				NSMutableArray*		newList = [NSMutableArray arrayWithObject: list];
				list = newList;
			}
			
			[list addObject: currDict];	// Add this item to the array of items we already parsed.
			[containerDict setObject: list forKey: elementName];
			[currentTagStack addObject: currDict];
		}
		else	// No entry with this key yet? Add one with this object in it.
		{
			[containerDict setObject: currDict forKey: elementName];
			[currentTagStack addObject: currDict];
		}
	}
	//NSLog(@"%@", parsedReply);
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	//NSLog(@"%@", parsedReply);
	NSMutableDictionary*	currDict = [currentTagStack lastObject];
	[currentTagStack removeLastObject];
	
	// If this is a text range, collapse its dictionary into a plain string:
	NSString*	theText = [[currDict objectForKey: UKTextOfXMLTagKey] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if( [currDict count] == 2 && theText != nil )	// Text-only node?
	{
		NSMutableDictionary*	containerDict = [currentTagStack lastObject];
		NSString*				theKey = [currDict objectForKey: UKNameOfXMLTagKey];
		NSMutableArray*			list = [containerDict objectForKey: theKey];
		if( [list isKindOfClass: [NSArray class]] )	// If this key contains a list of items, put those in there:
		{
			NSUInteger	idx = [list indexOfObject: currDict];
			[list replaceObjectAtIndex: idx withObject: theText];
		}
		else	// Otherwise, replace the single object there with the string:
			[containerDict setObject: theText forKey: theKey];
	}
	else if( [theText length] == 0 )	// More contents besides text, but no text?
		[currDict removeObjectForKey: UKTextOfXMLTagKey];	// Remove the text entry.
	//NSLog(@"%@", parsedReply);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	// Add the text to whatever is the current tag:
	NSMutableDictionary*	currDict = [currentTagStack lastObject];
	NSMutableString*		bodyText = [currDict objectForKey: UKTextOfXMLTagKey];
	if( !bodyText )
	{
		bodyText = [[string mutableCopy] autorelease];
		[currDict setObject: bodyText forKey: UKTextOfXMLTagKey];
	}
	else
		[bodyText appendFormat: @" %@", string];
}

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString
{
	//NSLog( @"whitespace %@", whitespaceString );
}


@end
