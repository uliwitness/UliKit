//
//  ULIURLHandlingApplication.h
//  Stacksmith
//
//  Created by Uli Kusterer on 2014-01-11.
//  Copyright (c) 2014 Uli Kusterer. All rights reserved.
//
//	To use this class, change the principal class from NSApplication to
//	ULIURLHandlingApplication and add a CFBundleURLTypes entry like the
//	following to your Info.plist:
//
//		<key>CFBundleURLTypes</key>
//		<array>
//			<dict>
//				<key>CFBundleURLSchemes</key>
//				<array>
//					<string>x-stack</string>
//				</array>
//				<key>CFBundleURLName</key>
//				<string>com.stacksmith.stack</string>
//			</dict>
//		</array>
//
//	This claims an "x-stack:" URL scheme and hands the URL to application:openURL:
//	You can make up whatever bundle ID you want for the URL name.
//

#import <Cocoa/Cocoa.h>


@class ULIURLHandlingApplication;


@protocol ULIURLHandlingApplicationDelegate <NSApplicationDelegate>

@optional
-(BOOL)	application: (ULIURLHandlingApplication*)inApp openURL: (NSURL*)inURLToOpen;

@end

@interface ULIURLHandlingApplication : NSApplication

-(void)										setDelegate: (id<ULIURLHandlingApplicationDelegate>)inDelegate;
-(id<ULIURLHandlingApplicationDelegate>)	delegate;

@end


