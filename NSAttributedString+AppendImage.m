//
//  NSAttributedString+AppendImage.m
//  Shovel
//
//  Created by Uli Kusterer on 03.10.04.
//  Copyright 2004 M. Uli Kusterer. All rights reserved.
//

#import "NSAttributedString+AppendImage.h"


@implementation NSMutableAttributedString (UKAppendImage)

-(void)	appendImage: (NSImage*)img
{
	NSFileWrapper*		fwrap = [[[NSFileWrapper alloc] initRegularFileWithContents: [img TIFFRepresentation]] autorelease];
	NSString*			imgName = [img name];
	if( !imgName )
		imgName = @"image";
	imgName = [imgName stringByAppendingPathExtension: @".tiff"];
	
	[fwrap setFilename: imgName];
	[fwrap setPreferredFilename: imgName];
	NSTextAttachment*	ta = [[[NSTextAttachment alloc] initWithFileWrapper: fwrap] autorelease];
	[self appendAttributedString: [NSAttributedString attributedStringWithAttachment: ta]];
}

-(void)	appendCenteredImage: (NSImage*)img
{
	NSFileWrapper*		fwrap = [[[NSFileWrapper alloc] initRegularFileWithContents: [img TIFFRepresentation]] autorelease];
	NSString*			imgName = [img name];
	if( !imgName )
		imgName = @"image";
	imgName = [imgName stringByAppendingPathExtension: @".tiff"];
	
	[fwrap setFilename: imgName];
	[fwrap setPreferredFilename: imgName];
	NSTextAttachment*	ta = [[[NSTextAttachment alloc] initWithFileWrapper: fwrap] autorelease];
	NSAttributedString*	str = [NSAttributedString attributedStringWithAttachment: ta];
	[self appendAttributedString: str];
	[self addAttribute: NSBaselineOffsetAttributeName value: [NSNumber numberWithInt: -([img size].height /2)]
			range: NSMakeRange([self length] -[str length], [str length])];
}

@end


@implementation NSCenteredTextAttachmentCell

/*-(NSPoint)	cellBaselineOffset
{
	NSSize	sz = [self cellSize];
	NSPoint	blo = [super cellBaselineOffset];
	
	blo.y -= 64;
	
	return blo;
}*/

@end
