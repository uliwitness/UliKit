//
//  NSString+FetchNextLine.h
//  MayaFTP
//
//  Created by Uli Kusterer on Fri Aug 27 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSMutableString (UKFetchNextLine)

-(NSString*)	nextLine;       // Removes and returns the topmost line of this string, nil if there's no more text.
-(NSString*)    nextFullLine;   // Removes and returns the topmost line if it ends with a line break. If there's no line break in this string, returns nil.

@end
