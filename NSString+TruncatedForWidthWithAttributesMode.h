//
//  NSString+TruncatedForWidthWithAttributesMode.h
//  xTableImage
//
//  Created by Uli Kusterer on 28.09.06.
//  Copyright 2006 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (UKTruncatedForWidthWithAttributesMode)

-(NSString*)	truncatedForWidth: (int)wid withAttributes: (NSDictionary*)attrs
					mode: (NSLineBreakMode)truncateMode;

@end
