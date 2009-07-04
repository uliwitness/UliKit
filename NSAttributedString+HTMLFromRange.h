//
//  NSAttributedString+HTMLFromRange.h
//  PosterChild
//
//  Created by Uli Kusterer on 22.03.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSAttributedString (UKHTMLFromRange)

-(NSString*)    HTMLFromRange: (NSRange) range;

@end
