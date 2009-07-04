//
//  NSAttributedString+AppendImage.h
//  Shovel
//
//  Created by Uli Kusterer on 03.10.04.
//  Copyright 2004 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSMutableAttributedString (UKAppendImage)

-(void)	appendImage: (NSImage*)img;
-(void)	appendCenteredImage: (NSImage*)img;

@end


@interface NSCenteredTextAttachmentCell : NSTextAttachmentCell {}
@end