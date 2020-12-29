//  MIT Licence
//
//  Created on 23/02/2009.
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

#import "MacroOrganizer.h"
#import "AppConstants.h"
#import "MacroXMLParser.h"


@implementation MacroOrganizerElement
@synthesize name,definition,macroId,variables;

-(MacroOrganizerElement*)init{
	if (!(self = [super init])) return nil;
	if( self ){
		name = nil;
		definition = nil;
		macroId = INVALID_MACRO_ID;
		variables = nil;
	}
	return( self );
}


-(NSNumber*)macroIdAsNumber{
	return( @(macroId) );
}
@end

@implementation MacroOrganizer
@synthesize db, currentMacros,db_errors,usageData;

-(MacroOrganizer*)initWithDb:(FMDatabase*)aDb{
	if( self = [super init] ){
		db = aDb;

		currentMacros				= [[NSMutableArray	alloc] initWithCapacity:10];
		usageData					= [[UsageData		alloc] initUsageWithDb:db];

		db_errors					= 0;
		[self cleanupOldCallRecords];
	};
	return( self );
}


-(void)forceRefresh{

	[currentMacros	removeAllObjects];
	[usageData		loadFromDb];

	db_errors		= 0;
}

-(void)loadCurrentMacros{
	PROFILE_START();
	if( [currentMacros count] == 0 ){
		FMResultSet *rs = [db executeQuery:@"SELECT macro_id,macro_name,definition FROM macro_current ORDER BY lastuse DESC"];
		[self checkDbError];
		while ([rs next]) {
			MacroOrganizerElement * elem = [[MacroOrganizerElement alloc] init];
			[elem setMacroId:[rs intForColumn:@"macro_id"]];
			[elem setName:[rs stringForColumn:@"macro_name"]];
			[elem setDefinition:[rs stringForColumn:@"definition"]];

			BOOL valid = [elem name] != nil && [elem definition] != nil;
			if( valid ){

				NSMutableDictionary * aDict = [[NSMutableDictionary alloc] init];

				FMResultSet *rs_var = [db executeQuery:@"SELECT variable_name,variable_value FROM macro_user_variables WHERE macro_id = ?",
									   [NSNumber numberWithInt:[rs intForColumn:@"macro_id"]]
									   ];
				[self checkDbError];
				while ([rs_var next]) {
					if( [rs_var stringForColumn:@"variable_value"] && [rs_var stringForColumn:@"variable_name"] )
						[aDict setObject:[rs_var stringForColumn:@"variable_value"] forKey:[rs_var stringForColumn:@"variable_name"]];
				}

				[elem setVariables:aDict];
				[currentMacros addObject:elem];

				[rs_var close];
			}else{
				[self deleteMacroInDB:[elem macroId]];
			}
		}
		[rs close];
	}
	PROFILE_STOP( @"loadCurrentMacros:end" );
};

-(MacroOrganizerElement*)elementAtIndex:(NSUInteger)idx{
    return( idx<currentMacros.count ? [currentMacros objectAtIndex:idx] : nil);
}


-(void)saveMacroVariable:(NSUInteger)idx{
	if( idx < [self numberOfMacros] ){
		MacroOrganizerElement*elem = [self elementAtIndex:idx];
		NSNumber * macro_id = [elem macroIdAsNumber];
		NSMutableDictionary * vars = [elem variables];
		NSString * v_name;
		NSString * v_value;
		BOOL need_update = FALSE;
		BOOL need_insert = TRUE;
		for( v_name in vars ){
			v_value = [vars objectForKey:v_name];
			FMResultSet * rs_check = [ db executeQuery:@"SELECT * FROM macro_user_variables WHERE macro_id = '?' AND variable_name = '?'",
									  macro_id, v_name ];
			[self checkDbError];
			while ([rs_check next]) {
				need_insert = FALSE;
				if( ![[rs_check stringForColumn:@"variable_value"] isEqualToString:v_value] ){
					need_update = true;
				}
			}
			[rs_check close];

			if( need_insert ){
				[db executeUpdate:@"INSERT INTO macro_user_variables ('macro_id','variable_name','variable_value') VALUES(?,?,?)",
				 macro_id, v_name, v_value];
			}
			if( need_update ){
				[db executeUpdate:@"UPDATE macro_user_variables SET 'variable_value' = ? WHERE macro_id = ? AND variable_name =?",
				 v_value, macro_id, v_name ];
			}
			[self checkDbError];
		}
	}
}
-(BOOL)checkDbError{
	BOOL rv = FALSE;
	if( [db hadError] ){
		NSString * er = [db lastErrorMessage];
#ifdef TARGET_IPHONE_SIMULATOR
		NSLog(@"%@",er);
#endif
		rv = TRUE;
		db_errors++;
	}
	return( rv );
}

