//
//  QTMovieUtilities.m
//  PixUp
//
//  Created by Uli Kusterer on 27.07.07.
//  Copyright 2007 M. Uli Kusterer. All rights reserved.
//

#import "QTMovieUtilities.h"


@implementation QTMovie (UKUtilities)

+(QTMovie*)	movieByConcatenatingMovies: (NSArray*)movieList
{
	QTMovie*	finalMovie = [QTMovie movie];
	[finalMovie setAttribute: [NSNumber numberWithBool: YES] forKey: QTMovieEditableAttribute];
	
	NSEnumerator*	enny = [movieList objectEnumerator];
	QTMovie*		currMovie = nil;
	
	while(( currMovie = [enny nextObject] ))
		[finalMovie insertSegmentOfMovie: currMovie timeRange: QTMakeTimeRange(QTZeroTime,[currMovie duration]) atTime: [finalMovie duration]];
	
	return finalMovie;
}

@end
