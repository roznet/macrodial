//  MIT Licence
//
//  Created on 09/03/2009.
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

#import "DatabaseTests.h"
#import "RZUtils/RZUtils.h"
#import "UsageData.h"
#import <CoreLocation/CoreLocation.h>
@import Contacts;

// If left is current -> first
// If right is current -> right first
// else same
static NSInteger compareIntHelper( NSString * l, NSString * r, NSString * c ){
    NSInteger order = NSOrderedSame;
    NSComparisonResult lc = [l compare:c];
    NSComparisonResult rc = [r compare:c];
    if( lc == NSOrderedSame && rc != NSOrderedSame ){
        order = NSOrderedAscending;
    }else if( lc != NSOrderedSame && rc == NSOrderedSame ){
        order = NSOrderedDescending;
    }

    return( order );
}

static NSInteger sortUsage( RecentCallRecord*l,RecentCallRecord*r,RecentCallRecord*aCurrent){
    RecentCallRecord * c = aCurrent;
    NSInteger order = NSOrderedSame;

    // NSOrderedAscending -> Left Will appear first.
    // NSOrderedDescending -> Right will appear first.

    // first by location box,
    // First order for same contact, then for same idd
    // then by last use
    if( [c location] ){
        CLLocationDistance distanceL = [[l location] distanceFromLocation:[c location]];
        CLLocationDistance distanceR = [[r location] distanceFromLocation:[c location]];

        CLLocationDistance buckets[2] = { 50.0e3, 500.0e3 };
        for( int i = 0; i < 2 && order == NSOrderedSame; i++){
            if( distanceL < buckets[i] && distanceR > buckets[i] ){
                order = NSOrderedAscending;
            }else if( distanceL > buckets[i] && distanceR < buckets[i] ){
                order = NSOrderedDescending;
            }
        };
    };

    if( NSOrderedSame == order ){
        int commonL = [l commonPrefixLength:c];
        int commonR = [r commonPrefixLength:c];
        if( commonL < commonR ){
            order = NSOrderedDescending;
        }else if( commonL > commonR ){
            order = NSOrderedAscending;
        };
    }

    if( NSOrderedSame == order ){
        order = compareIntHelper([l contactId], [r contactId], [c contactId]);
    }

    if( NSOrderedSame == order ){
        double ld = [[l callTime] timeIntervalSinceDate:[c callTime]];
        double rd = [[r callTime] timeIntervalSinceDate:[c callTime]];
        // left is bigger, means longer ago,
        if( ld < rd ){
            order = NSOrderedAscending;
        }else if( ld > rd ){
            order = NSOrderedDescending;
        }
    }

    return( order );

}

@implementation DatabaseTests
@synthesize organizer,db;

-(NSArray*)testDefinitions{
    return @[
             @{@"selector":NSStringFromSelector(@selector(runDatabaseTests)),
               @"description":@"Test for Database",
               @"session":@"Database"},
             ];
}



-(void)dbSetup:(NSString*)path{
	db			= [[FMDatabase alloc] initWithPath:path];
	[db open];
	organizer	= [[MacroOrganizer alloc] initWithDb:db];
}
-(void)dbUnsetup{
	db = nil;
	organizer = nil;
}

-(void)testInitialSetup{
	NSFileManager	*	fileManager			= [NSFileManager defaultManager];
    NSString		*	writableFilePath	= [RZFileOrganizer writeableFilePath:@"macros_test.db"];
	BOOL				success;

	success = [fileManager fileExistsAtPath:writableFilePath];
	[self assessTestResult:@"File not there initially" result:!success];

	[RZFileOrganizer createEditableCopyOfFileIfNeeded:@"macros_test.db"];
	success = [fileManager fileExistsAtPath:writableFilePath];
	[self assessTestResult:@"File was created" result:success];


	[self dbSetup:writableFilePath];
	[MacroOrganizer upgradeDbToV1:db];
	[MacroOrganizer upgradeDbToV2:db];

	// Check it got reset fine:
	NSMutableArray * recent = [organizer retrieveCallRecords];
	[self assessTestResult:@"No recent files" result:([recent count] == 0)];

	[db executeUpdate:@"DELETE FROM macro_current"];
	[db executeUpdate:@"DELETE FROM macro_user_variables"];
	[db executeUpdate:@"DELETE FROM recent_calls"];

	[self checkNumberOfMacros:0];

	[organizer loadCurrentMacros];

	[self assessTestResult:@"Start with no macros" result:[organizer numberOfMacros]==0];
	[self dbUnsetup];
}

