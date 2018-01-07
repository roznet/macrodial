//  MIT Licence
//
//  Created on 15/03/2009.
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

#import "WebMacrosTests.h"
#import "RZUtils/RZUtils.h"
#import "WebURLroznet.h"
#import "RemoteDownloadList.h"

#define MACRO_TEST_NAME @"__TEST__"

@interface WebMacrosTests ()
@property (nonatomic,strong) id cacheConnection;
@end

@implementation WebMacrosTests
@synthesize receivedString,receivedArray,expected,testSelector,currentTestInt,notifyee,notifyeeSelector;

-(NSArray*)testDefinitions{
    return @[
             @{@"selector":NSStringFromSelector(@selector(runDatabaseTests)),
               @"description":@"Test for Database",
               @"session":@"Database"},
             ];
}

-(NSString*)receivedListProperty:(NSString*)aProperty atIndex:(int)aIdx{
	if( ! receivedArray || aIdx >= [receivedArray count] ){
		return( nil );
	}
	NSDictionary * dict = [receivedArray objectAtIndex:aIdx];
	return( [dict objectForKey:aProperty] );
}
#pragma mark download test
-(void)testFoundHKThree{
	BOOL found = FALSE;
	for( int i=0;i<[[self receivedArray] count];i++ ){
		NSString * name = [self receivedListProperty:@"name" atIndex:i];
		if( [name isEqualToString:@"Hong Kong Three"] ){
			found = TRUE;
		}
	}
	[self assessTestResult:@"Found package Hong Kong Three" result:found];
	[self runNextTest];
}


-(void)runOneTest:(NSString*)url forClass:(Class)aClass expected:(ExpectedResult)expRes test:(SEL)aSel{
	[self setExpected:expRes];
	[self setTestSelector:aSel];
	// Will be freed in delegate function
	self.cacheConnection = [[aClass alloc] initWithURL:url andDelegate:self];
}

-(NSArray*)testCases{
	return( [NSArray arrayWithObjects:	@"local+0",		@"+81909975",	@"0909975",
										@"ローカル",		@"81909975",	@"0909975",
										nil] );
}

-(void)testDownloadMacro{
	NSArray * cases		= [self testCases];
	int i				= currentTestInt*3;
	NSString * input	= [cases objectAtIndex:i+1];
	NSString * output	= [cases objectAtIndex:i+2];
	if( receivedString )
		[self testSimpleRule:input rule:receivedString output:output];

	currentTestInt++;
	[self runNextTest];
}

-(void)runNextTest{
	NSArray * cases = [self testCases];
	int i = currentTestInt*3;
	NSUInteger n = [cases count]/3;

	if( currentTestInt == n ){
		[self runOneTest:WebStandardURL(@"list.php", @"packages", nil)
				forClass:[RemoteDownloadList class]
				expected:ExpectedArray
					test:@selector(testFoundHKThree)];
		currentTestInt++;
	}else if(currentTestInt<n){
		[self runOneTest:WebStandardURL( @"download.php", [NSString stringWithFormat:@"name=%@", [cases objectAtIndex:i]], nil)
				forClass:[RZRemoteDownload class]
				expected:ExpectedString
					test:@selector(testDownloadMacro)];
	}else{
		currentTestInt = 0;
		[self runNextUploadTest];
	}
}

#pragma mark upload test

-(NSArray*)testUploadCases{
	return( [NSArray arrayWithObjects:	MACRO_TEST_NAME,	@"<rule><type>makelocal</type></rule>", @"+81909975", @"909975",
			 nil] );
}

-(void)runOneUploadTest:(NSString*)url forName:(NSString*)aName andRule:(NSString*)aRule expected:(ExpectedResult)expRes test:(SEL)aSel{
	[self setExpected:expRes];
	[self setTestSelector:aSel];
	// Will be freed in delegate function
	NSDictionary * postData = [NSDictionary dictionaryWithObjectsAndKeys:
										aName,		@"macro_name",
										aRule,		@"macro_xml",
										MACRO_TEST_NAME,	@"macro_description",
										MACRO_TEST_NAME,	@"package_description",
										MACRO_TEST_NAME,	@"package_contact",
										MACRO_TEST_NAME,	@"package_name",
										@"",				@"unlock_code",
										nil];

	self.cacheConnection = [[RZRemoteDownload alloc] initWithURL:url postData:(NSDictionary*)postData andDelegate:self];
}