-(BOOL)dbIsCorrupted{
	BOOL rv = FALSE;
	[db executeQuery:@"SELECT * FROM macro_current"];
	if( [db hadError] ){
		rv = TRUE;
	}
	return( rv );
}


//If a variable exists with this name, use that as default
-(NSString*)macroVariablesValueGuess:(NSString*)name{
	NSString*rv = nil;
	FMResultSet * rs_check = [ db executeQuery:@"SELECT * FROM macro_user_variables WHERE variable_name = ?", name];
	[self checkDbError];
	while ([rs_check next]) {
		rv = [rs_check stringForColumn:@"variable_value"];
	}
	[rs_check close];
	return( rv );
}

#pragma mark Access Cache Information

-(NSUInteger)indexForMacroName:(NSString*)aName{
	NSUInteger i=INVALID_MACRO_INDEX;
	NSUInteger n=[currentMacros count];
	for( i = 0 ; i < n; i++ ){
		if( [aName isEqualToString:[[self elementAtIndex:i] name]] ){
			break;
		}
	}
	return( i );
}

-(NSUInteger)macroForXML:(NSString*)aXML{
	NSUInteger i=0;
	NSUInteger n=[currentMacros count];
	for( i = 0 ; i < n; i++ ){
		if( [aXML isEqualToString:[[self elementAtIndex:i] definition]] ){
			break;
		}
	}
	return( i );
}

-(NSUInteger)numberOfMacros{
	return( [currentMacros count] );
}

-(NSArray*)macroNames{
	NSMutableArray * rv = [NSMutableArray arrayWithCapacity:[currentMacros count]];
	for( MacroOrganizerElement * elem in currentMacros ){
		[rv addObject:[elem name]];
	}
	return( rv );
}


-(BOOL)validIndex:(NSUInteger)i{
	return( i < [currentMacros count]);
}

-(NSString*)macroNameForId:(MacroId)i{
	for( MacroOrganizerElement * elem in currentMacros ){
		if( [elem macroId] == i ){
			return( [elem name] );
		}
	}
	return( nil );
}

-(NSString*)macroNameAtIndex:(NSUInteger)i{

	return( [self validIndex:i] ? [[self elementAtIndex:i] name] : nil );
}
-(NSString*)macroDefinitionAtIndex:(NSUInteger)i{
	return( [self validIndex:i] ? [[self elementAtIndex:i] definition] : nil);
}
-(NSMutableDictionary*)macroVariablesAtIndex:(NSUInteger)i{
	return( [self validIndex:i] ? [[self elementAtIndex:i] variables]: nil );
}
-(MacroId)macroIdAtIndex:(NSUInteger)i{
	return( [self validIndex:i] ? [[self elementAtIndex:i] macroId] : INVALID_MACRO_ID );
}