-(void)checkNumberOfMacros:(int)n{
	int  actual = -1;
	FMResultSet * rs = [db executeQuery:@"SELECT COUNT(*) FROM macro_current"];
	if( ![db hadError] && [rs next] ){
		actual = [rs intForColumn:@"COUNT(*)"];
	}
	[rs close];
	[self assessTestResult:[NSString stringWithFormat:@"Count(macros)==%d actual=%d", n, actual] result:(actual == n )];
}

-(void)testOrganizerRule:(NSString*)input expected:(NSString*)expected forIndex:(NSUInteger)i{
	NSString * result = [organizer macroEvaluate:i forNumber:input];

	[self assessTestResult:[NSString stringWithFormat:@"organizer[%@]:[%@]==[%@] %@", input,  result, expected, [organizer macroNameAtIndex:i]]
					result:[result isEqualToString:expected]];
}


-(void)runAddToDb{
	NSString * test1	= @"<rule><type>prefix</type><prefix>1</prefix></rule>";
	NSString * test1_1	= @"<rule><type>prefix</type><prefix>2</prefix></rule>";
	NSString * test2	= @"<rule><type>varprefix</type><variable>var</variable></rule>";
	NSString * test3	= @"<rule><type>prefix</type><prefix>4</prefix></rule>";

	NSString * name1    = @"test1";
	NSString * name2    = @"test2";
	NSString * name3	= @"test3";
	NSString * name4	= @"test4";
	NSUInteger idx;

	//------ Test 1
	[organizer addOrReplaceMacro:name1 definition:test1];
	idx = [organizer indexForMacroName:name1];
	[self assessTestResult:@"Found name1 in cache" result:(idx < [organizer numberOfMacros] )];
	[self testSimpleRule:@"0000"	rule:[organizer macroDefinitionAtIndex:idx]	output:@"10000"];
	[self testOrganizerRule:@"0000" expected:@"10000" forIndex:idx];

	[organizer forceRefresh];
	[organizer loadCurrentMacros];

	idx = [organizer indexForMacroName:name1];
	[self assessTestResult:@"Found name1 after reload" result:(idx < [organizer numberOfMacros] )];
	[self testSimpleRule:@"0000"	rule:[organizer macroDefinitionAtIndex:idx]	output:@"10000"];
	[self testOrganizerRule:@"0000" expected:@"10000" forIndex:idx];

	[organizer addOrReplaceMacro:name1 definition:test1_1];
	NSUInteger n_idx = [organizer indexForMacroName:name1];
	[self assessTestResult:@"Found redefinition at same idx" result:(idx == n_idx)];
	[self testSimpleRule:@"0000" rule:[organizer macroDefinitionAtIndex:n_idx] output:@"20000"];
	[self testOrganizerRule:@"0000" expected:@"20000" forIndex:idx];

	//---------- test2
	[organizer addOrReplaceMacro:name2 definition:test2];
	idx = [organizer indexForMacroName:name2];
	[self assessTestResult:@"Found name2 in cache" result:(idx < [organizer numberOfMacros] )];
	[[organizer macroVariablesAtIndex:idx] setObject:@"3" forKey:@"var"];
	[self testRuleWithVar:@"0000"
					rule:[organizer macroDefinitionAtIndex:idx]
					var:[organizer macroVariablesAtIndex:idx]
					output:@"30000"
					tag:@"test2 in cache"];
	[organizer	saveMacroVariable:idx];
	[self testOrganizerRule:@"0000" expected:@"30000" forIndex:idx];

	[organizer forceRefresh];
	[organizer loadCurrentMacros];

	idx = [organizer indexForMacroName:name2];
	[self assessTestResult:@"Found name2 after reload" result:(idx < [organizer numberOfMacros] )];
	[self testRuleWithVar:@"0000"
					 rule:[organizer macroDefinitionAtIndex:idx]
					  var:[organizer macroVariablesAtIndex:idx]
				   output:@"30000"
					  tag:@"test2 in cache"];
	[self testOrganizerRule:@"0000" expected:@"30000" forIndex:idx];

	//-------------test rename
	[organizer addOrReplaceMacro:name3 definition:test3];
	idx = [organizer indexForMacroName:name3];
	[self assessTestResult:@"Found name3 before rename" result:(idx < [organizer numberOfMacros] )];
	[self testRuleWithVar:@"0000"
					 rule:[organizer macroDefinitionAtIndex:idx]
					  var:[organizer macroVariablesAtIndex:idx]
				   output:@"40000"
					  tag:@"test3 in cache"];
	[self testOrganizerRule:@"0000" expected:@"40000" forIndex:idx];

	[organizer renameMacroAtIndex:idx newName:name4];
	idx = [organizer indexForMacroName:name3];
	[self assessTestResult:@"name3 not found after rename" result:(idx == [organizer numberOfMacros] )];

	idx = [organizer indexForMacroName:name4];
	[self assessTestResult:@"name4 found after rename" result:(idx < [organizer numberOfMacros] )];
	[self testRuleWithVar:@"0000"
					 rule:[organizer macroDefinitionAtIndex:idx]
					  var:[organizer macroVariablesAtIndex:idx]
				   output:@"40000"
					  tag:@"renamed test3 in cache"];

	[organizer forceRefresh];
	[organizer loadCurrentMacros];

	idx = [organizer indexForMacroName:name4];
	[self assessTestResult:@"name4 found after rename in db" result:(idx < [organizer numberOfMacros] )];
	[self testRuleWithVar:@"0000"
					 rule:[organizer macroDefinitionAtIndex:idx]
					  var:[organizer macroVariablesAtIndex:idx]
				   output:@"40000"
					  tag:@"renamed test4 in db"];

}

