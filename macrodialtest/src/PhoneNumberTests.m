//  MIT Licence
//
//  Created on 19/02/2009.
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

#import "PhoneNumberTests.h"
#import "PhoneNumber.h"


@implementation PhoneNumberTests

-(NSArray*)testDefinitions{
    return @[
             @{@"selector":NSStringFromSelector(@selector(runPhoneNumbersTests)),
               @"description":@"Tests Phone Numbers",
               @"session":@"Phone Numbers"},
             ];
}

-(void)testCountryCode:(NSString*)number countryCode:(NSString*)expected{
	PhoneNumber * pn = [[PhoneNumber alloc] initWithString:number];
	[self assessTestResult:	[NSString stringWithFormat:@"Country Code[%@]:[%@]==[%@]", pn.number, pn.countryCode, expected]
					result:[pn.countryCode isEqualToString:expected]];
}

-(void)testAddPrefix:(NSString*)number prefix:(NSString*)aPrefix output:(NSString*)expected{
	PhoneNumber * pn = [[PhoneNumber alloc] initWithString:number];
	[pn addPrefix:aPrefix];
	[self assessTestResult:	[NSString stringWithFormat:@"AddPrefix[%@|%@]:[%@]==[%@]", pn.number, aPrefix, [pn outputNumber], expected]
					result:[[pn outputNumber] isEqualToString:expected]];
}


-(void)testAddSuffix:(NSString*)number suffix:(NSString*)aSuffix output:(NSString*)expected{
	PhoneNumber * pn = [[PhoneNumber alloc] initWithString:number];
	[pn addSuffix:aSuffix];
	[self assessTestResult:	[NSString stringWithFormat:@"AddSuffix[%@|%@]:[%@]==[%@]", pn.number, aSuffix, [pn outputNumber], expected]
					result:[[pn outputNumber] isEqualToString:expected]];
}


-(void)testMakeLocal:(NSString*)number output:(NSString*)expected{
	PhoneNumber * pn = [[PhoneNumber alloc] initWithString:number];
	[pn removeCountryCode];
	[self assessTestResult:	[NSString stringWithFormat:@"removeCountryCode [%@]:[%@]==[%@]", pn.number, [pn outputNumber], expected]
					result:[[pn outputNumber] isEqualToString:expected]];
}

-(void)testLastDigits:(NSString*)number n:(int)n output:(NSString*)expected{
	PhoneNumber * pn = [[PhoneNumber alloc] initWithString:number];
	[pn lastDigits:n];
	[self assessTestResult:	[NSString stringWithFormat:@"LastDigits[%@|%d]:[%@]==[%@]", pn.number, n, [pn outputNumber], expected]
					result:[[pn outputNumber] isEqualToString:expected]];
}

-(void)testSelector:(SEL)aSelector onNumber:(NSString*)number expected:(NSString*)expected{
	PhoneNumber * pn = [[PhoneNumber alloc] initWithString:number];
	[pn performOperation:aSelector];
	[self assessTestResult:	[NSString stringWithFormat:@"%@[%@]:[%@]==[%@]", NSStringFromSelector(aSelector), pn.number, [pn outputNumber], expected]
					result:[[pn outputNumber] isEqualToString:expected]];
}

-(void)testSelector:(SEL)aSelector withStringArg:(NSString*)aStr onNumber:(NSString*)number expected:(NSString*)expected{
	PhoneNumber * pn = [[PhoneNumber alloc] initWithString:number];
	[pn performOperation:aSelector withObject:aStr];
	[self assessTestResult:	[NSString stringWithFormat:@"%@[%@|%@]:[%@]==[%@]", NSStringFromSelector(aSelector), pn.number, aStr, [pn outputNumber], expected]
					result:[[pn outputNumber] isEqualToString:expected]];
}

-(void)testSelector:(SEL)aSelector withArg:(NSString*)aStr andArg:(NSString*)otherStr onNumber:(NSString*)number expected:(NSString*)expected{
	PhoneNumber * pn = [[PhoneNumber alloc] initWithString:number];
	[pn performOperation:aSelector withObject:aStr withObject:otherStr];

	[self assessTestResult:	[NSString stringWithFormat:@"%@[%@|%@,%@]:[%@]==[%@]",
											NSStringFromSelector(aSelector),
											pn.number,
											aStr,
											otherStr,
											[pn outputNumber],
											expected]
					result:[[pn outputNumber] isEqualToString:expected]];
}