-(NSString*)macroEvaluate:(NSUInteger)i forNumber:(NSString*)aNumber{
	NSString*				output;
	PhoneNumber*			pn			=	[[PhoneNumber alloc]	initWithString:aNumber];
	MacroImpl*				imp			=	[self macroImplAtIndex:i];
	NSMutableDictionary*	aDict		=	[self macroVariablesAtIndex:i];
	NSMutableArray *		missing		=	[imp missingVariablesForDict:aDict];

	if( [missing count] != 0 ){
		BOOL oneDone = FALSE;
		for( NSString *aMissing in missing){
			NSString * guess = [self macroVariablesValueGuess:aMissing];
			if( guess ){
				oneDone = TRUE;
				[aDict setObject:guess forKey:aMissing];
			}
		}
		missing		=	[imp missingVariablesForDict:aDict];
		if( oneDone )
			[self saveMacroVariable:i];
	}

	if( [missing count] == 0 ){
		[imp execute:pn data:aDict];
		output = [pn outputNumber];
	}else {
		output = NSLocalizedString( @"Missing Var", @"" );
	}
	return( output );
}

-(MacroImpl*)macroImplAtIndex:(NSUInteger)i{
	return( [self validIndex:i] ? [MacroXMLParser	implementorForString:[[self elementAtIndex:i] definition]] : nil );
}

-(void)sortMacrosUsing:(UsageData*)aUsage{
    [currentMacros sortUsingComparator:^(MacroOrganizerElement * left, MacroOrganizerElement * right){
        NSInteger rankLeft		= [aUsage	rankMacroId:[left  macroId]];
        NSInteger rankRight		= [aUsage rankMacroId:[right macroId]];

        if( rankLeft == rankRight ){
            return( NSOrderedSame );
        }else if( rankLeft < rankRight ){
            return( NSOrderedAscending );
        };
        return( NSOrderedDescending );
    }];
}
-(void)sortMacrosForRecord:(RecentCallRecord*)aRecord{
	[usageData orderFor:aRecord];
	[self sortMacrosUsing:usageData];
}

#pragma mark Call and usage history

-(void)macroRecordUse:(NSUInteger)idx forRecord:(RecentCallRecord*)aRecord{
	if( idx < [self numberOfMacros] ){
/*		NSNumber * macro_id		= [[self elementAtIndex:idx] macroIdAsNumber];
		NSNumber * contact_id	= [NSNumber numberWithInt:[aRecord contactId]];
		NSNumber * longitude	= [NSNumber numberWithDouble:[aRecord longitude]];
		NSNumber * latitude		= [NSNumber numberWithDouble:[aRecord latitude]];
*/
		[aRecord saveIntoDatabase:db table:@"usage_data"];
		[usageData loadFromDb];
	}
}

-(void)saveCallRecord:(RecentCallRecord*)aRecord{
	[aRecord saveIntoDatabase:db table:@"recent_calls"];
	[self checkDbError];
}

-(NSMutableArray*)retrieveCallRecords{
	PROFILE_START();
	NSMutableArray * rv = [[NSMutableArray alloc] initWithCapacity:50];
	FMResultSet *rs = [db executeQuery:@"SELECT * FROM recent_calls ORDER BY call_time DESC"];
	[self checkDbError];
	while ([rs next]) {
		[rv addObject:[[RecentCallRecord alloc]initWithResultSet:rs]];
	}
	[rs close];
	PROFILE_STOP( @"retrieveCallRecords:end");
	return( rv );
}

-(void)clearCallRecords{
	[db executeUpdate:@"DELETE FROM recent_calls" ];

}