-(void)testUploadMacro{
	if( receivedString ){
		[self assessTestResult:@"uploaded" result:[receivedString isEqualToString:@"successfully uploaded"]];
	}
	currentTestInt++;
	[self runNextUploadTest];
}

-(void)runNextUploadTest{
	NSArray * cases = [self testUploadCases];
	int i = currentTestInt*4;
	NSUInteger n = [cases count]/4;

	if(currentTest<n){
		NSString * name	= [cases objectAtIndex:i];
		NSString * xml	= [cases objectAtIndex:i+1];

		[self runOneUploadTest:WebStandardURL( @"upload.php", @"", nil)
				forName:name
				andRule:xml
					  expected:ExpectedString
					test:@selector(testUploadMacro)];
	}else{
		[self endSession:@"Web Macro"];
        [self notifyNotifiee];
	}
}

#pragma mark perform Selectors
-(void)notifyNotifiee{
    id val = nil;
    if ([notifyee respondsToSelector:notifyeeSelector]) {
        // needs below because ARC can't call performSelector it does not know.
        IMP imp = [notifyee methodForSelector:notifyeeSelector];
        id (*func)(id, SEL) = (void *)imp;
        val = func(notifyee, notifyeeSelector);
    }

}

-(void)performTestSelector{
    id val = nil;
    if ([self respondsToSelector:self.testSelector]) {
        // needs below because ARC can't call performSelector it does not know.
        IMP imp = [self methodForSelector:self.testSelector];
        id (*func)(id, SEL) = (void *)imp;
        val = func(self, self.testSelector);
    }

}

#pragma mark upload received test
-(void)testUploadMacroReceived{
	NSArray * cases		= [self testUploadCases];
	int i				= currentTestInt*4;
	NSString * input	= [cases objectAtIndex:i+2];
	NSString * output	= [cases objectAtIndex:i+3];
	if( receivedString )
		[self testSimpleRule:input rule:receivedString output:output];

	currentTestInt++;
	[self runNextUploadTest];
}

-(void)runNextUploadReceivedTest{
	NSArray * cases = [self testUploadCases];
	int i = currentTestInt*4;
	NSUInteger n = [cases count]/4;

	if(currentTestInt<n){
		[self runOneTest:WebStandardURL( @"download.php", [NSString stringWithFormat:@"name=%@", [cases objectAtIndex:i]], nil)
				forClass:[RZRemoteDownload class]
				expected:ExpectedString
					test:@selector(testUploadReceivedMacro)];
	}else{
		[self endSession:@"Web Macro"];
        [self notifyNotifiee];
	}
}

#pragma mark General

-(void)runTests:(id)aObj sel:(SEL)aSelector{
	notifyee = aObj;
	notifyeeSelector = aSelector;
	[self startSession:@"Web Macro"];
	currentTestInt = 0;
	[self runNextTest];
}

-(void)downloadFailed:(id)connection{
	[self assessTestResult:@"Connection Failed was expected" result:([self expected]==ExpectedFailure)];
	[self setReceivedArray:nil];
	[self setReceivedString:nil];
    [self performTestSelector];
}
-(void)downloadArraySuccessful:(id)connection array:(NSArray*)theArray{
	[self setReceivedArray:nil];
	[self setReceivedString:nil];
	[self assessTestResult:@"Array was expected" result:([self expected]==ExpectedArray)];
	if([self expected]==ExpectedArray){
		[self setReceivedArray:theArray];
        [self performTestSelector];
	};
}
-(void)downloadStringSuccessful:(id)connection string:(NSString*)theString{
	[self setReceivedArray:nil];
	[self setReceivedString:nil];
	[self assessTestResult:@"String was expected" result:([self expected]==ExpectedString)];
	if([self expected]==ExpectedString){
		[self setReceivedString:theString];
        [self performTestSelector];
	};
}




@end
