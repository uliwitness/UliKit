//
//  UKXMLToDictionary.h
//  MobileMoose
//
//  Created by Uli Kusterer on 13.07.08.
//  Copyright 2008 Uli Kusterer. All rights reserved.
//

/*
	Handy utility functions for turning XML into a dictionary that is a bit
	easier to work with. As an example:
	
	<foo>
		<bar>
			Welcome to Abu Dhabi
			<snort>50</snort>
		</bar>
		<bazzes>
			<baz>one</baz>
			<baz>two</baz>
			<baz>three</baz>
		</bazzes>
	</foo>
	
	will be turned into:
	
	{
		UKNameOfXMLTagKey = "foo"
		bar =
		{
			UKNameOfXMLTagKey = "bar"
			UKTextOfXMLTagKey = "Welcome to Abu Dhabi"
			snort = "50"
		}
		bazzes =
		{
			baz =
			(
				"one",
				"two",
				"three"
			)
		}
	}
	
	(where curly brackets indicate dictionaries, regular brackets indicate arrays)
*/

#import <Foundation/Foundation.h>


// The following keys share a namespace with the actual tag names, so should
//	be invalid XML tag names to avoid collisions:

#define UKNameOfXMLTagKey			@"  NAME"
#define UKTextOfXMLTagKey			@"  TEXT"


NSDictionary*	UKXMLDataToDictionary( NSData* inXMLData );
NSDictionary*	UKXMLStringToDictionary( NSString* inXMLString );
