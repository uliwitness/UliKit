/*
 *  UKXMLPersistence.c
 *  
 *
 *  Created by Uli Kusterer on 07.10.04.
 *  Copyright 2004 M. Uli Kusterer. All rights reserved.
 *
 */

#include "UKXMLPersistence.h"

enum
{
	UK_XML_TOKEN_START_TAG,
	UK_XML_TOKEN_END_TAG,
	UK_XML_TOKEN_DATA,
	UK_XML_TOKEN_UNKNOWN
};


struct UKXMLWriteOutData
{
	CFMutableStringRef	outStr;			// The string we're writing to.
	unsigned int		depth;			// Depth so we can properly indent.
	unsigned int		flags;			// Flags that modify behavior.
};


#if 0
#define UK_XML_SHOWSTR(s)	{ char tmp[1024]; CFStringGetCString( (s), tmp, 1024, kCFStringEncodingUTF8 ); printf("\"%s\"\n",tmp); }
#else
#define UK_XML_SHOWSTR(s)	// (s)
#endif

void	UKWriteArrayItemToXML( const CFTypeRef value, struct UKXMLWriteOutData* data );



// CFStringFindAndReplace Is only available in 10.2 and later, so we roll our own:
void	UKFindAndReplace( CFMutableStringRef target, CFStringRef pattern, CFStringRef newStr )
{
	CFRange	searchRange = { 0, 0 },
			foundRange;
	CFIndex	newLen = CFStringGetLength(newStr);
	
	searchRange.length = CFStringGetLength( target );
	while( CFStringFindWithOptions( target, pattern, searchRange, 0, &foundRange ) )
	{
		CFStringReplace( target, foundRange, newStr );
		searchRange.location += foundRange.location +newLen;
		searchRange.length = CFStringGetLength(target) -searchRange.location;
	}
}


void	UKExpandXMLEntities( CFMutableStringRef s )
{
	UKFindAndReplace( s, CFSTR("&lt;"), CFSTR("<") );
	UKFindAndReplace( s, CFSTR("&gt;"), CFSTR(">") );
	UKFindAndReplace( s, CFSTR("&quot;"), CFSTR("\"") );
	UKFindAndReplace( s, CFSTR("&amp;"), CFSTR("&") );
}


void	UKXMLEntities( CFMutableStringRef s )
{
	UKFindAndReplace( s, CFSTR("&"), CFSTR("&amp;") );
	UKFindAndReplace( s, CFSTR("<"), CFSTR("&lt;") );
	UKFindAndReplace( s, CFSTR(">"), CFSTR("&gt;") );
	UKFindAndReplace( s, CFSTR("\""), CFSTR("&quot;") );
	
}


