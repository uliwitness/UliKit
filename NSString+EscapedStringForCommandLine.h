//
//  NSString+EscapedStringForCommandLine.h
//  MayaFTP
//
//  Created by Uli Kusterer on Fri Aug 27 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (UKEscapedStringForCommandLine)

-(NSString*)	escapedStringForCommandline;

@end


@interface NSMutableString (UKEscapeForCommandLine)

-(void)	escapeForCommandline;

@end
