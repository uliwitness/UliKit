//
//  NSColor+OpenGLExtensions.m
//  TheBigRedButton
//
//  Created by Uli Kusterer on 02.09.07.
//  Copyright 2007 M. Uli Kusterer. All rights reserved.
//

#import "NSColor+OpenGLExtensions.h"
#import <OpenGL/gl.h>

static GLuint		texName = 0;


GLuint	UKGetTextureFromImage( NSImage* theImg )
{
	NSBitmapImageRep*	bitmap = [NSBitmapImageRep alloc];
    int					samplesPerPixel = 0;
    NSSize				imgSize = [theImg size];
 
    [theImg lockFocus];
    [bitmap initWithFocusedViewRect:
                    NSMakeRect(0.0, 0.0, imgSize.width, imgSize.height)];
    [theImg unlockFocus];
 
    // Set proper unpacking row length for bitmap.
    glPixelStorei(GL_UNPACK_ROW_LENGTH, [bitmap pixelsWide]);
 
    // Set byte aligned unpacking (needed for 3 byte per pixel bitmaps).
    glPixelStorei (GL_UNPACK_ALIGNMENT, 1);
 
    // Generate a new texture name if one was not provided.
	texName = 0;
	glGenTextures( 1, &texName );
	
    glBindTexture( GL_TEXTURE_RECTANGLE_EXT, texName );
 
    // Non-mipmap filtering (redundant for texture_rectangle).
    glTexParameteri( GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_S, GL_REPEAT );
    glTexParameteri( GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_T, GL_REPEAT );
    samplesPerPixel = [bitmap samplesPerPixel];
	
    // Nonplanar, RGB 24 bit bitmap, or RGBA 32 bit bitmap.
    if(![bitmap isPlanar] &&
        (samplesPerPixel == 3 || samplesPerPixel == 4))
    {
        glTexImage2D( GL_TEXTURE_RECTANGLE_EXT, 0,
            samplesPerPixel == 4 ? GL_RGBA8 : GL_RGB8,
            [bitmap pixelsWide],
            [bitmap pixelsHigh],
            0,
            samplesPerPixel == 4 ? GL_RGBA : GL_RGB,
            GL_UNSIGNED_BYTE,
            [bitmap bitmapData]);
	    }
    else
    {
        NSLog(@"Wrong bitmap format.");
    }
 
    // Clean up.
    [bitmap release];
	
	return texName;
}


@implementation NSColor (UKOpenGLExtensions)

-(void)	setForGLContext
{
	NSString*	myColorSpace = [self colorSpaceName];
	if( myColorSpace == NSPatternColorSpace )
	{
		NSImage*		pattern = [self patternImage];
		GLuint			pat = UKGetTextureFromImage( pattern );
		glBindTexture( GL_TEXTURE_RECTANGLE_EXT, pat );
	}
	else
	{
		NSColor*	theColor = self;
		
		if( myColorSpace != NSDeviceRGBColorSpace && myColorSpace != NSCalibratedRGBColorSpace )
			theColor = [self colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
		
		GLfloat		red = 1.0, green = 1.0, blue = 1.0, alpha = 1.0;
		red = [theColor redComponent];
		green = [theColor greenComponent];
		blue = [theColor blueComponent];
		alpha = [theColor alphaComponent];
		
		glColor4f( red, green, blue, alpha );
	}
}

-(void)	setForClearingGLContext
{
	GLfloat		red = 1.0, green = 1.0, blue = 1.0, alpha = 1.0;
	NSString*	myColorSpace = [self colorSpaceName];
	NSColor*	theColor = self;
	
	if( myColorSpace != NSDeviceRGBColorSpace && myColorSpace != NSCalibratedRGBColorSpace )
		theColor = [self colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
	
	red = [theColor redComponent];
	green = [theColor greenComponent];
	blue = [theColor blueComponent];
	alpha = [theColor alphaComponent];
	
	glClearColor( red, green, blue, 1 -alpha );
}


@end
