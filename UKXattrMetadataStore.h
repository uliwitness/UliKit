//
//  UKXattrMetadataStore.h
//  BubbleBrowser
//
//  Created by Uli Kusterer on 12.03.06.
//  Copyright 2006 Uli Kusterer. All rights reserved.
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

#import <Cocoa/Cocoa.h>


/*!
 Keys (i.e. xattr names) are strings of 127 characters or less and
 should be composed like bundle identifiers, e.g. @"de.zathras.myattribute".
*/
extern const NSInteger ULIMaxXAttrKeyLength;


// -----------------------------------------------------------------------------
//	Class declaration:
// -----------------------------------------------------------------------------

NS_ASSUME_NONNULL_BEGIN

/*!
 This is a wrapper around The Mac OS X 10.4 and later xattr API that lets
 you attach arbitrary metadata to a file. Currently it allows querying and
 changing the attributes of a file, as well as retrieving a list of attribute
 names.
 
 It also includes some conveniences for storing/retrieving UTF8 strings,
 and objects as XML property lists in addition to the raw data.
*/

@interface UKXattrMetadataStore : NSObject

/*!
	@method		allKeysAtPath:traverseLink:
	@param		path
				The file to get xattr names from.
	@param		travLnk
				If <code>YES</code>, follows symlinks.
	@return		An \c NSArray of <code>NSString</code>s, or an empty array on failure.
	@discussion	Returns an \c NSArray of <code>NSString</code>s containing all xattr names currently set
				for the file at the specified path.
 */
+(NSArray<NSString*>*) allKeysAtPath: (NSString*)path traverseLink: (BOOL)travLnk DEPRECATED_MSG_ATTRIBUTE("Use '+allKeysAtPath:traverseLink:error:' instead.") NS_SWIFT_UNAVAILABLE("");

/*!
	@method		allKeysAtPath:traverseLink:
	@param		path
				The file to get xattr names from.
	@param		travLnk
				If <code>YES</code>, follows symlinks.
	@param		error
				If the method does not complete successfully, upon return
				contains an \c NSError object that describes the problem.
	@return		An \c NSArray of <code>NSString</code>s, or \c nil on failure.
	@discussion	Returns an \c NSArray of <code>NSString</code>s containing all xattr names currently set
				for the file at the specified path. Will return an empty \c NSArray if the file does not
				have any extended attributes.
 */
+(nullable NSArray<NSString*>*) allKeysAtPath: (NSString*)path traverseLink: (BOOL)travLnk error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(keys(path:traverseLink:));


#pragma mark Store UTF8 strings:
/*!
	@method		setString:forKey:atPath:traverseLink:
	@brief		Set the xattr with name \c key to the UTF8 representation of <code>str</code>.
	@param		str
				The string to set.
	@param		key
				the key to set \c str to.
	@param		path
				The file whose xattr you want to set.
	@param		travLnk
				If <code>YES</code>, follows symlinks.
	@discussion	Set the xattr with name key to an XML property list representation of
				the specified object (or object graph).
	@deprecated	This method throws an Obj-C exception. No other error information is provided, not even if it was successful.
 */
+(void) setString: (NSString*)str forKey: (NSString*)key
		   atPath: (NSString*)path traverseLink: (BOOL)travLnk DEPRECATED_MSG_ATTRIBUTE("Use '+setString:forKey:atPath:traverseLink:error:' instead.") NS_SWIFT_UNAVAILABLE("Use 'setString(_:forKey:atPath:traverseLink:) throws' instead");

/*!
	@method		setString:forKey:atPath:traverseLink:error:
	@brief		Set the xattr with name \c key to the UTF8 representation of <code>str</code>.
	@param		str
				The string to set.
	@param		key
				the key to set \c str to.
	@param		path
				The file whose xattr you want to set.
	@param		travLnk
				If <code>YES</code>, follows symlinks.
	@param		outError
				If the method does not complete successfully, upon return
				contains an \c NSError object that describes the problem.
	@return		\c YES on success, \c NO on failure.
	@discussion	Set the xattr with name \c key to the UTF8 representation of <code>str</code>.
 */
+(BOOL) setString: (NSString*)str forKey: (NSString*)key
		   atPath: (NSString*)path traverseLink: (BOOL)travLnk error: (NSError * _Nullable __autoreleasing * _Nullable)outError NS_SWIFT_NAME(setString(_:key:path:traverseLink:));

