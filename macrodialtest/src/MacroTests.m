//  MIT Licence
//
//  Created on 20/02/2009.
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

#import "MacroTests.h"
#import "MacroXMLParser.h"

@implementation MacroTests

-(NSArray*)testDefinitions{
    return @[
             @{@"selector":NSStringFromSelector(@selector(runTestsBasics)),
               @"description":@"Macro Basics",
               @"session":@"Macro Basics"},
             @{@"selector":NSStringFromSelector(@selector(runTestsComplex)),
               @"description":@"Macro Complex",
               @"session":@"Macro Complex"},
             @{@"selector":NSStringFromSelector(@selector(runTestsInvalid)),
               @"description":@"Macro Invalid",
               @"session":@"Macro Invalid"},

             ];
}


-(void)testSimpleRule:(NSString*)number impl:(MacroImpl*)aImpl output:(NSString*)expected{
	PhoneNumber * pn	= [[PhoneNumber alloc]	initWithString:number];
	[aImpl execute:pn data:[[NSDictionary alloc] init]];

	[self assessTestResult:	[NSString stringWithFormat:@"f[%@]:[%@]==[%@] %@", number,  [pn outputNumber], expected, [aImpl toXML]]
					result:[[pn outputNumber] isEqualToString:expected]];

}

-(void)testSimpleRule:(NSString*)number rule:(NSString*)str output:(NSString*)expected{
	MacroImpl	* imp	= [MacroXMLParser		implementorForString:str];
	[self testSimpleRule:number impl:imp output:expected];
}

-(void)testRuleWithVar:(NSString*)number rule:(NSString*)str var:(NSDictionary*)dict output:(NSString*)expected tag:(NSString*)aTag{
	PhoneNumber * pn	= [[PhoneNumber alloc] initWithString:number];
	MacroImpl	* imp	= [MacroXMLParser implementorForString:str];

	NSMutableArray * keys = [imp variablesNames];

	BOOL success = TRUE;
	for( id key in keys ){
		if( ! [dict objectForKey:key] )
			success = FALSE;
	}
	[self assessTestResult:@"All variables in" result:success];

	[imp execute:pn data:dict];

	[self assessTestResult:	[NSString stringWithFormat:@"f[%@]:[%@]==[%@] %@", number,  [pn outputNumber], expected, aTag]
					result:[[pn outputNumber] isEqualToString:expected]];

	NSString *		replayXML	= [imp toXML];
	MacroImpl *		replayImp	= [MacroXMLParser implementorForString:replayXML];
	PhoneNumber *	replayPn	= [[PhoneNumber alloc] initWithString:number];
	[replayImp execute:replayPn	data:dict];
	[self assessTestResult:	[NSString stringWithFormat:@"replay[%@]:[%@]==[%@] %@", number,  [pn outputNumber], [replayPn outputNumber], aTag]
					result:[[pn outputNumber] isEqualToString:[replayPn outputNumber]]];

}


-(NSString*)buildRuleFromArray:(NSArray*)ar{
	NSString * rv = @"";
	NSUInteger i;
	NSUInteger n= [ar count];

	for( i=0;i<n;i+=2){
		if( i+1 < n ){
			// process in reverse so output rule is in left to right of input array
			rv = [NSString stringWithFormat:[ar objectAtIndex:(n-2-i)], [ar objectAtIndex:(n-i-1)], rv ];
		}
	}
	return( rv );
}

-(void)runTestsInvalid{
    [self startSession:@"Macro Invalid"];

	NSString * notXML		= @"HELLO";
	NSString * unknownType	= @"<rule><type>UNKNOWN</type></rule>";
	NSString * incomplete	= @"<rule><type>prefix";
	NSString * missingArg   = @"<rule><type>prefix</type><suffix>1</suffix></rule>";
	NSString * emptyRule    = @"<rule></rule>";

	[self testSimpleRule:@"123456" rule:notXML			output:@"123456"];
	[self testSimpleRule:@"123456" rule:unknownType		output:@"123456"];
	[self testSimpleRule:@"123456" rule:incomplete		output:@"123456"];
	[self testSimpleRule:@"123456" rule:missingArg		output:@"123456"];
	[self testSimpleRule:@"123456" rule:emptyRule		output:@"123456"];
	[self testSimpleRule:@"123456" rule:nil				output:@"123456"];

    [self endSession:@"Macro Invalid"];
}