-(void)runFromWriteableDb{
    NSString	*	writableFilePath	= [RZFileOrganizer writeableFilePath:@"macros_test.db"];

	[self dbSetup:writableFilePath];

	[organizer loadCurrentMacros];

	NSString * name1    = @"test1";
	NSString * name2    = @"test2";
	NSString * name4    = @"test4";
	NSUInteger idx = INVALID_MACRO_INDEX;

	idx = [organizer indexForMacroName:name2];
	[self assessTestResult:@"Found name2 after reload" result:(idx < [organizer numberOfMacros] )];
	if( idx < [organizer numberOfMacros] ){
		[self testRuleWithVar:@"0000"
						 rule:[organizer macroDefinitionAtIndex:idx]
						  var:[organizer macroVariablesAtIndex:idx]
					   output:@"30000"
						  tag:@"test2 in cache"];
	}

	idx = [organizer indexForMacroName:name1];
	[self assessTestResult:@"Found name1 after reload" result:(idx < [organizer numberOfMacros] )];
	[self testSimpleRule:@"0000"	rule:[organizer macroDefinitionAtIndex:idx]	output:@"20000"];

	idx = [organizer indexForMacroName:name4];
	[self assessTestResult:@"Found name4 after reload" result:(idx < [organizer numberOfMacros] )];
	[self testSimpleRule:@"0000"	rule:[organizer macroDefinitionAtIndex:idx]	output:@"40000"];

	[self testRetrieveRecord];

	[self assessTestResult:@"No db error for writeable" result:[organizer db_errors]==0];

	[self dbUnsetup];
}

