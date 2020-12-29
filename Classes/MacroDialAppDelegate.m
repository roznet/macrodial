//  MIT Licence
//
//  Created on 12/02/2009.
//
//  Copyright (c) None Brice Rosenzweig.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//  

#import "MacroDialAppDelegate.h"
#import "AppConstants.h"

@implementation MacroDialAppDelegate
@synthesize window,tabBarController,macroOrganizer,db,settings,locator,info,timer;

#pragma mark UIApplication Delegate

-(NSString*)defaultIdd{
	NSString * rv = [[self settings] objectForKey:CONFIG_DEFAULT_IDD];
	if( info && ! rv ){
		if( ! rv ){
			rv = [info defaultIddForTimeZone:[[NSTimeZone defaultTimeZone] name]];
		}
		if( ! rv ){
			rv = @"1";
		}
		[[self settings] setObject:rv forKey:CONFIG_DEFAULT_IDD];
	}
	return( rv );
}

- (void)applicationDidFinishLaunching:(UIApplication *)application{
	PROFILE_START();
    RZLog(RZLogInfo, @"=========== %@ %@ ==== %@ ===============",
          [[NSBundle mainBundle] infoDictionary][@"CFBundleExecutable"],
          [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"],
          [RZSystemInfo systemDescription]);

    RZSimNeedle();

	[self setTimer:[[RZAppTimer alloc] init]];
#ifdef USEPINCH__DISABLE__
	NSString *applicationCode = @"09eccebcf5c97955ab79f1df280b4490";
    [Flurry startSession:applicationCode];
	PROFILE_REPORT( @"AppDidFinishLaunching:beacon" );
#endif
	[RZFileOrganizer createEditableCopyOfFileIfNeeded:@"macros.db"];
	[RZFileOrganizer createEditableCopyOfFileIfNeeded:@"settings.plist"];

	db = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:@"macros.db"]];
	[db open];
	PROFILE_REPORT( @"AppDidFinishLaunching:dbopen" );

	[self setSettings:[NSMutableDictionary dictionaryWithDictionary:[RZFileOrganizer loadDictionary:@"settings.plist"]]];
	PROFILE_REPORT( @"AppDidFinishLaunching:loadSettings" );

	int db_version = [[[self settings] objectForKey:CONFIG_DB_VERSION] intValue];
    BOOL changed = false;
	if( db_version < 1 ) {
		[MacroOrganizer upgradeDbToV1:db];
		[[self settings] setObject:@(1) forKey:CONFIG_DB_VERSION];
        changed = true;
	}
	if ( db_version < 2 ) {
		[MacroOrganizer upgradeDbToV2:db];
		[[self settings] setObject:@(2) forKey:CONFIG_DB_VERSION];
        changed = true;
	}
    if (db_version < 3) {
        [[self settings] setObject:@(3) forKey:CONFIG_DB_VERSION];
        [MacroOrganizer upgradeDbToV3:db];
        changed = true;
    }
    if (changed) {
        [self saveSettings];
    }
	macroOrganizer	= [[MacroOrganizer	alloc] initWithDb:db];
	info			= [[InfoDatabase	alloc] init];
	[info setDefaultIdd:[self defaultIdd]];
	PROFILE_REPORT( @"AppDidFinishLaunching:db" );

	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	tabBarController = [[TabBarController alloc] init];
	[tabBarController loadFromDictionary:[self settings]];
    [window setRootViewController:tabBarController];
	[window makeKeyAndVisible];
	PROFILE_REPORT(@"AppDidFinishLaunching:ui");

	locator = [[FindWhereIAm alloc] initWithDelegate:self reverse:FALSE];
	[timer record:@"AppDidFinishLaunching"];

	PROFILE_STOP( @"AppDidFinishLaunching:end" );
}

- (void)applicationWillResignActive:(UIApplication *)application{
	[tabBarController saveToDictionary:settings];
	[RZFileOrganizer saveDictionary:settings withName:@"settings.plist"];
}

- (void)applicationWillTerminate:(UIApplication *)application{
	[tabBarController saveToDictionary:settings];
	[RZFileOrganizer saveDictionary:settings withName:@"settings.plist"];

}

-(void)saveSettings{
    [RZFileOrganizer saveDictionary:settings withName:@"settings.plist"];
}

-(void)foundLocation{
	CLLocationCoordinate2D loc = [[locator currentLocation] coordinate];
	NSNumber * longitude = [NSNumber numberWithDouble:loc.longitude];
	NSNumber * latitude  = [NSNumber numberWithDouble:loc.latitude];

	[[self settings] setObject:latitude		forKey:CONFIG_LAST_LATITUDE];
	[[self settings] setObject:longitude	forKey:CONFIG_LAST_LONGITUDE];
	[[self settings] setObject:[[locator currentLocation] timestamp] forKey:CONFIG_LAST_LOC_TIME];
	[timer record:@"foundLocation"];
}

#pragma mark Database and Settings

- (void)dealloc {

	[db		close];



}


@end
