//
//  URLHandlerCommand.h
//  UKLicenseMaker
//
//  Created by Uli Kusterer on 16.08.08.
//  Copyright 2008 Uli Kusterer.
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