-(void)testUpgradeDb{

}

-(void)testCorruptedFile{
    NSString	*	writableFilePath	= [RZFileOrganizer writeableFilePath:@"macros_test.db"];

	[self dbSetup:writableFilePath];

	NSString * name1    = @"test1";
	NSString * name2    = @"test2";

	// corrupt definition of nam1 and variable of name2
	[db executeUpdate:@"DELETE FROM macro_current WHERE macro_name = ?", name1];
	[db executeUpdate:@"INSERT INTO macro_current (macro_name) VALUES (?)", name1];
	[db executeUpdate:@"DELETE FROM macro_user_variables WHERE variable_name = 'var'"];
	[db executeUpdate:@"INSERT INTO macro_user_variables (macro_id,variable_name) SELECT macro_id,'var' FROM macro_current WHERE macro_name = ?", name2];

	[organizer loadCurrentMacros];

	NSUInteger idx = INVALID_MACRO_INDEX;

	idx = [organizer indexForMacroName:name1];
	[self assessTestResult:@"corrupted name1 should not be loaded" result:idx==[organizer numberOfMacros]];
	FMResultSet * rs = [db executeQuery:@"SELECT * FROM macro_current WHERE macro_name = ?", name1];
	[self assessTestResult:@"name1 was deleted from the database after corruption" result:([rs next]==FALSE)];
	[rs close];

	idx = [organizer indexForMacroName:name2];
	NSDictionary * toTest = [organizer macroVariablesAtIndex:idx];
	[self assessTestResult:@"Var are empty after corruption" result:[toTest count]==0];
	[self assessTestResult:@"No db error after corruption" result:[organizer db_errors]==0];
	[self assessTestResult:@"Db isn't corrupted" result:[organizer dbIsCorrupted] == FALSE];
	[self dbUnsetup];

	// really corrupt the file now
    NSError * error = nil;
    [@"HELLO" writeToFile:writableFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
	[self dbSetup:writableFilePath];
	[organizer loadCurrentMacros];
	[self assessTestResult:@"Error were caught" result:[organizer db_errors]>0];
	[self assessTestResult:@"Very corrupted file" result:[organizer numberOfMacros] == 0];
	[self assessTestResult:@"Corruption detected" result:[organizer dbIsCorrupted]];
	[self dbUnsetup];
}

-(void)testRetrieveRecord{
	return;
    /*
	NSMutableArray*calls = [ organizer retrieveCallRecords];
	[self assessTestResult:@"Call record" result:[calls count]==2];

	if( [calls count] == 2 ){
		RecentCallRecord * retrieved1 = (RecentCallRecord*)[calls objectAtIndex:0];
		RecentCallRecord * retrieved2 = (RecentCallRecord*)[calls objectAtIndex:1];
		[self assessTestResult:@"retrieve1 name CN2" result:[[retrieved1 contactName] isEqualToString:@"CN2"]];
		[self assessTestResult:@"retrieve1 id 1"	result:([[retrieved1 contactId] isEqualToString:@"1"])];
		[self assessTestResult:@"retrieve2 name CN" result:[[retrieved2 contactName] isEqualToString:@"CN"]];
		[self assessTestResult:@"retrieve2 id 0"	result:([[retrieved2 contactId] isEqualToString:@"0"])];
	};
 */
}

-(void)runCallRecordTest{
	RecentCallRecord * record  = [[RecentCallRecord alloc] init];
	RecentCallRecord * record2 = [[RecentCallRecord alloc] init];

	[record setCallTime:[NSDate date]];
	[record setContactName:@"CN"		];
	[record setContactId:@"0"				];
	[record setMacroName:@"MN"			];
	[record setCallNumber:@"1234"		];

	[organizer saveCallRecord:record];

	[record2 setCallTime:[NSDate date]];
	[record2 setContactName:@"CN2"		];
	[record2 setContactId:@"1"				];
	[record2 setMacroName:@"MN2"		];
	[record2 setCallNumber:@"5678"		];

	[organizer saveCallRecord:record2	];
	[self testRetrieveRecord			];

}

-(CLLocation*)tweakLocation:(CLLocation*)aLoc{
	double latTw = (random() % 1000)/5000.0;
	double lonTw = (random() % 1000)/5000.0;
	double lat = [aLoc coordinate].latitude  + latTw ;
	double lon = [aLoc coordinate].longitude + lonTw;
	return( [[CLLocation alloc] initWithLatitude:lat longitude:lon] );
}

-(void)recordHelper:(RecentCallRecord*)aRecord c:(NSString*)aContact  i:(NSString*)aNumber m:(NSInteger)aMacro l:(CLLocation*)aLoc{
	[aRecord setContactId:aContact];
	[aRecord setOriginalNumber:aNumber];
	[aRecord setLocation:[self tweakLocation:aLoc]];
	[aRecord setMacroId:aMacro];
	[organizer macroRecordUse:aMacro forRecord:aRecord];
}
-(void)testUsageData{

	srandom( 123456 );

	NSDate * timer = [NSDate date];

	CLLocation * l_niseko			= [[CLLocation alloc] initWithLatitude:42.82	longitude:140.67];
	CLLocation * l_repulsebay		= [[CLLocation alloc] initWithLatitude:22.24	longitude:114.2];
	CLLocation * l_cheungkong		= [[CLLocation alloc] initWithLatitude:22.28	longitude:114.16];
	CLLocation * l_85broad			= [[CLLocation alloc] initWithLatitude:40.7	longitude:-74.01];
	CLLocation * l_cupertino		= [[CLLocation alloc] initWithLatitude:37.32	longitude:-122.04];
	CLLocation * l_paris			= [[CLLocation alloc] initWithLatitude:48.87	longitude:2.35];
	CLLocation * l_shenzhen			= [[CLLocation alloc] initWithLatitude:22.55	longitude:114.06];
	CLLocation * l_roppongihills	= [[CLLocation alloc] initWithLatitude:35.66	longitude:139.73];
	CLLocation * l_hkg				= [[CLLocation alloc] initWithLatitude:22.27	longitude:114.18];

	NSString   * i_us = @"1";
	NSString   * i_fr = @"33";
	NSString   * i_jp = @"81";

	//int			c_us = 1;
	NSString*			c_fr = @"2";
	NSString*			c_jp = @"3";

	int			m_fromhk = 1;
	int			m_fromjp = 0;
	//int			m_foru2	 = 2;

	NSArray * i_all = [NSArray arrayWithObjects:i_us, i_fr, i_jp, nil];
	NSArray * l_all = [NSArray arrayWithObjects:l_niseko, l_repulsebay, l_cheungkong, l_85broad, l_cupertino, l_paris, l_shenzhen,
					   l_roppongihills, l_hkg, nil];

	UsageData * data = [organizer usageData];
	RecentCallRecord * current = [[RecentCallRecord alloc] init];
	RecentCallRecord * record  = [[RecentCallRecord alloc] init];
	RecentCallRecord * record2 = [[RecentCallRecord alloc] init];
	[self recordHelper:record	c:c_jp	i:i_jp		m:m_fromhk		l:l_hkg];
	[self recordHelper:record	c:c_fr	i:i_fr		m:m_fromhk		l:l_hkg];
	[self recordHelper:record	c:c_jp	i:i_jp		m:m_fromjp		l:l_roppongihills];

	[current setLocation:		l_hkg];
	[current setContactId:		c_fr];
	[current setOriginalNumber:	i_fr];
	[current setCallTime:		[NSDate date]];

	[data orderFor:current];
	[organizer sortMacrosUsing:data];
	for( NSUInteger i = 0 ; i < [organizer numberOfMacros]; i++ ){
		[self log:[NSString stringWithFormat:@"%lu: %lu %@", (unsigned long)(i+1), (unsigned long)[organizer macroIdAtIndex:i],
                   [organizer macroNameAtIndex:i]]];
	}
	[self log:[NSString stringWithFormat:@"time to sort: %f", [timer timeIntervalSinceNow]*-1]];

	for( int i = 0;i<100;i++){
		NSInteger idx_l = random() % [l_all count];
		NSInteger idx_i = random() % [i_all count];
		NSString* c = [NSString stringWithFormat:@"%@",@( random() % 5 +1)];
		NSInteger m = random() % 3;

		[self recordHelper:record c:c i:[i_all objectAtIndex:idx_i] m:m l:[l_all objectAtIndex:idx_l]];
	}

	[self log:[NSString stringWithFormat:@"time to record: %f", [timer timeIntervalSinceNow]*-1]];
	timer = [NSDate date];

	[data loadFromDb];
	[data orderFor:current];
	[organizer sortMacrosUsing:data];
	for( int i = 0 ; i < [organizer numberOfMacros]; i++ ){
		[self log:[NSString stringWithFormat:@"%lu: %ld %@", (unsigned long)i+1, (long)[organizer macroIdAtIndex:i], [organizer macroNameAtIndex:i]]];
	}
	[self log:[NSString stringWithFormat:@"time to sort: %f", [timer timeIntervalSinceNow]*-1]];

	[self recordHelper:record	c:@"1" i:@"3314027"	m:1 l:l_repulsebay];
	[self recordHelper:record2	c:@"2" i:@"3332670"	m:1 l:l_paris];
	[self recordHelper:current	c:@"1" i:@"3324027"	m:1 l:l_repulsebay];
	[self assessTestResult:@"Compare distance" result:sortUsage(record, record2, current)==NSOrderedAscending];

	[self recordHelper:record	c:@"1" i:@"3314027"	m:1 l:l_repulsebay];
	[self recordHelper:record2	c:@"2" i:@"3322670"	m:1 l:l_repulsebay];
	[self recordHelper:current	c:@"3" i:@"3324027"	m:1 l:l_repulsebay];
	[self assessTestResult:@"Compare common numbers" result:sortUsage(record, record2, current)==NSOrderedDescending];

	// change contact, common number has precedence
	[self recordHelper:current	c:@"1" i:@"3324027"	m:1 l:l_repulsebay];
	[self assessTestResult:@"Compare common numbers" result:sortUsage(record, record2, current)==NSOrderedDescending];

}

-(void)runDatabaseTests{
	NSFileManager	*	fileManager			= [NSFileManager defaultManager];
    NSString		*	writableFilePath	= [RZFileOrganizer writeableFilePath:@"macros_test.db"];
	BOOL				success;
	NSError			*	error;

	// if file already exists tests we can recover state
	[self startSession:@"Database"];

    success = [fileManager fileExistsAtPath:writableFilePath];

	if( success ){
		[self runFromWriteableDb];
		[self testCorruptedFile];
		// now remove so we can start test from scratch
		success = [fileManager removeItemAtPath:writableFilePath error:&error];
		[self assessTestResult:@"Could Remove file" result:success];
	}


	[self testInitialSetup		];


	[self dbSetup:writableFilePath];
	[self runAddToDb			];
	[self runCallRecordTest		];
	[self testUsageData			];
	[self assessTestResult:@"No db error at the end" result:[organizer db_errors] == 0		];
	[self assessTestResult:@"Db isn't corrupted" result:[organizer dbIsCorrupted] == FALSE	];
	[self dbUnsetup];
	/**/
	[self endSession:@"Database"];
}


@end
