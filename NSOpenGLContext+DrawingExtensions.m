//
//  NSOpenGLContext+DrawingExtensions.m
//  TheBigRedButton
//
//  Created by Uli Kusterer on 02.09.07.
//  Copyright 2007 M. Uli Kusterer. All rights reserved.
//

#import "NSOpenGLContext+DrawingExtensions.h"
#import <OpenGL/gl.h>


@implementation NSOpenGLContext (UKDrawingExtensions)

-(void)		fillQuad: (UK3DQuad)quad
{
	glBegin(GL_QUADS);	// 01 11 10 00
		glTexCoord2f(0.0f, 0.0f);
		glVertex3f( quad.a.x, quad.a.y, quad.a.z );
		glTexCoord2f( quad.b.x -quad.a.x, 0.0f);
		glVertex3f( quad.b.x, quad.b.y, quad.b.z );	
		glTexCoord2f( quad.b.x -quad.a.x, quad.a.y -quad.c.y);
		glVertex3f( quad.c.x, quad.c.y, quad.c.z );
		glTexCoord2f(0.0f, quad.a.y -quad.c.y);
		glVertex3f( quad.d.x, quad.d.y, quad.d.z );
	glEnd();
}


-(void)		fillQuadReflection: (UK3DQuad)quad
{
	GLfloat		height = quad.a.y -quad.c.y,
				halfHeight = height / 2;
	
	glBegin(GL_QUADS);	// 01 11 10 00
		glColor4f( 1.0, 1.0, 1.0, 0.3 );
		glTexCoord2f(0.0f, height);
		glVertex3f( quad.a.x, quad.a.y -height, quad.a.z );
		glTexCoord2f( quad.b.x -quad.a.x, height);
		glVertex3f( quad.b.x, quad.b.y -height, quad.b.z );	
		glTexCoord2f( quad.b.x -quad.a.x, 0.0f);
		glColor4f( 1.0, 1.0, 1.0, 0.0 );
		glVertex3f( quad.c.x, quad.c.y -halfHeight, quad.c.z );
		glTexCoord2f(0.0f, 0.0f);
		glVertex3f( quad.d.x, quad.d.y -halfHeight, quad.d.z );
		glColor4f( 1.0, 1.0, 1.0, 1.0 );
	glEnd();
}


-(void)		fillQuadShadow: (UK3DQuad)quad
{
	GLfloat		height = quad.a.y -quad.c.y,
				halfHeight = height / 8,
				quarterHeight = halfHeight / 2;
	
	glBegin(GL_QUADS);	// 01 11 10 00
		glColor4f( 0, 0, 0, 0.05 );
		glTexCoord2f(0.0f, 0.0f);
		glVertex3f( quad.a.x, quad.a.y -height +(quarterHeight *3), quad.a.z );
		glTexCoord2f( quad.b.x -quad.a.x, 0.0f);
		glVertex3f( quad.b.x, quad.b.y -height +(quarterHeight *3), quad.b.z );	
		glColor4f( 0, 0, 0, 0.1 );
		glTexCoord2f( quad.b.x -quad.a.x, height);
		glVertex3f( quad.c.x, quad.c.y, quad.c.z );
		glTexCoord2f(0.0f, height);
		glVertex3f( quad.d.x, quad.d.y, quad.d.z );
		glColor4f( 1.0, 1.0, 1.0, 1.0 );
	glEnd();
}


@end
