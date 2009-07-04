//
//  NSStream+ReadWriteLine.h
//  RSSToPOP
//
//  Created by Uli Kusterer on 11.11.05.
//  Copyright 2005 Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSInputStream (UKReadWriteLine)

// Read one line into a string (reads until it encounters a "\r\n" sequence):
-(NSString*)	readOneLine;

@end

@interface NSOutputStream (UKReadWriteLine)

// Write one line to this stream (automatically adds the "\r\n" sequence onto the end):
-(void)			writeOneLine: (NSString*)lineStr;

@end