CFTypeRef	UKReadSubXMLData( CFStringRef padStr, CFIndex *x, CFMutableStringRef inStartToken, CFStringRef* arrayKeys )
{
	CFIndex					len = CFStringGetLength( padStr );
	int						state = UK_XML_TOKEN_DATA;
	CFMutableDictionaryRef	dict = NULL;
	CFMutableArrayRef		arr = NULL;
	CFMutableStringRef		startToken = NULL;
	CFMutableStringRef		currToken = CFStringCreateMutable( kCFAllocatorDefault, 0 );
	CFMutableStringRef		currData = NULL;
	int						slashIndex = -1, n = 0;
	
	UK_XML_SHOWSTR( inStartToken );
	
	while( arrayKeys && arrayKeys[n] )
	{
		if( CFStringCompare( inStartToken, arrayKeys[n], 0 ) == 0 )
		{
			arr = CFArrayCreateMutable( kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks );
			break;
		}
		n++;
	}
	
	if( !arr )
		dict = CFDictionaryCreateMutable( kCFAllocatorDefault, 0,
											&kCFCopyStringDictionaryKeyCallBacks,
											&kCFTypeDictionaryValueCallBacks );
	
	for( (*x)++; *x < len; (*x)++ )
	{
		UniChar ch = CFStringGetCharacterAtIndex( padStr, *x );
		
		switch( ch )
		{
			case '<':
				if( state == UK_XML_TOKEN_UNKNOWN )
				{
					if( currToken )
						CFRelease( currToken );
					currToken = CFStringCreateMutable( kCFAllocatorDefault, 0 );
					state = UK_XML_TOKEN_START_TAG;
				}
				else if( state == UK_XML_TOKEN_DATA )
				{
					currData = currToken;
					currToken = CFStringCreateMutable( kCFAllocatorDefault, 0 );
					state = UK_XML_TOKEN_END_TAG;
					slashIndex = -1;
				}
				break;
			
			case '>':
				if( state == UK_XML_TOKEN_START_TAG
					&& (slashIndex == -1 || slashIndex == CFStringGetLength(currToken)) )
				{
					startToken = currToken;
					CFStringTrimWhitespace(startToken);
					currToken = CFStringCreateMutable( kCFAllocatorDefault, 0 );
					UK_XML_SHOWSTR( startToken );
					if( slashIndex == -1 )	// Regular start tag.
						state = UK_XML_TOKEN_DATA;
					else	// Start tag with integrated end tag.
					{
						CFDictionaryAddValue( dict, startToken, CFSTR("") );
						CFRelease( startToken );
						startToken = NULL;
						state = UK_XML_TOKEN_UNKNOWN;
					}
					slashIndex = -1;
				}
				else if( state == UK_XML_TOKEN_END_TAG )
				{
					if( slashIndex == 0
						&& startToken != NULL
						&& CFStringCompare( currToken, startToken, kCFCompareCaseInsensitive ) == 0 )
					{
						UK_XML_SHOWSTR( currData );
						UK_XML_SHOWSTR( startToken );
						CFRelease( currToken );
						currToken = CFStringCreateMutable( kCFAllocatorDefault, 0 );
						UKExpandXMLEntities(currData);
						if( dict )
							CFDictionaryAddValue( dict, startToken, currData );
						else
							CFArrayAppendValue( arr, currData );
						CFRelease( currData );
						currData = NULL;
						CFRelease( startToken );
						startToken = NULL;
						state = UK_XML_TOKEN_UNKNOWN;
					}
					else if( slashIndex == 0 && startToken == NULL && ((dict && CFDictionaryGetCount(dict) == 0)
																	|| (arr && CFArrayGetCount(arr) == 0)) )
					{
						if( currToken )
							CFRelease( currToken );
						if( dict )
							CFRelease( dict );
						if( arr )
							CFRelease( arr );
						
						UKExpandXMLEntities(currData);
						
						return currData;
					}
					else if( slashIndex == 0 )
					{
						if( currToken )
							CFRelease( currToken );
						if( startToken )
							CFRelease( startToken );
						if( currData )
							CFRelease( currData );
						
						if( dict )
							return dict;		// Just ate owner's end tag.
						else
							return arr;			// Just ate owner's end tag.
					}
					else	// No slash? This is beginning tag for sub-object:
					{
						if( currData )
							UK_XML_SHOWSTR( currData );
						
						if( slashIndex != -1 && slashIndex == CFStringGetLength(currToken) )
						{
							CFStringTrimWhitespace(currToken);
							
							UK_XML_SHOWSTR( currToken );
							
							if( dict )
								CFDictionaryAddValue( dict, currToken, CFSTR("") );
							else
								CFArrayAppendValue( arr, CFSTR("") );
							state = UK_XML_TOKEN_DATA;
							if( currData )
							{
								CFRelease( currData );
								currData = CFStringCreateMutable( kCFAllocatorDefault, 0 );
							}
							CFRelease( currToken );
							currToken = CFStringCreateMutable( kCFAllocatorDefault, 0 );
							slashIndex = -1;
						}
						else
						{
							if( !startToken )
							{
								CFStringTrimWhitespace(currToken);
								CFTypeRef	dict2 = UKReadSubXMLData( padStr, x, currToken, arrayKeys );
								if( dict )
									CFDictionaryAddValue( dict, currToken, dict2 );
								else
									CFArrayAppendValue( arr, dict2 );
								CFRelease( dict2 );
								state = UK_XML_TOKEN_DATA;
								if( currData )
								{
									CFRelease( currData );
									currData = CFStringCreateMutable( kCFAllocatorDefault, 0 );
								}
								CFRelease( currToken );
								currToken = CFStringCreateMutable( kCFAllocatorDefault, 0 );
							}
							else
							{
								if( currToken )
									UK_XML_SHOWSTR( currToken );
								
								CFTypeRef	dict2 = UKReadSubXMLData( padStr, x, startToken, arrayKeys );
								if( dict )
									CFDictionaryAddValue( dict, startToken, dict2 );
								else
									CFArrayAppendValue( arr, dict2 );
								CFRelease( dict2 );
								CFRelease( startToken );
								startToken = NULL;
								CFRelease( currToken );
								currToken = CFStringCreateMutable( kCFAllocatorDefault, 0 );
							}
						}
					}
				}
				else if( slashIndex == 0 )
				{
					if( currToken )
						CFRelease( currToken );
					if( startToken )
						CFRelease( startToken );
					if( currData )
						CFRelease( currData );
					
					if( dict )
						return dict;		// Just ate owner's end tag.
					else
						return arr;
				}
				break;
			
			case '/':
				if( state == UK_XML_TOKEN_START_TAG || state == UK_XML_TOKEN_END_TAG )
					slashIndex = CFStringGetLength(currToken);
				else if( state != UK_XML_TOKEN_UNKNOWN && currToken != NULL )
					CFStringAppendCharacters( currToken, &ch, 1 );
				break;
			
			default:
				if( state != UK_XML_TOKEN_UNKNOWN && currToken != NULL )
					CFStringAppendCharacters( currToken, &ch, 1 );
				break;
		}
	}
	
	if( currToken )
		CFRelease( currToken );
	if( startToken )
		CFRelease( startToken );
	if( currData )
		CFRelease( currData );
	
	if( dict )
		return dict;
	else
		return arr;
}


