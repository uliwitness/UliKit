/*
 *  UKDumpHex.h
 *  VelocityLoader
 *
 *  Created by Uli Kusterer on 02.04.07.
 *  Copyright 2007 M. Uli Kusterer. All rights reserved.
 *
 */

#ifndef UKDUMPHEX_H
#define UKDUMPHEX_H 1

#include <memory.h>

#if __cplusplus
extern "C" {
#endif

// Prints bufLen bytes of the specified buffer to the console as hex and ASCII:

void	UKDumpHex( const char* buf, size_t bufLen );


#if __cplusplus
}
#endif

#endif /*UKDUMPHEX_H*/