//
//  UKDropTableView.h
//  CocoaMediator
//
//  Created by Uli Kusterer on Sun May 11 2003.
//  Copyright (c) 2003 M. Uli Kusterer. All rights reserved.
//

#import <AppKit/AppKit.h>


@interface UKDropTableView : NSTableView
{

}

-(NSDragOperation)	draggingSourceOperationMaskForLocal: (BOOL)isLocal;

@end
