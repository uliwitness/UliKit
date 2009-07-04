//
//  URLHandlerCommand.h
//  UKLicenseMaker
//
//  Created by Uli Kusterer on 16.08.08.
//  Copyright 2008 The Void Software. All rights reserved.
//

/*
	Class that forwards URLs to the application delegate, which can then dissect
	them and handle them. To activate this, add this file and its implementation
	to the project, and add
		
		URLHandler.scriptSuite
		URLHandler.scriptTerminology
	
	to the project as resources. Finally, add the following to your app's Info.plist:
	
		<key>NSAppleScriptEnabled</key>
		<true/>
		<key>CFBundleURLTypes</key>
		<array>
			<dict>
				<key>CFBundleURLSchemes</key>
				<array>
					<string>x-myscheme</string>
				</array>
			</dict>
		</array>
	
	where you'd replace x-myscheme with http or whatever scheme you want your
	app to handle.
*/

#import <Cocoa/Cocoa.h>


@interface URLHandlerCommand : NSScriptCommand
{

}

@end


@interface NSObject (URLHandlerCommandDelegate)

-(void)	openCustomURL: (NSURL*)url;

@end