/*!
	@method		stringForKey:atPath:traverseLink:
	@brief		Get the xattr with name \c key as a UTF8 string.
	@param		key
				the key to set \c str to.
	@param		path
				The file whose xattr you want to get.
	@param		travLnk
				If <code>YES</code>, follows symlinks.
	@return		an \c NSString on succes, or \c nil on failure.
	@discussion	Get the xattr with name \c key as a UTF8 string.
	@deprecated	This method has no error handling.
 */
+(nullable NSString*) stringForKey: (NSString*)key atPath: (NSString*)path
					  traverseLink: (BOOL)travLnk DEPRECATED_MSG_ATTRIBUTE("Use '+stringForKey:atPath:traverseLink:error:' instead.") NS_SWIFT_UNAVAILABLE("Use 'string(forKey:atPath:traverseLink:) throws' instead");

/*!
	@method		stringForKey:atPath:traverseLink:error:
	@brief		Get the xattr with name \c key as a UTF8 string.
	@param		key
				the key to set \c str to.
	@param		path
				The file whose xattr you want to get.
	@param		travLnk
				If <code>YES</code>, follows symlinks.
	@param		error
				If the method does not complete successfully, upon return
				contains an \c NSError object that describes the problem.
	@return		an \c NSString on succes, or \c nil on failure.
	@discussion	Get the xattr with name \c key as a UTF-8 string.
 */
+(nullable NSString*) stringForKey: (NSString*)key atPath: (NSString*)path
					  traverseLink: (BOOL)travLnk error: (NSError**)error NS_SWIFT_NAME(string(key:path:traverseLink:));

#pragma mark Store raw data:
/*!
	@method		setData:forKey:atPath:traverseLink:
	@brief		Set the xattr with name \c key to the raw data in <code>data</code>.
	@param		data
				The data to set.
	@param		key
				the key to set \c data to.
	@param		path
				The file whose xattr you want to set.
	@param		travLnk
				If <code>YES</code>, follows symlinks.
	@discussion	Set the xattr with name key to an XML property list representation of
				the specified object (or object graph).
	@deprecated	This method has no way of indicating success or failure.
 */
+(void) setData: (NSData*)data forKey: (NSString*)key
		 atPath: (NSString*)path traverseLink: (BOOL)travLnk DEPRECATED_MSG_ATTRIBUTE("Use '+setData:forKey:atPath:traverseLink:error:' instead.") NS_SWIFT_UNAVAILABLE("Use 'setData(_:forKey:atPath:traverseLink:) throws' instead");
/*!
	@method		setData:forKey:atPath:traverseLink:error:
	@brief		Set the xattr with name \c key to the raw data in <code>data</code>.
	@param		data
				The data to set.
	@param		key
				the key to set \c data to.
	@param		path
				The file whose xattr you want to set.
	@param		travLnk
				If <code>YES</code>, follows symlinks.
	@param		error
				If the method does not complete successfully, upon return
				contains an \c NSError object that describes the problem.
	@return		\c YES on success, \c NO on failure.
	@discussion	Set the xattr with name \c key to the raw data in <code>data</code>.
 */
