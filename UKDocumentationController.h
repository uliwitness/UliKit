//
//  UKDocumentationController.h
//  Shovel
//
//  Created by Uli Kusterer on 04.10.04.
//  Copyright 2004 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


/*
    This is a little controller object that you can instantiate in your
    MainMenu.nib to add a few menu items to your application's "Help" menu.
    
    It will bring up the anchors of the specified name (e.g. #readme) in your
    application's help book. This way, you are very flexible in regard to where
    you put this info in your help book. As long as the specified anchor tags
    (e.g. <a name="readme"></a> is present in your help book somewhere and you
    have run the Apple Help Indexing Tool on your help book's HTML files, this
    object will show the right page and the right location, even if your help
    consists only of one large file and not several pages.
*/


@interface UKDocumentationController : NSObject
{
}

// IBActions for our additional help menu items:
-(void)	showReadme: (id)sender;             // #readme
-(void)	showReleaseNotes: (id)sender;       // #release_notes
-(void)	showFAQ: (id)sender;                // #faq

// Private, used by the other three:
-(void)	showHelpBookAnchor: (NSString*)str;

@end
