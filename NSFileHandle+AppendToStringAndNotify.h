//
//  NSFileHandle+AppendToStringAndNotify.h
//  MayaFTP
//
//  Created by Uli Kusterer on Thu Aug 26 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSFileHandle (UKAppendToStringAndNotify)

// endSelector must be of the form: -(void) dataReadFrom: (NSFileHandle*)sender finished: (BOOL)finished;
-(void) readDataToEndOfFileIntoString: (NSMutableString*)str endSelector: (SEL)sel
										delegate: (id)del;

@end
