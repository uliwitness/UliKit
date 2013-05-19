//
//  UKCoordinateUtils.m
//  UKDockableWindow
//
//  Created by Uli Kusterer on Wed Feb 04 2004.
//  Copyright (c) 2004 M. Uli Kusterer.
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

#import "UKCoordinateUtils.h"


NSPoint  UKCenterOfRect( NSRect rect )
{
	return NSMakePoint( NSMidX(rect), NSMidY(rect) );
}

NSPoint  UKTopCenterOfRect( NSRect rect )
{
	return NSMakePoint( NSMidX(rect), NSMaxY(rect) );
}

NSPoint  UKTopLeftOfRect( NSRect rect )
{
	return NSMakePoint( NSMinX(rect),NSMaxY(rect) );
}

NSPoint  UKTopRightOfRect( NSRect rect )
{
	return NSMakePoint( NSMaxX(rect), NSMaxY(rect) );
}

NSPoint  UKLeftCenterOfRect( NSRect rect )
{
	return NSMakePoint( NSMinX(rect), NSMidY(rect) );
}

NSPoint  UKBottomCenterOfRect( NSRect rect )
{
	return NSMakePoint( NSMidX(rect), NSMinY(rect) );
}

NSPoint  UKBottomLeftOfRect( NSRect rect )
{
	return rect.origin;
}

NSPoint  UKBottomRightOfRect( NSRect rect )
{
	return NSMakePoint( NSMaxX(rect), NSMinY(rect) );
}

NSPoint  UKRightCenterOfRect( NSRect rect )
{
	return NSMakePoint( NSMaxX(rect), NSMidY(rect) );
}
 