CFDictionaryRef	UKCreateDictionaryFromXML( CFStringRef padStr, CFStringRef* arrayKeys, unsigned int flags )
{
	CFIndex					x = 0,
							len = CFStringGetLength( padStr );
	int						state = UK_XML_TOKEN_UNKNOWN;
	CFMutableDictionaryRef	dict = CFDictionaryCreateMutable( kCFAllocatorDefault, 0,
																&kCFCopyStringDictionaryKeyCallBacks,
																&kCFTypeDictionaryValueCallBacks );
	CFMutableStringRef		currToken = NULL;
	UniChar					ch;
	int						slashIndex = -1;
	
	for( x = 0; x < len; x++ )
	{
		ch = CFStringGetCharacterAtIndex( padStr, x );
		
		switch( ch )
		{
			case '<':
				if( state == UK_XML_TOKEN_UNKNOWN )
				{
					currToken = CFStringCreateMutable( kCFAllocatorDefault, 0 );
					state = UK_XML_TOKEN_START_TAG;
				}
				break;
			
			case '>':
				if( state == UK_XML_TOKEN_START_TAG )
				{
					UK_XML_SHOWSTR( currToken );
					if( CFStringGetCharacterAtIndex( currToken, 0 ) == '?'
						&& CFStringGetCharacterAtIndex( currToken, CFStringGetLength(currToken) -1 ) == '?' )
					{
						CFStringTrimWhitespace(currToken);
						if( CFStringHasPrefix( currToken, CFSTR("?xml") ) )
						{
							if( (flags & kUKXMLNoXMLHeadTag) == 0 )
								CFDictionaryAddValue( dict, CFSTR("?xml"), currToken );
						}
						else
							CFDictionaryAddValue( dict, currToken, CFSTR("") );
					}
					else
					{
						CFStringTrimWhitespace(currToken);
						CFTypeRef	dict2 = UKReadSubXMLData( padStr, &x, currToken, arrayKeys );
						CFDictionaryAddValue( dict, currToken, dict2 );
						CFRelease( dict2 );
					}
					CFRelease( currToken );
					currToken = NULL;
					state = UK_XML_TOKEN_UNKNOWN;
				}
				break;
			
			default:
				if( state != UK_XML_TOKEN_UNKNOWN )
					CFStringAppendCharacters( currToken, &ch, 1 );
				break;
		}
	}
	
	if( currToken )
		CFRelease( currToken );
	
	return dict;
}


void	UKXMLIndentByTabs( CFMutableStringRef s, unsigned int count )
{
	UniChar				spaces[10] = { '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t' };
	unsigned int		x = 0,
						chunk = 10;

	//CFStringAppendFormat( s, NULL, CFSTR("%u:"), count );

	while( x < count )
	{
		x += 10;
		if( x > count )
			chunk -= x -count;
		
		CFStringAppendCharacters( s, spaces, chunk );
	}
}


