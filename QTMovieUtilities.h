//
//  QTMovieUtilities.h
//  PixUp
//
//  Created by Uli Kusterer on 27.07.07.
//  Copyright 2007 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>


@interface QTMovie (UKUtilities)

+(QTMovie*)	movieByConcatenatingMovies: (NSArray*)movieList;	// NSArray of QTMovies.

@end
