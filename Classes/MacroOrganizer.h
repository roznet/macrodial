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

#import <Foundation/Foundation.h>
#import "MacroImpl.h"
#import "RecentCallRecord.h"
#import "UsageData.h"
#import "Macros.h"

@interface MacroOrganizerElement : NSObject
{
	NSMutableDictionary	*	variables;
	NSString			*	name;
	NSString			*	definition;
	MacroId						macroId;
}

@property (nonatomic,strong) NSMutableDictionary	*	variables;
@property (nonatomic,strong) NSString				*	name;
@property (nonatomic,strong) NSString				*	definition;
@property (nonatomic,assign) MacroId						macroId;


-(NSNumber*)macroIdAsNumber;

@end

@interface MacroOrganizer : NSObject {
	FMDatabase		*	__weak db;
	NSMutableArray  *	currentMacros;
	UsageData		*   usageData;
	int					db_errors;
}
@property (nonatomic,weak) FMDatabase *		db;
@property (nonatomic,strong) NSMutableArray	*	currentMacros;
@property (nonatomic,assign) int				db_errors;
@property (nonatomic,strong) UsageData *		usageData;

// Upgrades
+(BOOL)upgradeDbToV1:(FMDatabase*)db;
+(BOOL)upgradeDbToV2:(FMDatabase*)db;
+(BOOL)upgradeDbToV3:(FMDatabase *)db;


// Errors
-(BOOL)checkDbError;
-(BOOL)dbIsCorrupted;

// Initialization
-(MacroOrganizer*)	initWithDb:(FMDatabase*)aDb;
-(void)				loadCurrentMacros;
-(void)				forceRefresh;

// Macro Variables
-(void)		saveMacroVariable:(NSUInteger)idx;
-(NSString*)macroVariablesValueGuess:(NSString*)name;

// Call Records
-(void)				saveCallRecord:(RecentCallRecord*)aRecord;
-(NSMutableArray*)	retrieveCallRecords;
-(void)macroRecordUse:(NSUInteger)idx forRecord:(RecentCallRecord*)aRecord;
-(void)clearCallRecords;
-(void)cleanupOldCallRecords;

// Update/Create/Modify macros
-(BOOL)addOrReplaceMacro:(NSString*)aName implementor:(MacroImpl*)aImpl;
-(BOOL)addOrReplaceMacro:(NSString*)aName definition:(NSString*)aXML;
-(BOOL)removeMacroAtIndex:(NSUInteger)aIdx;
-(BOOL)renameMacroAtIndex:(NSUInteger)aIdx newName:(NSString*)aName;

// Access to cached macros
-(NSUInteger)			numberOfMacros;
-(NSArray*)				macroNames;
-(BOOL)					validIndex:(NSUInteger)i;
-(NSUInteger)			indexForMacroName:(NSString*)aName;
-(NSUInteger)			macroForXML:(NSString*)aXML;
-(NSMutableDictionary*)	macroVariablesAtIndex:(NSUInteger)i;
-(NSString*)			macroNameAtIndex:(NSUInteger)i;
-(NSString*)			macroNameForId:(MacroId)i;
-(NSString*)			macroDefinitionAtIndex:(NSUInteger)i;
-(MacroImpl*)			macroImplAtIndex:(NSUInteger)i;
-(NSInteger)			macroIdAtIndex:(NSUInteger)i;
-(NSString*)			macroEvaluate:(NSUInteger)i forNumber:(NSString*)aNumber;
-(void)					sortMacrosUsing:(UsageData*)aUsage;
-(void)					sortMacrosForRecord:(RecentCallRecord*)aRecord;

// Utility/Db
-(NSString*)			nextNewName;
-(BOOL)deleteMacroInDB:(MacroId)macro_id;

//package and setup tool
-(NSMutableArray*)packagesArray;
-(int)addPackage:(NSString*)aPackageName;
-(void)clearAllMacros;

@end
