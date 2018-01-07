//  MIT Licence
//
//  Created on 11/06/2009.
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

#import "InfoTests.h"
#import "InfoDatabase.h"
#import "AppConstants.h"
#import "AppGlobals.h"

@implementation InfoTests

-(NSArray*)testDefinitions{
    return @[
             @{@"selector":NSStringFromSelector(@selector(runInfoTests)),
               @"description":@"Test for Info",
               @"session":@"Info"},
             ];
}

-(void)testInfoAll:(NSString*)aNumber areaCode:(NSString*)aAreaCode areaName:(NSString*)aAreaName country:(NSString*)aCountry{
	InfoDatabase * info = [AppGlobals info];

	PhoneNumberInfo * data = [info infoForNumber:aNumber];
	BOOL ok = TRUE;

	ok = ok && aCountry  ? [[data country]	isEqualToString:aCountry ] : [data country]  == nil;
	ok = ok && aAreaCode ? [[data areaCode] isEqualToString:aAreaCode] : [data areaCode] == nil;
	ok = ok && aAreaName ? [[data areaName] isEqualToString:aAreaName] : [data areaName] == nil;

	[self assessTestResult:[NSString stringWithFormat:@"Info for %@ incorrect: %@", aNumber, [data description]] result:ok];
}

-(void)bunchOfPlusTests{
	NSString * jpmob = @"Mobile";
	NSString * ukldn = @"London (inner city)";

	[self testInfoAll:@"+85269078299"	areaCode:nil		areaName:nil		country:@"Hong Kong"];
	[self testInfoAll:@"+33140270027"	areaCode:@"140"		areaName:@"Paris"	country:@"France"];
	[self testInfoAll:@"+3326705151"	areaCode:@"326"		areaName:@"Marne"	country:@"France"];
	[self testInfoAll:@"+3326705151"	areaCode:@"326"		areaName:@"Marne"	country:@"France"];
	[self testInfoAll:@"+33663721399"	areaCode:@"6"		areaName:@"Marne"	country:@"France"];
	[self testInfoAll:@"+33143730878"	areaCode:@"1"		areaName:@"Paris"	country:@"France"];
	[self testInfoAll:@"+33238667582"	areaCode:@"238"		areaName:@"Loiret"	country:@"France"];
	[self testInfoAll:@"+81364377361"	areaCode:@"3"		areaName:@"Tokyo"	country:@"Japan"];
	[self testInfoAll:@"+819042093940"	areaCode:@"90"		areaName:jpmob		country:@"Japan"];
	[self testInfoAll:@"+81136224611"	areaCode:nil		areaName:nil		country:@"Japan"];
	[self testInfoAll:@"+12129021000"	areaCode:@"212"		areaName:@"New York" country:@"US"];
	[self testInfoAll:@"+14087183687"	areaCode:@"408"		areaName:@"California" country:@"US"];
	[self testInfoAll:@"+442077745861"	areaCode:@"207"		areaName:ukldn		country:@"United Kingdom"];
}

-(void)runInfoTests{
	[self startSession:@"Info"];

	InfoDatabase * info = [AppGlobals info];

	[info setDefaultIdd:[info defaultIddForTimeZone:@"Asia/Hong_Kong"]];
	[self testInfoAll:@"85269078299"	areaCode:nil		areaName:nil		country:@"Hong Kong"];
	[self testInfoAll:@"69078299"		areaCode:nil		areaName:nil		country:@"Hong Kong"];
	[self testInfoAll:@"2129021000"		areaCode:nil		areaName:nil		country:@"Hong Kong"];
	[self bunchOfPlusTests];

	[info setDefaultIdd:[info defaultIddForTimeZone:@"Europe/Paris"]];
	[self testInfoAll:@"0326705151"		areaCode:@"326"		areaName:@"Marne"	country:@"France"];
	[self testInfoAll:@"0140270027"		areaCode:@"140"		areaName:@"Paris"	country:@"France"];
	[self testInfoAll:@"33140270027"	areaCode:@"140"		areaName:@"Paris"	country:@"France"];
	[self bunchOfPlusTests];

	[info setDefaultIdd:[info defaultIddForTimeZone:@"America/New_York"]];
	[self testInfoAll:@"2129021000"		areaCode:@"212"		areaName:@"New York"		country:@"US"];
	[self testInfoAll:@"9177711507"		areaCode:@"917"		areaName:@"New York"		country:@"US"];
	[self testInfoAll:@"6172830358"		areaCode:@"617"		areaName:@"Massachusetts"		country:@"US"];
	[self testInfoAll:@"6172830358"		areaCode:@"617"		areaName:@"Massachusetts"		country:@"US"];

	[self endSession:@"Info"];
}
@end
