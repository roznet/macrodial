//
//  MacroDialTests.m
//  MacroDialTests
//
//  Created by Brice Rosenzweig on 21/01/2018.
//

#import <XCTest/XCTest.h>
#import <RZUtilsTestInfra/RZUtilsTestInfra.h>
#import <RZUtils/RZUtils.h>

NSString * kExpectationAllDone = @"RZUnitRunner All Done";

@interface MacroDialTests : XCTestCase<RZUnitTestSource,RZChildObject>
@property (nonatomic,retain) RZUnitTestRunner * runner;
@property (nonatomic,retain) XCTestExpectation * expectation;
@property (nonatomic,retain) NSString * testClassToRun;

@end

@implementation MacroDialTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.runner = RZReturnAutorelease([[RZUnitTestRunner alloc] init]);
    self.runner.testSource = self;
    [self.runner attach:self];

}

- (void)tearDown {
    [self.runner detach:self];
    self.runner = nil;
    self.testClassToRun = nil;
    self.expectation = nil;

    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
-(void)rzRunnerExecute{
    self.expectation = [self expectationWithDescription:kExpectationAllDone];
    
    [self.runner run];
    
    [self waitForExpectations:@[ self.expectation ] timeout:60];
    for (RZUnitTestRecord * record in self.runner.collectedResults) {
        XCTAssertEqual(record.success, record.total, @"%@", record);
        if( record.success != record.total){
            for (UnitTestRecordDetail * detail in record.failureDetails) {
                // To put the error detail on the report
                XCTAssertTrue(false, @"%@", detail);
            }
        }
    }
}
-(NSArray*)testClassNames{
    return @[ self.testClassToRun];
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    if( [theInfo.stringInfo isEqualToString:kRZUnitTestAllDone] ){
        [self.expectation fulfill];
        self.expectation = nil;
    }
}

-(void)testConfig{
    self.testClassToRun = @"ConfigTests";
    [self rzRunnerExecute];
    
}

-(void)testMacros{
    self.testClassToRun = @"MacroTests";
    [self rzRunnerExecute];

}
- (void)testMacroHandler {
    self.testClassToRun = @"MacroHandlerTests";
    [self rzRunnerExecute];

}

-(void)testPhoneNumberTests{
    self.testClassToRun = @"PhoneNumberTests";
    [self rzRunnerExecute];
}


@end
