//
//  NSFileHandle+UKReadLinewise.h
//  MayaFTP
//
//  Created by Uli Kusterer on Thu Aug 26 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "NSString+FetchNextLine.h"	// Used by .m, not really needed here.


@interface NSFileHandle (UKReadLinewise)

// endSelector must be of the form: -(void) fileHandle: (NSFileHandle*)sender didReadLine: (NSString*)currLine;
//	You're finished reading if currLine == nil.
-(void) readLinesToEndOfFileNotifyingTarget: (id)del newLineSelector: (SEL)sel;

@end