+(BOOL) setData: (NSData*)data forKey: (NSString*)key
		 atPath: (NSString*)path traverseLink: (BOOL)travLnk error: (NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(setData(_:key:path:traverseLink:));

/*!
	@method		dataForKey:atPath:traverseLink:
	@brief		Get the xattr with name \c key as raw data.
	@param		key
				the key to set \c str to.
	@param		path
				The file whose xattr you want to get.
	@param		travLnk
				If <code>YES</code>, follows symlinks.
	@return		an \c NSData containing the contents of \c key on succes, or \c nil on failure
	@discussion	Get the xattr with name \c key as a UTF8 string
	@deprecated	This method throws an Obj-C exception. No other error information is provoded on failure.
 */
+(nullable NSData*) dataForKey: (NSString*)key atPath: (NSString*)path
				  traverseLink: (BOOL)travLnk DEPRECATED_MSG_ATTRIBUTE("Use '+dataForKey:atPath:traverseLink:error:' instead.") NS_SWIFT_UNAVAILABLE("Use 'data(forKey:atPath:traverseLink:) throws' instead");
/*!
	@method		dataForKey:atPath:traverseLink:error:
	@brief		Get the xattr with name \c key as raw data.
	@param		key
				the key to set \c str to.
	@param		path
				The file whose xattr you want to get.
	@param		travLnk
				If <code>YES</code>, follows symlinks.
	@param		error
				If the method does not complete successfully, upon return
				contains an \c NSError object that describes the problem.
	@return		an \c NSData containing the contents of \c key on succes, or \c nil on failure
	@discussion	Get the xattr with name \c key as a UTF8 string
 */
+(nullable NSData*) dataForKey: (NSString*)key atPath: (NSString*)path
				  traverseLink: (BOOL)travLnk error: (NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(data(key:path:traverseLink:));

#pragma mark Store objects: (Only can get/set plist-type objects for now)‚
/*!
	@method		setObject:forKey:atPath:traverseLink:
	@param		obj
				The property list object to set.
	@param		key
				the key to set \c obj to.
	@param		path
				The file whose xattr you want to set.
	@param		travLnk
				If <code>YES</code>, follows symlinks.
	@discussion	Set the xattr with name key to an XML property list representation of
				the specified object (or object graph).
	@deprecated	This method throws an Obj-C exception. No other error information is provided,
				not even if it was successful.
 */
+(void) setObject: (id)obj forKey: (NSString*)key atPath: (NSString*)path
	 traverseLink: (BOOL)travLnk DEPRECATED_MSG_ATTRIBUTE("Use '+setPlist:asXMLForKey:atPath:traverseLink:error:' instead.") NS_SWIFT_UNAVAILABLE("Use 'setPlistAsXML(_:key:path:traverseLink:) throws' instead");

/*!
	@method		setPlist:asXMLForKey:atPath:traverseLink:error:
	@param		obj
				The Property List object to set.
	@param		key
				the key to assign \obj to.
	@param		path
				The file whose xattr you want to set.
	@param		travLnk
				If <code>YES</code>, follows symlinks.
	@param		error
				If the method does not complete successfully, upon return
				contains an \c NSError object that describes the problem.
	@return		\c YES on success, \c NO on failure.
	@discussion	Set the xattr with name \c key to an XML property list representation of
				the specified object (or object graph).
 */
+(BOOL) setPlist: (id)obj asXMLForKey: (NSString*)key atPath: (NSString*)path
	traverseLink: (BOOL)travLnk error: (NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(setPlistAsXML(_:key:path:traverseLink:));

/*!
	@method		objectForKey:atPath:traverseLink:
	@param		key
				the key whose value to retrieve.
	@param		path
				The file whose xattr you want to read.
	@param		travLnk
				If <code>YES</code>, follows symlinks.
	@discussion	Retrieve the xattr with name \c key and parse it as an XML
property list representation of
				the specified object (or object graph).
	@deprecated	This method throws an Obj-C exception. No other error information is provided,
				not even if it was successful.
 */
+(nullable id) objectForKey: (NSString*)key atPath: (NSString*)path traverseLink:(BOOL)travLnk DEPRECATED_MSG_ATTRIBUTE("Use '+plistForXMLInKey:atPath:traverseLink:error:' instead.") NS_SWIFT_UNAVAILABLE("Use 'plistFromXML(key:path:traverseLink:) throws' instead");

/*!
	@method		plistForXMLInKey:atPath:traverseLink:error:
	@brief		Get the xattr with name \c key as a property list
	@param		key
				the key to get the Property List object from.
	@param		path
				The file whose xattr you want to get.
	@param		travLnk
				If <code>YES</code>, follows symlinks.
	@param		outError
				If the method does not complete successfully, upon return
				contains an \c NSError object that describes the problem.
	@return		a Property List object from contents of \c key on succes, or \c nil on failure
	@discussion	Get the xattr with name \c key as a property list object (<code>NSString</code>, <code>NSArray</code>, etc...)<br>
				The data has to be stored as an XML property list.
 */
+(nullable id) plistForXMLInKey: (NSString*)key atPath: (NSString*)path
				   traverseLink: (BOOL)travLnk error:  (NSError * _Nullable __autoreleasing * _Nullable)outError NS_SWIFT_NAME(plistFromXML(key:path:traverseLink:));

@end

NS_ASSUME_NONNULL_END