-(void)testHasSelector:(SEL)aSelector withStringArg:(NSString*)aStr onNumber:(NSString*)number expected:(NSString*)expected{
	PhoneNumber * pn = [[PhoneNumber alloc] initWithString:number];
    // needs below because ARC can't call performSelector it does not know.
    IMP imp = [pn methodForSelector:aSelector];
    NSString * (*func)(id, SEL,NSString*) = (void*)imp;
    NSString * rv = func(pn, aSelector, aStr);

	[self assessTestResult:	[NSString stringWithFormat:@"%@[%@|%@]:[%@]==[%@]", NSStringFromSelector(aSelector), pn.number, aStr, rv, expected]
					result:[rv isEqualToString:expected]];
}


-(void)runPhoneNumbersTests{

	[self startSession:@"Phone Numbers"];

	[self testSelector:@selector(removePrefix:) withStringArg:@"123" onNumber:@"123456" expected:@"456"];
	[self testSelector:@selector(removeSuffix:) withStringArg:@"123" onNumber:@"123456" expected:@"123456"];

	[self testSelector:@selector(removePrefix:) withStringArg:@"456" onNumber:@"123456" expected:@"123456"];
	[self testSelector:@selector(removeSuffix:) withStringArg:@"456" onNumber:@"123456" expected:@"123"];

	[self testSelector:@selector(replaceString:with:) withArg:@"456" andArg:@"000" onNumber:@"123456" expected:@"123000"];
	[self testSelector:@selector(replaceString:with:) withArg:@"456" andArg:@"000" onNumber:@"123123" expected:@"123123"];
	[self testSelector:@selector(replaceString:with:) withArg:@"4"	 andArg:@"0"   onNumber:@"123444" expected:@"123000"];

	[self testSelector:@selector(regexReplace:with:) withArg:@"^0"	 andArg:@"1"   onNumber:@"001" expected:@"101"];
	[self testSelector:@selector(regexReplace:with:) withArg:@"^0"	 andArg:@"1"   onNumber:@"201" expected:@"201"];
	[self testSelector:@selector(regexReplace:with:) withArg:@"[01]$"	 andArg:@"9"   onNumber:@"1101" expected:@"1109"];
	[self testSelector:@selector(regexReplace:with:) withArg:@"[01]$"	 andArg:@"9"   onNumber:@"1100" expected:@"1109"];
	[self testSelector:@selector(regexReplace:with:) withArg:@"[01]$"	 andArg:@"9"   onNumber:@"1102" expected:@"1102"];
	[self testSelector:@selector(regexReplace:with:) withArg:@"[01]$"	 andArg:@"9"   onNumber:@"1102" expected:@"1102"];

	[self testSelector:@selector(addPlus) onNumber:@"123456" expected:@"+123456"];

	[self testHasSelector:@selector(commonPrefix:) withStringArg:@"123400" onNumber:@"123456" expected:@"1234"];
	[self testHasSelector:@selector(commonPrefix:) withStringArg:@"12340"  onNumber:@"123456" expected:@"1234"];
	[self testHasSelector:@selector(commonPrefix:) withStringArg:@"123400" onNumber:@"12345"  expected:@"1234"];

	[self testHasSelector:@selector(commonSuffix:) withStringArg:@"23456"  onNumber:@"000456" expected:@"456"];
	[self testHasSelector:@selector(commonSuffix:) withStringArg:@"123456" onNumber:@"00456"  expected:@"456"];
	[self testHasSelector:@selector(commonSuffix:) withStringArg:@"123456" onNumber:@"000456" expected:@"456"];

	[self testCountryCode:@"+1(212)123-4567"	countryCode:@"1"];
	[self testCountryCode:@"331234567"			countryCode:@"33"];
	[self testCountryCode:@"+852-1234-1234"		countryCode:@"852"];
	[self testCountryCode:@"0-1234-1234"		countryCode:@""];

	[self testAddPrefix:@"1(212)123456"			prefix:@"1966"		output:@"19661212123456"];
	[self testAddPrefix:@"(212)123456"			prefix:@"1"			output:@"1212123456"];

	[self testAddSuffix:@"1(212)123456"			suffix:@"11"		output:@"121212345611"];
	[self testAddSuffix:@"(212)123456"			suffix:@"22"		output:@"21212345622"];


	[self testMakeLocal:@"+1212 123-456"		output:@"212123456"];
	[self testMakeLocal:@"33 1 11 22 33 44"		output:@"111223344"];
	[self testMakeLocal:@"+33 1 11 22 33 44"	output:@"111223344"];
	[self testMakeLocal:@"+86 (1) 2340000"		output:@"12340000"];
	[self testMakeLocal:@"+4(4) 1234"			output:@"1234"];

	[self testLastDigits:@"+1212 1234"		n:4 output:@"1234"];
	[self testLastDigits:@"+86 212 1234"	n:4 output:@"1234"];

	[self endSession:@"Phone Numbers"];

}
@end
