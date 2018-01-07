//  MIT Licence
//
//  Created on 05/03/2009.
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

#import "MacroHandlerTests.h"
#import "MacroImplHandler.h"
#import "MacroXMLParser.h"
#import "MacroAutoLearner.h"



@implementation MacroHandlerTests

-(NSArray*)testDefinitions{
    return @[
             @{@"selector":NSStringFromSelector(@selector(runHandlerTests)),
               @"description":@"Tests Handlers",
               @"session":@"Macro Handler"},
             ];
}

-(void)testImpl:(NSString*)number impl:(MacroImpl*)imp output:(NSString*)expected tag:(NSString*)aTag{
	PhoneNumber * pn	= [[PhoneNumber alloc]	initWithString:number];

	[imp execute:pn data:[[NSDictionary alloc] init]];

	[self assessTestResult:	[NSString stringWithFormat:@"f[%@]:[%@]==[%@] %@", number, [pn outputNumber], expected, aTag]
					result:[[pn outputNumber] isEqualToString:expected]];
}

-(void)runBuildRules{
	MacroImplHandler * handler = [[MacroImplHandler alloc] init];

	MacroImpl * imp = [handler createNewImplForType:@"removeprefix"];
	[imp setArgument:@"prefix" value:@"22"];
	[handler insertImplementor:imp atIndex:0];
	[self testSimpleRule:@"2200" impl:[handler implementor]	output:@"00"];

	imp = [handler createNewImplForType:@"prefix"];
	[imp setArgument:@"prefix" value:@"1"];
	[handler insertImplementor:imp atIndex:[handler implementorCount]];
	[self testSimpleRule:@"2200" impl:[handler implementor]	output:@"100"];

	imp = [handler createNewImplForType:@"prefix"];
	[imp setArgument:@"prefix" value:@"2"];
	[handler replaceImplementorAt:[handler implementorCount]-1 with:imp];
	[self testSimpleRule:@"2200" impl:[handler implementor]	output:@"200"];

	imp = [handler createNewImplForType:@"suffix"];
	[imp setArgument:@"suffix" value:@"3"];
	[handler replaceImplementorAt:0 with:imp];
	[self testSimpleRule:@"2200" impl:[handler implementor]	output:@"222003"];

	[handler deleteImplementorAt:0];
	[self testSimpleRule:@"2200" impl:[handler implementor]	output:@"22200"];


}

