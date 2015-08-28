//
//  UKSystemInfo.m
//  UKSystemInfo
//
//  Created by Uli Kusterer on 23.09.04.
//  Copyright 2004 M. Uli Kusterer. Uli Kusterer
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

#import "UKSystemInfo.h"
#include <sys/types.h>
#include <sys/sysctl.h>

unsigned	UKPhysicalRAMSize(void)
{
	return (unsigned) (([NSProcessInfo.processInfo physicalMemory] / 1024ULL) / 1024ULL);
}


NSString*	UKSystemVersionString(void)
{
	static NSString*	sSysVersionCocoaStr = nil;
	if( !sSysVersionCocoaStr )
	{
		sSysVersionCocoaStr = [[[NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"] objectForKey:@"ProductVersion"] retain];
	}
	return sSysVersionCocoaStr;
}


void	UKGetSystemVersionComponents( SInt32* outMajor, SInt32* outMinor, SInt32* outBugfix )
{
	NSArray		*	sysVersionComponents = [UKSystemVersionString() componentsSeparatedByString: @"."];
	
	if( sysVersionComponents.count > 0 )
		*outMajor = [[sysVersionComponents objectAtIndex: 0] intValue];
	if( sysVersionComponents.count > 1 )
		*outMinor = [[sysVersionComponents objectAtIndex: 1] intValue];
	if( sysVersionComponents.count > 2 )
		*outBugfix = [[sysVersionComponents objectAtIndex: 2] intValue];
}


long	UKSystemVersion(void)
{
	SInt32		sysVersion, major = 0, minor = 0, bugfix = 0, bcdMajor = 0;
	
	UKGetSystemVersionComponents( &major, &minor, &bugfix );
	
	if( bugfix > 9 )
		bugfix = 9;
	if( minor > 9 )
		minor = 9;
	bcdMajor = major % 10;
	while( major >= 10 )
	{
		major -= 10;
		bcdMajor += 16;
	}
	
	sysVersion = (bcdMajor << 8) | (minor << 4) | bugfix;
	printf( "%x\n", sysVersion );
	
	return sysVersion;
}


unsigned	UKClockSpeed(void)
{
	unsigned long long	count = 0;
	size_t				size = sizeof(count);

	if( sysctlbyname( "hw.cpufrequency_max", &count, &size, NULL, 0 ) )
		return 1;
	
	return (unsigned) (count / 1000000ULL);
}


unsigned	UKCountCores(void)
{
	unsigned	count = 0;
	size_t		size = sizeof(count);

	if( sysctlbyname( "hw.ncpu", &count, &size, NULL, 0 ) )
		return 1;

	return count;
}


NSString*	UKMachineName(void)
{
	static NSString*	cpuName = nil;
	if( cpuName )
		return cpuName;
	
	char		machineName[256] = {};
	int			modelInfo[2] = { CTL_HW, HW_MODEL };
	size_t		modelSize = sizeof(machineName) -1;
	if( sysctl(modelInfo, 2, machineName, &modelSize, NULL, 0 ) != 0 )
		return nil;
	
	NSString*	internalName = [NSString stringWithUTF8String: machineName];
	
	static NSDictionary* translationDictionary = nil;
	if( !translationDictionary )
		translationDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"PowerMac 8500/8600",@"AAPL,8500",
                                 @"PowerMac 9500/9600",@"AAPL,9500",
                                 @"PowerMac 7200",@"AAPL,7200",
                                 @"PowerMac 7200/7300",@"AAPL,7300",
                                 @"PowerMac 7500",@"AAPL,7500",
                                 @"Apple Network Server",@"AAPL,ShinerESB",
                                 @"Alchemy(Performa 6400 logic-board design)",@"AAPL,e407",
                                 @"Gazelle(5500)",@"AAPL,e411",
                                 @"PowerBook 3400",@"AAPL,3400/2400",
                                 @"PowerBook 3500",@"AAPL,3500",
                                 @"PowerMac G3 (Gossamer)",@"AAPL,Gossamer",
                                 @"PowerMac G3 (Silk)",@"AAPL,PowerMac G3",
                                 @"PowerBook G3 (Wallstreet)",@"AAPL,PowerBook1998",
                                 @"Yikes! Old machine",@"AAPL",		// generic.
                                 
                                 @"PowerBook G3 (Lombard)",@"PowerBook1,1",
                                 @"iBook (clamshell)",@"PowerBook2,1",
                                 @"iBook FireWire (clamshell)",@"PowerBook2,2",
                                 @"PowerBook G3 (Pismo)",@"PowerBook3,1",
                                 @"PowerBook G4 (Titanium)",@"PowerBook3,2",
                                 @"PowerBook G4 (Titanium w/ Gigabit Ethernet)",@"PowerBook3,3",
                                 @"PowerBook G4 (Titanium w/ DVI)",@"PowerBook3,4",
                                 @"PowerBook G4 (Titanium 1GHZ)",@"PowerBook3,5",
                                 @"iBook G3 (12in May 2001)",@"PowerBook4,1",
                                 @"iBook G3 (May 2002)",@"PowerBook4,2",
                                 @"iBook G3 rev. b (w/ or w/o 14in LCD) (Nov 2002)",@"PowerBook4,3",
                                 @"iBook G4 rev. c (w/ or w/o 14in LCD)",@"PowerBook4,4",
                                 @"PowerBook G4 (17-inch)",@"PowerBook5,1",
                                 @"PowerBook G4 (15-inch FW800)",@"PowerBook5,2",
                                 @"PowerBook G4 (17-inch 1.33 GHz)",@"PowerBook5,3",
                                 @"PowerBook G4 (15-inch 1.5/1.33 GHz)",@"PowerBook5,4",
                                 @"PowerBook G4 (17-inch 1.5 GHz)",@"PowerBook5,5",
                                 @"PowerBook G4 (15-inch 1.67/1.5 GHz)",@"PowerBook5,6",
                                 @"PowerBook G4 (17-inch 1.67 GHz)",@"PowerBook5,7",
                                 @"PowerBook G4 (Double-Layer SD, 15-inch)",@"PowerBook5,8",
                                 @"PowerBook G4 (Double-Layer SD, 17-inch)",@"PowerBook5,9",
                                 @"PowerBook G4 (12-inch)",@"PowerBook6,1",
                                 @"PowerBook G4 (12-inch DVI)",@"PowerBook6,2",
                                 @"iBook G4",@"PowerBook6,3",
                                 @"PowerBook G4 (12-inch 1.33 GHz)",@"PowerBook6,4",
                                 @"iBook G4",@"PowerBook6,5",
                                 @"iBook G4",@"PowerBook6,7",
                                 @"PowerBook G4 (12-inch 1.5 GHz)",@"PowerBook6,8",
                                 @"PowerBook or iBook",@"PowerBook",	// generic.
                                 
                                 @"Power Macintosh G3 (B&W)",@"PowerMac1,1",
                                 @"PowerMac G4 (PCI Graphics)",@"PowerMac1,2",
                                 @"iMac FireWire (Slot-Loading)",@"PowerMac2,1",
                                 @"iMac FireWire (2000)",@"PowerMac2,2",
                                 @"PowerMac G4 (AGP Graphics)",@"PowerMac3,1",
                                 @"PowerMac G4 (AGP Graphics)",@"PowerMac3,2",
                                 @"PowerMac G4 (Gigabit Ethernet)",@"PowerMac3,3",
                                 @"PowerMac G4 (Digital Audio)",@"PowerMac3,4",
                                 @"PowerMac G4 (QuickSilver)",@"PowerMac3,5",
                                 @"PowerMac G4 (MDD/Windtunnel)",@"PowerMac3,6",
                                 @"iMac (Flower Power)",@"PowerMac4,1",
                                 @"iMac (Flat Panel 15in)",@"PowerMac4,2",
                                 @"eMac",@"PowerMac4,4",
                                 @"iMac (Flat Panel 17in)",@"PowerMac4,5",
                                 @"PowerMac G4 Cube",@"PowerMac5,1",
                                 @"PowerMac G4 Cube",@"PowerMac5,2",
                                 @"iMac (USB 2.0)",@"PowerMac6,1",
                                 @"iMac (20-inch Flat Panel)",@"PowerMac6,3",
                                 @"eMac (USB 2.0)",@"PowerMac6,4",
                                 @"PowerMac G5",@"PowerMac7,2",
                                 @"PowerMac G5",@"PowerMac7,3",
                                 @"iMac G5",@"PowerMac8,1",
                                 @"iMac G5 (Ambient Light Sensor)",@"PowerMac8,2",
                                 @"Power Macintosh G5 (Late 2004)",@"PowerMac9,1",
                                 @"Mac mini",@"PowerMac10,1",
                                 @"Mac mini",@"PowerMac10,2",
                                 @"Power Macintosh G5 (PCIe)",@"PowerMac11,2",
                                 @"iMac G5 (iSight)",@"PowerMac12,1",
                                 @"PowerMac",@"PowerMac",	// generic.
                                 
                                 @"Xserve G4",@"RackMac1,1",
                                 @"Xserve G4 (Slot-Loading)",@"RackMac1,2",
                                 @"Xserve G5",@"RackMac3,1",
                                 @"Xserve Xeon",@"Xserve1,1",
                                 @"Xserve Xeon (Early 2008)",@"Xserve2,1",
                                 @"Xserve Xeon (Early 2009)",@"Xserve3,1",
                                 @"XServe",@"RackMac",
                                 
                                 @"MacBook (Core Duo)",@"MacBook1,1",
                                 @"MacBook (Core 2 Duo)",@"MacBook2,1",
                                 @"MacBook (Core 2 Duo)",@"MacBook3,1",
                                 @"MacBook (Early 2008)",@"MacBook4,1",
                                 @"MacBook Alum (Early 2008)",@"MacBook5,1",
                                 @"MacBook (Mid 2009)",@"MacBook5,2",
                                 @"MacBook (Late 2009)",@"MacBook6,1",
                                 @"MacBook (13-inch, Mid 2010)",@"MacBook7,1",
                                 @"MacBook (12-inch, Early 2015)",@"MacBook8,1",
                                 @"MacBook",@"MacBook",	// generic.
                                 
                                 @"MacBook Air (Original)",@"MacBookAir1,1",
                                 @"MacBook Air (Late 2008)",@"MacBookAir2,1",
                                 @"MacBook Air (11-inch, Late 2010)",@"MacBookAir3,1",
                                 @"MacBook Air (13-inch, Late 2010)",@"MacBookAir3,2",
                                 @"MacBook Air (11-inch, Mid 2011)",@"MacBookAir4,1",
                                 @"MacBook Air (13-inch, Mid 2011)",@"MacBookAir4,2",
                                 @"MacBook Air (11-inch, Mid 2012)",@"MacBookAir5,1",
                                 @"MacBook Air (13-inch, Mid 2012)",@"MacBookAir5,2",
                                 @"MacBook Air (11-inch, Mid 2013 or Early 2014)",@"MacBookAir6,1",
                                 @"MacBook Air (13-inch, Mid 2013 or Early 2014)",@"MacBookAir6,2",
                                 @"MacBook Air (11-inch, Early 2015)",@"MacBookAir5,1",
                                 @"MacBook Air (13-inch, Early 2015)",@"MacBookAir5,2",
                                 @"MacBook Air",@"MacBookAir",	// generic.
                                 
                                 @"MacBook Pro (15-inch Core Duo)",@"MacBookPro1,1",
                                 @"MacBook Pro (17-inch Core Duo)",@"MacBookPro1,2",
                                 @"MacBook Pro (17-inch Core 2 Duo)",@"MacBookPro2,1",
                                 @"MacBook Pro (15-inch Core 2 Duo)",@"MacBookPro2,2",
                                 @"MacBook Pro (15-inch or 17-inch LED, Core 2 Duo)",@"MacBookPro3,1",
                                 @"MacBook Pro (15-inch or 17-inch LED, Early 2008)",@"MacBookPro4,1",
                                 @"MacBook Pro (15-inch LED Unibody, Late 2008)",@"MacBookPro5,1",
                                 @"MacBook Pro (17-inch LED Unibody, Mid 2009 or Mid 2010)",@"MacBookPro5,2",
                                 @"MacBook Pro (15-inch LED Unibody, Mid 2009)",@"MacBookPro5,3",
                                 @"MacBook Pro (15-inch LED Unibody, 2.53, Mid 2009)",@"MacBookPro5,4",
                                 @"MacBook Pro (13-inch LED Unibody, Mid 2009)",@"MacBookPro5,5",
                                 @"MacBook Pro (17-inch, Mid 2010)",@"MacBookPro6,1",
                                 @"MacBook Pro (15-inch, Mid 2010)",@"MacBookPro6,2",
                                 @"MacBook Pro (13-inch, Mid 2010)",@"MacBookPro7,1",
                                 @"MacBook Pro (13-inch, Early 2011 or Late 2011)",@"MacBookPro8,1",
                                 @"MacBook Pro (15-inch, Early 2011 or Late 2011)",@"MacBookPro8,2",
                                 @"MacBook Pro (17-inch, Early 2011 or Late 2011)",@"MacBookPro8,3",
                                 @"MacBook Pro (15-inch, Mid 2012)",@"MacBookPro9,1",
                                 @"MacBook Pro (13-inch, Mid 2012)",@"MacBookPro9,2",
                                 @"MacBook Pro (15-inch, Retina, Mid 2012 or Early 2013)",@"MacBookPro10,1",
                                 @"MacBook Pro (13-inch, Retina, Late 2012 or Early 2013)",@"MacBookPro10,2",
                                 @"MacBook Pro (13-inch, Retina, Late 2013 or Mid 2014)",@"MacBookPro11,1",
                                 @"MacBook Pro (15-inch, Retina, Late 2013 or Mid 2014)",@"MacBookPro11,2",
                                 @"MacBook Pro (15-inch, Retina, Late 2013 or Mid 2014)",@"MacBookPro11,3",
                                 @"MacBook Pro (15-inch, Retina, Early 2015)",@"MacBookPro11,4",
                                 @"MacBook Pro (15-inch, Retina, Early 2015)",@"MacBookPro11,5",
                                 @"MacBook Pro (13-inch, Retina, Early 2015)",@"MacBookPro12,1",
                                 @"MacBook Pro",@"MacBookPro",	// generic.
                                 
                                 @"iMac (first generation)",@"iMac,1",
                                 @"iMac (Core Duo Edu)",@"iMac4,1",
                                 @"iMac (Core Duo)",@"iMac4,2",
                                 @"iMac (Core 2 Duo Edu)",@"iMac5,1", 
                                 @"iMac (Core 2 Duo)",@"iMac5,2", 
                                 @"iMac (24-inch Core 2 Duo)",@"iMac6,1",
                                 @"iMac (Aluminum Core 2 Duo)",@"iMac7,1",
                                 @"iMac (20-inch or 24-inch Penryn, Early 2008)",@"iMac8,1",
                                 @"iMac (20-inch or 24-inch Penryn, Early 2009 or Mid 2009)",@"iMac9,1",
                                 @"iMac (21.5-inch or 27-inch, Core 2 Duo, Late 2009)",@"iMac10,1",
                                 @"iMac (27-inch, Core i5 or i7, Late 2009)",@"iMac11,1",
                                 @"iMac (21.5-inch, Late 2009)",@"iMac11,2",
                                 @"iMac (27-inch, Late 2009)",@"iMac11,3",
                                 @"iMac (21.5-inch, Mid 2011)",@"iMac12,1",
                                 @"iMac (27-inch, Mid 2011)",@"iMac12,2",
                                 @"iMac (21.5-inch, Late 2012)",@"iMac13,1",
                                 @"iMac (27-inch, Late 2012)",@"iMac13,2",
                                 @"iMac (21.5-inch, Late 2013)",@"iMac14,1",
                                 @"iMac (27-inch, Late 2013)",@"iMac14,2",
                                 @"iMac (21.5-inch, Late 2013)",@"iMac14,3",
                                 @"iMac (21.5-inch, Mid 2014)",@"iMac14,4",
                                 @"iMac (27-inch, Retina, Late 2014 or Mid 2015)",@"iMac15,1",
                                 @"iMac",@"iMac",					// generic.
                                 
                                 @"Mac Pro (Quad Xeon)",@"MacPro1,1",
                                 @"Mac Pro (Octal Xeon)",@"MacPro2,1",
                                 @"Mac Pro (Early 2008)",@"MacPro3,1",
                                 @"Mac Pro (Early 2009)",@"MacPro4,1",
                                 @"Mac Pro (Mid 2010 or Mid 2012)",@"MacPro5,1",
                                 @"Mac Pro (Late 2013)",@"MacPro6,1",
                                 @"Mac Pro",@"MacPro",	// generic.

                                 @"Mac mini (Core Duo/Solo)",@"Macmini1,1",
                                 @"Mac mini (Core Duo)",@"Macmini2,1",
                                 @"Mac mini (Core 2 Duo)",@"Macmini3,1",
                                 @"Mac mini (Mid 2010)",@"Macmini4,1",
                                 @"Mac mini (Mid 2011)",@"Macmini5,1",
                                 @"Mac mini (Server, Mid 2011)",@"Macmini5,3",
                                 @"Mac mini (2.5 GHz, Late 2012)",@"Macmini6,1",
                                 @"Mac mini (2.3 or 2.6 GHz, Late 2012)",@"Macmini6,2",
                                 @"Mac mini (Late 2014)",@"Macmini7,1",
                                 @"Mac Mini",@"Macmini",		// generic
                                 
                                 @"Developer Transition Kit",@"ADP2,1",
                                 @"Development Mac Pro",@"M43ADP1,1 ",
				nil];
	
	NSRange			r;
	NSString*		aKey;
	NSString*		foundKey = nil;
	NSString*		humanReadableName = nil;
	
	// Find the corresponding entry in the NSDictionary
	//	Keys should be sorted to distinguish 'generic' from 'specific' names.
	//	So we can overwrite generic names with the more specific ones as we
	//	progress through the list.
	NSEnumerator	*e=[[[translationDictionary allKeys]
								sortedArrayUsingSelector:@selector(compare:)]
								objectEnumerator];
	while( aKey = [e nextObject] )
	{
		r = [internalName rangeOfString: aKey];
		if( r.location != NSNotFound )
		{
			if( humanReadableName == nil || [foundKey length] != [internalName length] )	// We didn't have an exact match yet?
			{
				humanReadableName = [translationDictionary objectForKey:aKey];
				foundKey = aKey;
			}
		}
	}
	
	// If it was a generic name, include the ugly name so we can add it to the list:
	if( [foundKey rangeOfString: @","].location == NSNotFound )
		humanReadableName = [[NSString stringWithFormat: @"%@ (%@)", humanReadableName, foundKey] retain];
	// If nothing was found, at least show the ugly name so we have some hint:
	if( humanReadableName == nil )
		cpuName = [[NSString stringWithFormat: @"Unknown (%@)", internalName] retain];
	else
		cpuName = humanReadableName;
	
	return cpuName;
}


NSString*	UKCPUName(void)
{
	return UKAutoreleasedCPUName( NO );
}


NSString*	UKAutoreleasedCPUName( BOOL dontCache )
{
	static NSString	*	sCPUName = nil;
	
	if( dontCache || !sCPUName )
	{
		char		cpuName[256] = {};
		size_t		size = sizeof(cpuName) -1;

		if( sysctlbyname( "machdep.cpu.brand_string", cpuName, &size, NULL, 0 ) != 0 )
			return nil;

		[sCPUName release];
		sCPUName = [[NSString alloc] initWithUTF8String: cpuName];
	}
	
	return sCPUName;
}


/*NSString*	UKSystemSerialNumber()
{
	mach_port_t				masterPort;
	kern_return_t			kr = noErr;
	io_registry_entry_t		entry;
	CFTypeRef				prop;
	CFTypeID				propID;
	NSString*				str = nil;

	kr = IOMasterPort(MACH_PORT_NULL, &masterPort);
	if( kr != noErr )
		goto cleanup;
	entry = IORegistryGetRootEntry( masterPort );
	if( entry == MACH_PORT_NULL )
		goto cleanup;
	prop = IORegistryEntrySearchCFProperty(entry, kIODeviceTreePlane, CFSTR("serial-number"), nil, kIORegistryIterateRecursively);
	if( prop == nil )
		goto cleanup;
	propID = CFGetTypeID( prop );
	if( propID != CFDataGetTypeID() )
		goto cleanup;
	
	const char*	buf = [(NSData*)prop bytes];
	int			len = [(NSData*)prop length],
				 x;
	
	char	secondPart[256];
	char	firstPart[256];
	char*	currStr = secondPart;
	int		y = 0;
	
	for( x = 0; x < len; x++ )
	{
		if( buf[x] > 0 && (y < 255) )
			currStr[y++] = buf[x];
		else if( currStr == secondPart )
		{
			currStr[y] = 0;		// Terminate string.
			currStr = firstPart;
			y = 0;
		}
	}
	currStr[y] = 0;	// Terminate string.
	
	str = [NSString stringWithFormat: @"%s%s", firstPart, secondPart];
	
cleanup:
	mach_port_deallocate( mach_task_self(), masterPort );
	
	return str;
}*/

