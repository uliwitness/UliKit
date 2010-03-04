//
//  NSColor+OpenGLExtensions.m
//  TheBigRedButton
//
//  Created by Uli Kusterer on 02.09.07.
//  Copyright 2007 M. Uli Kusterer.
//
//	This software is provided 'as-is', without any express or implied
//	warranty. In no event will the authors be held liable for any damages
//	arising from the use of this software.
//
//	Permission is granted to anyone to use this software for any purpose,
//	including commercial applications, and to alter it and redistribute it
//	freely, subject to the following restrictions:
//
//	   1. The origin of this software must not be misrepresented; you must not
//	   claim that you wrote the original software. If you use this software
//	   in a product, an acknowledgment in the product documentation would be
//	   appreciated but is not required.
//
//	   2. Altered source versions must be plainly marked as such, and must not be
//	   misrepresented as being the original software.
//
//	   3. This notice may not be removed or altered from any source
//	   distribution.
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