void	UKWriteDictionaryItemToXML( const CFTypeRef key, const CFTypeRef value, struct UKXMLWriteOutData* data )
{
	CFMutableStringRef	theKey = CFStringCreateMutableCopy( kCFAllocatorDefault, 0, key );
	CFMutableStringRef	theValue = NULL;
	UKXMLEntities( theKey );
	
	if( CFDictionaryGetTypeID() == CFGetTypeID(value) )
	{
		if( (data->flags & kUKXMLDontIndent) == 0 )
			UKXMLIndentByTabs( data->outStr, data->depth );
		CFStringAppend( data->outStr, CFSTR("<") );
		CFStringAppend( data->outStr, theKey );
		CFStringAppend( data->outStr, CFSTR(">\n") );
		data->depth++;
		CFDictionaryApplyFunction( value, (CFDictionaryApplierFunction) UKWriteDictionaryItemToXML, data );
		data->depth--;
		if( (data->flags & kUKXMLDontIndent) == 0 )
			UKXMLIndentByTabs( data->outStr, data->depth );
		CFStringAppend( data->outStr, CFSTR("</") );
		CFStringAppend( data->outStr, theKey );
		CFStringAppend( data->outStr, CFSTR(">\n") );
	}
	else if( CFArrayGetTypeID() == CFGetTypeID(value) )
	{
		CFRange	r = { 0, 0 };
		r.length = CFArrayGetCount(value);
		if( (data->flags & kUKXMLDontIndent) == 0 )
			UKXMLIndentByTabs( data->outStr, data->depth );
		CFStringAppend( data->outStr, CFSTR("<") );
		CFStringAppend( data->outStr, theKey );
		CFStringAppend( data->outStr, CFSTR(">\n") );
		data->depth++;
			CFArrayApplyFunction( value, r, (CFArrayApplierFunction) UKWriteArrayItemToXML, data );
		data->depth--;
		if( (data->flags & kUKXMLDontIndent) == 0 )
			UKXMLIndentByTabs( data->outStr, data->depth );
		CFStringAppend( data->outStr, CFSTR("</") );
		CFStringAppend( data->outStr, theKey );
		CFStringAppend( data->outStr, CFSTR(">\n") );
	}
	else if( CFStringGetTypeID() == CFGetTypeID(value) )
	{
		if( CFStringCompare( theKey, CFSTR("?xml"), 0 ) == 0 )
		{
			if( (data->flags & kUKXMLDontIndent) == 0 )
				UKXMLIndentByTabs( data->outStr, data->depth );
			
			CFStringAppend( data->outStr, CFSTR("<") );
			CFStringAppend( data->outStr, value );
			CFStringAppend( data->outStr, CFSTR(">\n") );
		}
		else
		{
			theValue = CFStringCreateMutableCopy( kCFAllocatorDefault, 0, value );
			UKXMLEntities( theValue );
			
			if( CFStringGetLength(theValue) == 0 )
			{
				if( (data->flags & kUKXMLNoEmptyTags) == 0 )
				{
					if( (data->flags & kUKXMLDontIndent) == 0 )
						UKXMLIndentByTabs( data->outStr, data->depth );
					
					CFStringAppend( data->outStr, CFSTR("<") );
					CFStringAppend( data->outStr, theKey );
					CFStringAppend( data->outStr, CFSTR("/>\n") );
				}
			}
			else
			{
				if( (data->flags & kUKXMLDontIndent) == 0 )
					UKXMLIndentByTabs( data->outStr, data->depth );
				
				CFStringAppend( data->outStr, CFSTR("<") );
				CFStringAppend( data->outStr, theKey );
				CFStringAppend( data->outStr, CFSTR(">") );
					CFStringAppend( data->outStr, theValue );
				CFStringAppend( data->outStr, CFSTR("</") );
				CFStringAppend( data->outStr, theKey );
				CFStringAppend( data->outStr, CFSTR(">\n") );
			}
		}
	}
	else
	{
		CFStringRef theStr = CFCopyDescription( value );
		theValue = CFStringCreateMutableCopy( kCFAllocatorDefault, 0, theStr );
		UKXMLEntities( theValue );
		
		if( (data->flags & kUKXMLDontIndent) == 0 )
			UKXMLIndentByTabs( data->outStr, data->depth );
		
		CFStringAppend( data->outStr, CFSTR("<") );
		CFStringAppend( data->outStr, theKey );
		CFStringAppend( data->outStr, CFSTR(">") );
			CFStringAppend( data->outStr, theValue );
		CFStringAppend( data->outStr, CFSTR("</") );
		CFStringAppend( data->outStr, theKey );
		CFStringAppend( data->outStr, CFSTR(">\n") );
		
		CFRelease( theStr );
	}
	
	CFRelease( theKey );
	if( theValue )
		CFRelease( theValue );
}


