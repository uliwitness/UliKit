//
//  UKDocumentationController.h
//  Shovel
//
//  Created by Uli Kusterer on 04.10.04.
//  Copyright 2004 Uli Kusterer.
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
