//
//  NSImage+PICTHandle.m
//  IconKit
//
//  Copyright (c) 2003, Florent Pillet, All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     1. Redistributions of source code must retain the above copyright notice, 
//        this list of conditions and the following disclaimer.
//     2. Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//     3. The name of the author may not be used to endorse or promote products
//        derived from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
// WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
// EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
// TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
// EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import "NSImage+PICTHandle.h"


// -----------------------------------------------------------------------------
//  Prototypes:
// -----------------------------------------------------------------------------

Handle UKBitmapImageCreateHandleDataRef(
     Handle             dataHandle,
     Str255             fileName,
     OSType             fileType,
     StringPtr          mimeTypeString,
     Ptr                initDataPtr,
     Size               initDataByteCount);


// -----------------------------------------------------------------------------
//  Categories:
// -----------------------------------------------------------------------------

@implementation NSImage (PICTHandle)

-(Handle)   TIFFHandle
{
        NSData *pngData = [self TIFFRepresentation];
        if (pngData == nil)
                return NULL;

        Handle pngDataH = NewHandle([pngData length]);
        PtrToHand([pngData bytes], &pngDataH, [pngData length]);
        return pngDataH;
}

-(PicHandle)    PICTHandle
{
        Handle pngDataH = [self TIFFHandle];
        if (pngDataH == NULL)
                return NULL;

        Handle dataRef = UKBitmapImageCreateHandleDataRef(pngDataH, "\pdummy.tif", kQTFileTypeTIFF, nil, nil, 0);

        // create a Graphics Importer component
        ComponentInstance importComponent=0;
        OSErr err = GetGraphicsImporterForDataRef(dataRef, HandleDataHandlerSubType, &importComponent);
        DisposeHandle(dataRef);
        if (err != noErr)
        {
                NSLog(@"Error %d when trying to create a graphics importer component", (int)err);
                CloseComponent(importComponent);
                DisposeHandle(pngDataH);
                return NULL;
        }

        // export data to PICT
        PicHandle pictDataH = NULL;
        if (GraphicsImportGetAsPicture(importComponent, &pictDataH) != noErr)
        {
                NSLog(@"Error %d when trying to export data as PICT via QuickTime", (int)err);
                CloseComponent(importComponent);
                DisposeHandle(pngDataH);
                return NULL;
        }
        CloseComponent(importComponent);
        DisposeHandle(pngDataH);
        
        return pictDataH;
}

-(NSData*)  PICTData
{
        NSArray *reps = [self representations];
        NSEnumerator *iter = [reps objectEnumerator];
        NSImageRep *rep;
        while (rep = [iter nextObject])
        {
                // easy case: there is already a PICT representation in the image
                if ([rep isMemberOfClass:[NSPICTImageRep class]])
                        return [(NSPICTImageRep*)rep PICTRepresentation];
        }

        // obtain a PICT handle
        PicHandle pictDataH = [self PICTHandle];
        if (pictDataH == NULL)
                return nil;

        // create a NSData block with the data
        HLock((Handle)pictDataH);
        NSData *pictData = [NSData dataWithBytes:*pictDataH length:GetHandleSize((Handle)pictDataH)];
        HUnlock((Handle)pictDataH);
        DisposeHandle((Handle)pictDataH);

        return pictData;
}

@end


/*
 * UKBitmapImageCreateHandleDataRef
 *
 * Tortuous function taken from Apple's Technote 1195 that creates
 * a dataRef for quicktime indicating which data format is stored
 * in the data
 *
 */
Handle UKBitmapImageCreateHandleDataRef(
     Handle             dataHandle,
     Str255             fileName,
     OSType             fileType,
     StringPtr          mimeTypeString,
     Ptr                initDataPtr,
     Size               initDataByteCount)
{
        OSErr  err;
        Handle dataRef = nil;
        Str31  tempName;
        long  atoms[3];
        StringPtr name;

        // First create a data reference handle for our data
        err = PtrToHand( &dataHandle, &dataRef, sizeof(Handle));
        if (err) goto bail;
        
        // If this is QuickTime 3 or later, we can add
        // the filename to the data ref to help importer
        // finding process. Find uses the extension.
        name = fileName;
        if (name == nil)
        {
                tempName[0] = 0;
                name = tempName;
        }

        // Only add the file name if we are also adding a
        // file type, MIME type or initialization data
        if (fileType || mimeTypeString || initDataPtr)
        {
                err = PtrAndHand(name, dataRef, name[0]+1);
                if (err)
                        goto bail;
        }

        // If this is QuickTime 4, the handle data handler
        // can also be told the filetype and/or
        // MIME type by adding data ref extensions. These
        // help the importer finding process.
        // NOTE: If you add either of these, you MUST add
        // a filename first -- even if it is an empty Pascal
        // string. Under QuickTime 3, any data ref extensions
        // will be ignored.

        // to add file type, you add a classic atom followed
        // by the Mac OS filetype for the kind of file
        if (fileType)
        {
                atoms[0] = EndianU32_NtoB(sizeof(long) * 3);
                atoms[1] = EndianU32_NtoB(kDataRefExtensionMacOSFileType);
                atoms[2] = EndianU32_NtoB(fileType);
                err = PtrAndHand(atoms, dataRef, sizeof(long) * 3);
                if (err)
                        goto bail;
        }

        // to add MIME type information, add a classic atom followed by
        // a Pascal string holding the MIME type
        if (mimeTypeString)
        {
                atoms[0] = EndianU32_NtoB(sizeof(long) * 2 + mimeTypeString[0]+1);
                atoms[1] = EndianU32_NtoB(kDataRefExtensionMIMEType);
        
                err = PtrAndHand(atoms, dataRef, sizeof(long) * 2);
                if (err)
                        goto bail;
        
                err = PtrAndHand(mimeTypeString, dataRef, mimeTypeString[0]+1);
                if (err)
                        goto bail;
        }

        // add any initialization data, but only if a dataHandle was
        // not already specified (any initialization data is ignored
        // in this case)
        if(dataHandle == nil && initDataPtr)
        {
                atoms[0] = EndianU32_NtoB(sizeof(long) * 2 + initDataByteCount);
                atoms[1] = EndianU32_NtoB(kDataRefExtensionInitializationData);
                err = PtrAndHand(atoms, dataRef, sizeof(long) * 2);
                if (err)
                        goto bail;
                err = PtrAndHand(initDataPtr, dataRef, initDataByteCount);
                if (err)
                        goto bail;
        }

        return dataRef;

bail:
        if (dataRef)
                DisposeHandle(dataRef);
        return nil;
}
