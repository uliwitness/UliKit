//
//  NSStringHTMLEntities.h
//  HTMLTranslator
//
//  Created by Uli Kusterer on Thu Aug 12 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (UKHTMLEntities)

-(NSString*) stringByInsertingHTMLEntities;
-(NSString*) stringByInsertingHTMLEntitiesAndLineBreaks: (BOOL)br;  // YES = generate <br>s, NO = same as stringByInsertingHTMLEntities.

@end