void	UKWriteArrayItemToXML( const CFTypeRef value, struct UKXMLWriteOutData* data )
{
	CFMutableStringRef	theValue = NULL;
	CFStringRef			theKey = CFSTR("item");
	
	if( CFDictionaryGetTypeID() == CFGetTypeID(value) )
	{
		if( (data->flags & kUKXMLDontIndent) == 0 )
			UKXMLIndentByTabs( data->outStr, data->depth );
		CFStringAppend( data->outStr, CFSTR("<") );
		CFStringAppend( data->outStr, theKey );
		CFStringAppend( data->outStr, CFSTR(">\n") );
		data->depth++;
			CFDictionaryApplyFunction( value, (CFDictionaryApplierFunction) UKWriteDictionaryItemToXML, data );
		data->depth--;
		if( (data->flags & kUKXMLDontIndent) == 0 )
			UKXMLIndentByTabs( data->outStr, data->depth );
		CFStringAppend( data->outStr, CFSTR("</") );
		CFStringAppend( data->outStr, theKey );
		CFStringAppend( data->outStr, CFSTR(">\n") );
	}
	else if( CFArrayGetTypeID() == CFGetTypeID(value) )
	{
		CFRange	r = { 0, 0 };
		r.length = CFArrayGetCount(value);
		if( (data->flags & kUKXMLDontIndent) == 0 )
			UKXMLIndentByTabs( data->outStr, data->depth );
		CFStringAppend( data->outStr, CFSTR("<") );
		CFStringAppend( data->outStr, theKey );
		CFStringAppend( data->outStr, CFSTR(">\n") );
		data->depth++;
			CFArrayApplyFunction( value, r, (CFArrayApplierFunction) UKWriteArrayItemToXML, data );
		data->depth--;
		if( (data->flags & kUKXMLDontIndent) == 0 )
			UKXMLIndentByTabs( data->outStr, data->depth );
		CFStringAppend( data->outStr, CFSTR("</") );
		CFStringAppend( data->outStr, theKey );
		CFStringAppend( data->outStr, CFSTR(">\n") );
	}
	else if( CFStringGetTypeID() == CFGetTypeID(value) )
	{
		theValue = CFStringCreateMutableCopy( kCFAllocatorDefault, 0, value );
		UKXMLEntities( theValue );
		
		if( CFStringGetLength(theValue) == 0 )
		{
			if( (data->flags & kUKXMLNoEmptyTags) == 0 )
			{
				if( (data->flags & kUKXMLDontIndent) == 0 )
					UKXMLIndentByTabs( data->outStr, data->depth );
				
				CFStringAppend( data->outStr, CFSTR("<") );
				CFStringAppend( data->outStr, theKey );
				CFStringAppend( data->outStr, CFSTR("/>\n") );
			}
		}
		else
		{
			if( (data->flags & kUKXMLDontIndent) == 0 )
				UKXMLIndentByTabs( data->outStr, data->depth );
			
			CFStringAppend( data->outStr, CFSTR("<") );
			CFStringAppend( data->outStr, theKey );
			CFStringAppend( data->outStr, CFSTR(">") );
				CFStringAppend( data->outStr, theValue );
			CFStringAppend( data->outStr, CFSTR("</") );
			CFStringAppend( data->outStr, theKey );
			CFStringAppend( data->outStr, CFSTR(">\n") );
		}
	}
	else
	{
		CFStringRef theStr = CFCopyDescription( value );
		theValue = CFStringCreateMutableCopy( kCFAllocatorDefault, 0, theStr );
		UKXMLEntities( theValue );
		
		if( (data->flags & kUKXMLDontIndent) == 0 )
			UKXMLIndentByTabs( data->outStr, data->depth );
		
		CFStringAppend( data->outStr, CFSTR("<") );
		CFStringAppend( data->outStr, theKey );
		CFStringAppend( data->outStr, CFSTR(">") );
			CFStringAppend( data->outStr, theValue );
		CFStringAppend( data->outStr, CFSTR("</") );
		CFStringAppend( data->outStr, theKey );
		CFStringAppend( data->outStr, CFSTR(">\n") );
		
		CFRelease( theStr );
	}
	
	if( theValue )
		CFRelease( theValue );
}



CFStringRef	UKCreateXMLFromDictionary( CFDictionaryRef ref, unsigned int flags )
{
	struct UKXMLWriteOutData	data = { NULL, 0, flags };
	
	data.outStr = CFStringCreateMutable( kCFAllocatorDefault, 0 );
	
	CFDictionaryApplyFunction( ref, (CFDictionaryApplierFunction) UKWriteDictionaryItemToXML, &data );
	
	if( (flags & kUKXMLNoXMLHeadTag) == 0 &&
		!CFDictionaryContainsKey(ref,CFSTR("?xml")) )
	{
		CFStringInsert( data.outStr, 0, CFSTR("<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n") );
	}
	
	return data.outStr;
}