void cleanupHelper( FMDatabase * db, NSString * table, int n ){
	NSDate * threshold = nil;
	NSString * query = [NSString stringWithFormat:@"SELECT call_time FROM %@ ORDER BY call_time DESC LIMIT 1 OFFSET %d",
						table, n ];
	FMResultSet *rs = [db executeQuery:query];
	while( [rs next] && ! threshold){
		threshold = [rs dateForColumn:@"call_time"];
	}
	[rs close];
	if( threshold ){
		[db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE call_time < ?",table], threshold];
	}
}

-(void)cleanupOldCallRecords{
	PROFILE_START();
	cleanupHelper( db, @"recent_calls", 50 );
	cleanupHelper( db, @"usage_data",  100 );
	PROFILE_STOP( @"cleanupOldCallRecords" );
}


#pragma mark Update/Create/Modify

-(MacroId)macroIdFromDatabase:(NSString*)aName{
	MacroId macro_id = INVALID_MACRO_ID;

	FMResultSet * rs = [db executeQuery:@"SELECT * FROM macro_current WHERE macro_name = ?", aName];
	[self checkDbError];
	if( [rs next] ){
		macro_id = [rs intForColumn:@"macro_id"];
	}
	[rs close];
	return( macro_id );
}

-(BOOL)addOrReplaceMacro:(NSString*)aName implementor:(MacroImpl*)aImpl{
	NSString * xml = [aImpl toXML];
	return( [self addOrReplaceMacro:aName definition:xml] );
}

-(BOOL)addOrReplaceMacro:(NSString*)aName definition:(NSString*)xml{
	NSUInteger cache_idx = [self indexForMacroName:aName];
	MacroId macro_id  = [self macroIdFromDatabase:aName];

	if( macro_id != INVALID_MACRO_ID ){
		[db executeUpdate:@"UPDATE macro_current SET definition = ? WHERE macro_id = ?", xml, @(macro_id)];
		[self checkDbError];
	}else{
		[db executeUpdate:@"INSERT INTO macro_current (macro_name,definition) VALUES ( ?,?)",aName,xml];
		[self checkDbError];
		macro_id = (int)[db lastInsertRowId];
	}
	MacroOrganizerElement * elem = [[MacroOrganizerElement alloc] init];
	[elem setName:aName];
	[elem setDefinition:xml];
	[elem setMacroId:macro_id];

	if( cache_idx < [self numberOfMacros] ){
		[elem setVariables:[self macroVariablesAtIndex:cache_idx]];
		[currentMacros replaceObjectAtIndex:cache_idx withObject:elem];
	}else{
		[elem setVariables:[NSMutableDictionary dictionary]];
		[currentMacros addObject:elem];
	}


	return( TRUE );
}

-(BOOL)removeMacroByName:(NSString*)aName{
	return( [self removeMacroAtIndex:[self indexForMacroName:aName]] );
}

-(BOOL)deleteMacroInDB:(MacroId)macro_id{
	BOOL rv = TRUE;
	if( macro_id != INVALID_MACRO_ID ){
		rv = [db executeUpdate:@"DELETE FROM macro_current WHERE macro_id = ?", @(macro_id) ];
	}
	return( rv );
}

-(BOOL)removeMacroAtIndex:(NSUInteger)aIdx{
	if( aIdx < [self numberOfMacros] ){
		MacroId macro_id = [self macroIdAtIndex:aIdx];
		if( macro_id != INVALID_MACRO_ID ){
			[self deleteMacroInDB:macro_id];
		}
		[currentMacros removeObjectAtIndex:aIdx];
	}

	return( TRUE );
}

-(BOOL)renameMacroAtIndex:(NSUInteger)aIdx newName:(NSString*)aName{
	[[self elementAtIndex:aIdx] setName:aName];
	MacroId macro_id = [self macroIdAtIndex:aIdx];
	if( macro_id != INVALID_MACRO_ID ){
		[db executeUpdate:@"UPDATE macro_current SET macro_name = ? WHERE macro_id = ?", aName, @(macro_id)];
	};

	return( TRUE );
}

-(NSString*)nextNewName{
	NSString * base = NSLocalizedString(@"New", @"" );
	NSString * rv = base;
	if( [self macroIdFromDatabase:base] != INVALID_MACRO_ID ){

		for( int i = 1; i < 15; i++ ){
			rv = [NSString stringWithFormat:@"%@ %d", base, i ];
			if( [self macroIdFromDatabase:rv] == INVALID_MACRO_ID ){
				break;
			}
		}
	}
	return( rv );
}


#pragma mark packages and setup tools

-(NSMutableArray*)packagesArray{
	NSMutableArray * rv = [NSMutableArray arrayWithCapacity:5];
	FMResultSet *rs = [db executeQuery:@"SELECT package_name FROM packages"];
	[self checkDbError];
	while ([rs next]) {
		[rv addObject:[rs stringForColumn:@"package_name"]];
	}
	[rs close];
	return( rv );
}

-(int)addPackage:(NSString*)aPackageName{
	FMResultSet*rs = [db executeQuery:@"SELECT macro_xml, macro_name FROM packages_macros m,packages p WHERE p.package_name = ? AND p.package_id= m.package_id",
					  aPackageName];
	[self checkDbError];
	int i = 0;
	while ([rs next]) {
		NSString * name = [rs stringForColumn:@"macro_name"];
		NSString * xml  = [rs stringForColumn:@"macro_xml"];
		[self addOrReplaceMacro:name definition:xml];
		i++;
	}
	[rs close];
	return( i );
}
-(void)clearAllMacros{
	NSUInteger n = [self numberOfMacros];
	while( n && [self numberOfMacros] ){
		[self removeMacroAtIndex:0];
	}
}

#pragma mark Upgrades

+(BOOL)upgradeDbToV1:(FMDatabase*)db{
	BOOL rv = [db executeUpdate:@"ALTER TABLE recent_calls ADD COLUMN phone_label TEXT DEFAULT ''"];
	CHECK(rv,@"UpgradeDbV1 error: %@", [db lastErrorMessage]);
	rv = [db executeUpdate:@"CREATE TABLE usage_data (macro_id INTEGER, contact_id INTEGER, idd INTEGER, longitude REAL, latitude REAL, lastcall REAL)"];
	CHECK(rv,@"UpgradeDbV1 error: %@", [db lastErrorMessage]);
	return( rv );
}

+(BOOL)upgradeDbToV3:(FMDatabase *)db{
    BOOL rv = true;

    if (![db columnExists:@"contact_identifier" inTableWithName:@"recent_calls"]) {
        rv = [db executeUpdate:@"ALTER TABLE recent_calls ADD COLUMN contact_identifier TEXT"];
        CHECK(rv,@"UpgradeDbV3 error: %@", [db lastErrorMessage]);
    }
    if (![db columnExists:@"contact_identifier" inTableWithName:@"usage_data"]) {
        rv = [db executeUpdate:@"ALTER TABLE usage_data ADD COLUMN contact_identifier TEXT"];
        CHECK(rv,@"UpgradeDbV3 error: %@", [db lastErrorMessage]);
    }
    return( rv );
}

+(BOOL)upgradeDbToV2:(FMDatabase *)db{
	NSArray * toAdd = [NSArray arrayWithObjects:
						@"original_number TEXT DEFAULT ''",
						@"macro_id INT DEFAULT -1",
						@"latitude DOUBLE DEFAULT 0.0",
						@"longitude DOUBLE DEFAULT 0.0",
					   nil];
	BOOL rv = TRUE;
	NSString * query = nil;

	for( NSString * field in toAdd){
		query = [NSString stringWithFormat:@"ALTER TABLE recent_calls ADD COLUMN %@", field ];
		rv = [db executeUpdate:query];
		CHECK(rv,@"UpgradeDbV2 error: %@", query);
	}

	rv = [db executeUpdate:(query = @"ALTER TABLE usage_data RENAME TO usage_data_old")];
	CHECK(rv,@"UpgradeDbV2 error: %@",query);

	rv = [db executeUpdate:(query = @"CREATE TABLE usage_data AS SELECT * FROM recent_calls LIMIT 0")];
	CHECK(rv,@"UpgradeDbV2 error: %@",query);

	FMResultSet * rs = [db executeQuery:@"SELECT * FROM usage_data_old"];
	RecentCallRecord * rec = [[RecentCallRecord alloc] init];
	while( [rs next] ){
		[rec loadFromOldUsageResultSet:rs];
		rv = [rec saveIntoDatabase:db table:@"usage_data"];
		CHECK(rv,@"UpgradeDbV2 save error: %@",[db lastErrorMessage]);
	}

	return( rv );
}

@end