-(void)runTestsComplex{
    [self startSession:@"Macro Complex"];

	NSDictionary * variables	= [NSDictionary dictionaryWithObjectsAndKeys:@"8", @"a", @"9", @"b", nil];

	NSString * basePrefix		= @"<rule><type>prefix</type><prefix>%@</prefix>%@</rule";
	NSString * baseSuffix		= @"<rule><type>suffix</type><suffix>%@</suffix>%@</rule>";
	NSString * baseVarPrefix	= @"<rule><type>varprefix</type><variable>%@</variable>%@</rule>";
	NSString * baseVarSuffix	= @"<rule><type>varsuffix</type><variable>%@</variable>%@</rule>";

	NSString * r1 = [self buildRuleFromArray:[NSArray arrayWithObjects:	basePrefix,		@"1",
																		baseSuffix,		@"2",
																		basePrefix,		@"3",
																		baseSuffix,		@"4",
																		nil ]];
	NSString * r2 = [self buildRuleFromArray:[NSArray arrayWithObjects:	baseVarPrefix,	@"a",
																		baseVarSuffix,	@"b",
																		baseVarPrefix,	@"b",
																		baseVarSuffix,	@"a",
																		nil ]];

	[self testRuleWithVar:@"0"	rule:r1		var:variables	output:@"31024"	tag:@"r1"];
	[self testRuleWithVar:@"0"	rule:r2		var:variables	output:@"98098"	tag:@"r2"];

    [self endSession:@"Macro Complex"];

}

