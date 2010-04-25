//
//  UKRandomInteger.m
//  Propaganda
//
//  Created by Uli Kusterer on 25.04.10.
//  Copyright 2010 The Void Software. All rights reserved.
//

#import "UKRandomInteger.h"


NSInteger	UKRandomInteger()
{
	#if __LP64__
	return (((NSInteger)rand()) | ((NSInteger)rand()) << 32);
	#else
	return rand();
	#endif
}