-(void)runTestsHandler{

	NSString * basePrefix		= @"<rule><type>prefix</type><prefix>%@</prefix>%@</rule";

	NSString * r1 = [self buildRuleFromArray:[NSArray arrayWithObjects:	basePrefix,		@"4",
																		basePrefix,		@"3",
																		basePrefix,		@"2",
																		basePrefix,		@"1",
																		nil ]];


	NSString * input = @"0000";
	NSString * output = @"12340000";
	MacroImplHandler * handler = [[MacroImplHandler alloc] initWithImplementor:[MacroXMLParser implementorForString:r1]];

	[self testSimpleRule:input rule:r1	output:output];

	NSUInteger n = [handler implementorCount];
	NSUInteger i = 0;

	[self assessTestResult:[NSString stringWithFormat:@"Implementor Count %lu==4", (unsigned long)n ] result:(n==4)];

	for( i = 0; i < n ; i++ ){
		NSString * until = [handler implementorExecuteOn:input with:[NSDictionary dictionary] untilIndex:i];
		NSString * expected = [output substringFromIndex:n-i-1];
		[self assessTestResult:[NSString stringWithFormat:@"Execute till %lu %@==%@", (unsigned long)i, until, expected ] result:[until isEqualToString:expected]];
	};
	//====================random delete

	[handler deleteImplementorAt:1];
	[self testImpl:input impl:[handler implementor] output:@"1240000" tag:@"Delete 1"];

	[handler deleteImplementorAt:3];
	[self testImpl:input impl:[handler implementor] output:@"240000" tag:@"Delete 3"];

	[handler deleteImplementorAt:0];
	[self testImpl:input impl:[handler implementor] output:@"20000" tag:@"Delete 0"];

	[handler deleteImplementorAt:0];
	[self testImpl:input impl:[handler implementor] output:@"0000" tag:@"Delete 0"];

	[handler deleteImplementorAt:0];
	[self testImpl:input impl:[handler implementor] output:@"0000" tag:@"Delete 0"];

	//=====================delete from beginning
	[handler setImplementor:[MacroXMLParser implementorForString:r1]];
	[handler deleteImplementorAt:0];
	[self testImpl:input impl:[handler implementor] output:@"1230000" tag:@"Delete first 0"];


	[handler deleteImplementorAt:0];
	[self testImpl:input impl:[handler implementor] output:@"120000" tag:@"Delete first 1"];

	[handler deleteImplementorAt:0];
	[self testImpl:input impl:[handler implementor] output:@"10000" tag:@"Delete first 2"];

	[handler deleteImplementorAt:0];
	[self testImpl:input impl:[handler implementor] output:@"0000" tag:@"Delete first 3"];

	[handler deleteImplementorAt:0];
	[self testImpl:input impl:[handler implementor] output:@"0000" tag:@"Delete first 4"];

	//======================delete from the end
	[handler setImplementor:[MacroXMLParser implementorForString:r1]];
	[handler deleteImplementorAt:([handler implementorCount]-1)];
	[self testImpl:input impl:[handler implementor] output:@"2340000" tag:@"Delete last 0"];

	[handler deleteImplementorAt:([handler implementorCount]-1)];
	[self testImpl:input impl:[handler implementor] output:@"340000" tag:@"Delete last 1"];

	[handler deleteImplementorAt:([handler implementorCount]-1)];
	[self testImpl:input impl:[handler implementor] output:@"40000" tag:@"Delete last 2"];

	[handler deleteImplementorAt:([handler implementorCount]-1)];
	[self testImpl:input impl:[handler implementor] output:@"0000" tag:@"Delete last 3"];

	[handler deleteImplementorAt:([handler implementorCount]-1)];
	[self testImpl:input impl:[handler implementor] output:@"0000" tag:@"Delete last 3"];

	//======================move around
	[handler setImplementor:[MacroXMLParser implementorForString:r1]];
	[handler moveImplementorFrom:0 to:2];
	[self testImpl:input impl:[handler implementor] output:@"14230000" tag:@"a-Move 0 to 2"];

	[handler moveImplementorFrom:2 to:0];
	[self testImpl:input impl:[handler implementor] output:@"12340000" tag:@"a-Move 2 to 0"];

	[handler moveImplementorFrom:3 to:0];
	[self testImpl:input impl:[handler implementor] output:@"23410000" tag:@"a-Move 3 to 0"];

	[handler moveImplementorFrom:0 to:3];
	[self testImpl:input impl:[handler implementor] output:@"12340000" tag:@"a-Move 0 to 3"];

	char expected[10];
	strcpy(expected, "12340000" );
	n = [handler implementorCount];

	for( NSUInteger from = 0; from < n; from++){
		for( NSUInteger to = 0; to < n; to++){
			if( to != from ){
				char tmp[10];
				memset(tmp, 0, 10);
				char * p_tmp = tmp;
				size_t s = strlen( expected );
				size_t i_exp = 0;
				size_t i_from = n-from-1;
				size_t i_to   = n-to-1;
				for( i_exp = 0; i_exp < s; i_exp++){
					if( i_from > i_to ){
						if( i_exp == i_to ){
							(*p_tmp++)=expected[i_from];
						}
						if( i_exp != i_from){
							(*p_tmp++)=expected[i_exp];
						}
					}else{
						if( i_exp != i_from){
							(*p_tmp++)=expected[i_exp];
						}

						if( i_exp == i_to ){
							(*p_tmp++)=expected[i_from];
						}
					}
				}
				strcpy(expected, tmp);
			}
			[[handler implementor] dump];
			[handler moveImplementorFrom:from to:to];
			[self assessTestResult:@"Implementor Count constant in loop" result:([handler implementorCount] == n) ];
			[self testImpl:input impl:[handler implementor] output:[NSString stringWithCString:expected encoding:NSUTF8StringEncoding]
					   tag:[NSString stringWithFormat:@"loop: from %lu to %lu", (unsigned long)from, (unsigned long)to]];

		}
	}

	[handler setImplementor:[MacroXMLParser implementorForString:r1]];
	[handler moveImplementorFrom:0 to:1];
	[self testImpl:input impl:[handler implementor] output:@"12430000" tag:@"b-Move 0 to 1"];

	[handler moveImplementorFrom:1 to:0];
	[self testImpl:input impl:[handler implementor] output:@"12340000" tag:@"b-Move 0 to 1"];

	[handler moveImplementorFrom:0 to:3];
	[self testImpl:input impl:[handler implementor] output:@"41230000" tag:@"b-Move 0 to 3"];

	//======================Move to same place
	[handler moveImplementorFrom:0 to:0];
	[self testImpl:input impl:[handler implementor] output:@"41230000" tag:@"b-Move 0 to 0"];

	[handler moveImplementorFrom:1 to:1];
	[self testImpl:input impl:[handler implementor] output:@"41230000" tag:@"b-Move 1 to 1"];

	[handler moveImplementorFrom:2 to:2];
	[self testImpl:input impl:[handler implementor] output:@"41230000" tag:@"b-Move 2 to 2"];

	[handler moveImplementorFrom:3 to:3];
	[self testImpl:input impl:[handler implementor] output:@"41230000" tag:@"b-Move 3 to 3"];

	//======================Create and Insert
	MacroImpl * newImp = [handler createNewImplForType:@"prefix"];
	[newImp setArgument:@"prefix" value:@"9"];

	[handler setImplementor:[MacroXMLParser implementorForString:r1]];
	[handler insertImplementor:newImp atIndex:0];
	[self testImpl:input impl:[handler implementor] output:@"123490000" tag:@"insert at 0"];

	newImp = [handler createNewImplForType:@"prefix"];
	[newImp setArgument:@"prefix" value:@"9"];
	[handler insertImplementor:newImp atIndex:2];
	[self testImpl:input impl:[handler implementor] output:@"1239490000" tag:@"insert at 2"];

	newImp = [handler createNewImplForType:@"prefix"];
	[newImp setArgument:@"prefix" value:@"9"];
	[handler insertImplementor:newImp atIndex:6];
	[self testImpl:input impl:[handler implementor] output:@"91239490000" tag:@"insert at 6"];

	newImp = [handler createNewImplForType:@"prefix"];
	[newImp setArgument:@"prefix" value:@"8"];
	[handler appendImplementor:newImp];
	[self testImpl:input impl:[handler implementor] output:@"891239490000" tag:@"append"];

	//=======================Replace
	[handler setImplementor:[MacroXMLParser implementorForString:r1]];

	newImp = [handler createNewImplForType:@"prefix"];
	[newImp setArgument:@"prefix" value:@"8"];

	[handler replaceImplementorAt:0 with:[newImp copy]];
	[self testImpl:input impl:[handler implementor] output:@"12380000" tag:@"replace at 0"];

	[handler replaceImplementorAt:3 with:[newImp copy]];
	[self testImpl:input impl:[handler implementor] output:@"82380000" tag:@"replace at 3"];

	[handler replaceImplementorAt:2 with:[newImp copy]];
	[self testImpl:input impl:[handler implementor] output:@"88380000" tag:@"replace at 2"];

	[handler replaceImplementorAt:1 with:[newImp copy]];
	[self testImpl:input impl:[handler implementor] output:@"88880000" tag:@"replace at 1"];

	/**/
}