-(void)runTestsBasics{
    [self startSession:@"Macro Basics"];

	// Prefix			tested
	// Suffix			tested
	// local			tested
	// removeplus
	// lastdigits		tested
	// firstdigits
	// varsuffix		tested
	// varprefix		tested
	// removeprefix		tested
	// removesuffix		tested
	// replace			tested
	// replaceplus		tested
	// replaceprefix	tested
	// replacesuffix	tested
	// pauseprefix
	// pausesuffix
	// noop

	NSString * idd				= @"<rule><type>prefix</type><prefix>1966</prefix></rule>";
	NSString * ext 				= @"<rule><type>suffix</type><suffix>1966</prefix></rule>";
	NSString * local			= @"<rule><type>local</type></rule>";
	NSString * localPlusZeroBad = @"<rule><prefix>0</prefix><type>prefix</type><rule><type>local</type></rule></rule>";
	NSString * localPlusZero	= @"<rule><type>local</type><rule><prefix>0</prefix><type>prefix</type></rule></rule>";
	NSString * last8			= @"<rule><type>lastdigits</type><n>8</n></rule>";
	NSString * disa8			= @"<rule><type>lastdigits</type><n>8</n><rule><type>prefix</type><prefix>12345678,123456,8</prefix></rule></rule>";
	NSString * suffixVar		= @"<rule><type>varsuffix</type><variable>password</variable></rule>";
	NSString * prefixVar		= @"<rule><type>varprefix</type><variable>password</variable></rule>";
	NSString * multiVar1		= @"<rule><type>varsuffix</type><variable>password</variable><rule><type>varprefix</type><variable>country code</variable></rule></rule>";
	NSString * multiVar2		= @"<rule><type>varprefix</type><variable>password</variable><rule><type>varsuffix</type><variable>country code</variable></rule></rule>";
	NSString * multiVar3		= @"<rule><type>varprefix</type><variable>password</variable><rule><type>varprefix</type><variable>country code</variable></rule></rule>";
	NSString * replace1			= @"<rule><type>replace</type><search>123</search><replace>000</replace></rule>";
	NSString * replace2			= @"<rule><type>replaceplus</type><replace>000</replace></rule>";
	NSString * replace3			= @"<rule><type>replaceprefix</type><search>123</search><replace>000</replace></rule>";
	NSString * replace4			= @"<rule><type>replacesuffix</type><search>123</search><replace>000</replace></rule>";
	NSString * removeprefix     = @"<rule><type>removeprefix</type><prefix>123</prefix></rule>";
	NSString * removesuffix     = @"<rule><type>removesuffix</type><suffix>123</suffix></rule>";
	NSString * replaceRegex     = @"<rule><type>replaceregexp</type><regexp>^0</regexp><replace>1</replace></rule>";

	NSDictionary * variables	= [NSDictionary dictionaryWithObjectsAndKeys:@"11", @"password", @"852", @"country code", nil];

	//Variables
	[self testRuleWithVar:@"1 212 12345"	rule:suffixVar	var:variables	output:@"12121234511"	tag:@"suffix852"];

	[self testRuleWithVar:@"1 212 12345"	rule:prefixVar	var:variables	output:@"11121212345"	tag:@"prefix11"];
	[self testRuleWithVar:@"0000"			rule:multiVar1	var:variables	output:@"852000011"		tag:@"prefix852suffix11"];
	[self testRuleWithVar:@"0000"			rule:multiVar2	var:variables	output:@"110000852"		tag:@"prefix11suffix852"];
	[self testRuleWithVar:@"0000"			rule:multiVar3	var:variables	output:@"852110000"		tag:@"prefix852prefix11"];

	//add prefix/suffix
	[self testSimpleRule:@"1 212 1234"			rule:idd					output:@"196612121234"];
	[self testSimpleRule:@"1 212 1234"			rule:ext					output:@"121212341966"];

    //replaceregexp
    [self testSimpleRule:@"001" rule:replaceRegex output:@"101"];
    [self testSimpleRule:@"201" rule:replaceRegex output:@"201"];

	//remove prefix/suffix

	// lastdigits/firstdigits
	[self testSimpleRule:@"81 3 12345678"		rule:last8					output:@"12345678"];

	//country codes
	[self testSimpleRule:@"+81 3 123456"		rule:local					output:@"3123456"];

	//multirules
	[self testSimpleRule:@"81 3 123456"			rule:localPlusZero			output:@"03123456"];
	[self testSimpleRule:@"81 3 123456"			rule:localPlusZeroBad		output:@"0813123456"];
	[self testSimpleRule:@"81 3 1122-3344"		rule:disa8					output:@"12345678,123456,811223344"];

	//replace
	[self testSimpleRule:@"123456"				rule:replace1				output:@"000456"];
	[self testSimpleRule:@"123123"				rule:replace1				output:@"000000"];
	[self testSimpleRule:@"+123456"				rule:replace2				output:@"000123456"];
	[self testSimpleRule:@"+123456"				rule:replace3				output:@"+123456"];
	[self testSimpleRule:@"123456"				rule:replace3				output:@"000456"];
	[self testSimpleRule:@"123123"				rule:replace3				output:@"000123"];
	[self testSimpleRule:@"223123"				rule:replace3				output:@"223123"];
	[self testSimpleRule:@"123456"				rule:replace4				output:@"123456"];
	[self testSimpleRule:@"123123"				rule:replace4				output:@"123000"];

	//removesuffix/prefix
	[self testSimpleRule:@"123456"				rule:removeprefix				output:@"456"];
	[self testSimpleRule:@"+123123"				rule:removeprefix				output:@"+123123"];
	[self testSimpleRule:@"123456"				rule:removesuffix				output:@"123456"];
	[self testSimpleRule:@"+123123"				rule:removesuffix				output:@"+123"];

    [self endSession:@"Macro Basics"];

}
@end
