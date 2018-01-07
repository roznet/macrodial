//  MIT Licence
//
//  Created on 30/05/2009.
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

#import "ConfigTests.h"
#import "AppGlobals.h"
#import "AppConstants.h"

@implementation ConfigTests

-(NSArray*)testDefinitions{
    return @[
             @{@"selector":NSStringFromSelector(@selector(runConfigTests)),
               @"description":@"Test for Config",
               @"session":@"Config"},
             ];
}



-(void)runConfigTests{
	[self startSession:@"Config"];

	[AppGlobals newSettings];

	NSString * ev1 = @"EV1";
	NSString * ev2 = @"EV2";
	NSString * ev3 = @"EV3";
	NSInteger count = 0;
	NSInteger expected = 0;
	NSInteger i = 0;

	// EVERY
	for( i = 0 ; i < 5; i++ ){
		[AppGlobals recordEvent:ev1 every:RECORDEVENT_STEP_EVERY];
		count = [AppGlobals configGetInt:[AppGlobals publishKey:ev1] defaultValue:0];
		[self assessTestResult:@"Recorded Event every" result:count==(i+1)];
	}

	// FIRST ONLY
	for( i= 0 ; i < 5; i++ ){
		[AppGlobals recordEvent:ev2 every:RECORDEVENT_STEP_FIRSTONLY];
		count = [AppGlobals configGetInt:[AppGlobals publishKey:ev2] defaultValue:0];
		[self assessTestResult:@"Recorded Event first" result:count==1];
	};

	// EVERY
	for( int i = 0 ; i < 35 ; i++ ){
		[AppGlobals recordEvent:ev3 every:10];
		count = [AppGlobals configGetInt:[AppGlobals publishKey:ev3] defaultValue:0];
		expected = (i+1)/10;
		[self assessTestResult:@"Recorded Event every 10" result:count==expected];
	};

	[self endSession:@"Config"];

}

@end