-(void)runAutoLearnTests{
	MacroAutoLearner *	learner = nil;
	MacroImpl*			impl	= nil;

	learner = [[MacroAutoLearner alloc] init];

	// local number
	impl	= [learner implementorFor:@"1234" from:@"+8521234"];
	[self testImpl:@"+8521234"		impl:impl output:@"1234"		tag:@"Autolearn 1 recover self"	];
	[self testImpl:@"+331234567"	impl:impl output:@"1234567"		tag:@"Autolearn 1 recover 1"	];

	// local number + prefix
	impl	= [learner implementorFor:@"0001234" from:@"+8521234"];
	[self testImpl:@"+8521234"		impl:impl output:@"0001234"		tag:@"Autolearn 2 recover self"	];
	[self testImpl:@"+331234567"	impl:impl output:@"0001234567"	tag:@"Autolearn 2 recover 1"	];

	// last digits + prefix
	impl	= [learner implementorFor:@"0007654321" from:@"+852987654321"];
	[self testImpl:@"+852987654321"	impl:impl output:@"0007654321"			tag:@"Autolearn 3 recover self"	];
	[self testImpl:@"+33123456789"	impl:impl output:@"0003456789"			tag:@"Autolearn 3 recover 1"	];

	//  prefix
	impl	= [learner implementorFor:@"18521234" from:@"+8521234"];
	[self testImpl:@"+8521234"		impl:impl output:@"18521234"		tag:@"Autolearn 4 recover self"	];
	[self testImpl:@"+3312345"		impl:impl output:@"13312345"		tag:@"Autolearn 4 recover 1"	];

	// remove zero + prefix
	impl	= [learner implementorFor:@"+813000" from:@"03000"];
	[self testImpl:@"03000"		impl:impl output:@"+813000"			tag:@"Autolearn 5 recover self"	];
	[self testImpl:@"0912345"	impl:impl output:@"+81912345"		tag:@"Autolearn 5 recover 1"	];

	// Should be no rule:
	impl	= [learner implementorFor:@"+123456" from:@"12456"];
	[self assessTestResult:@"Failed to learn 1" result:(impl == nil)];
	// random
	impl	= [learner implementorFor:@"+123456" from:@"7890000"];
	[self assessTestResult:@"Failed to learn 2" result:(impl == nil)];
	//only 5 common digits
	impl	= [learner implementorFor:@"+000078901" from:@"345678901"];
	[self assessTestResult:@"Failed to learn 3" result:(impl == nil)];


}

-(void)runHandlerTests{
	[self startSession:@"Macro Handler"];
	[self runTestsHandler];
	[self runBuildRules];
	[self runAutoLearnTests];
	[self endSession:@"Macro Handler"];
}

@end
