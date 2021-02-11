//  MIT Licence
//
//  Created on 06/03/2009.
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
#import <CoreLocation/CoreLocation.h>

//Note: upgrade to v2: add macro_id,longitude,latitude,original_number

@interface RecentCallRecord : NSObject {
	// Core Components
	NSString*	originalNumber; // original contact number
	NSString*	callNumber;		// number actually called

	// Information about when/where
	NSDate*		callTime;
	CLLocation* location;		// Location where called

	// For display
	NSString*	contactName;	// contact name for display
	NSString*	phoneLabel;		// label for display
	NSString*	macroName;		// macro name

	// For internal retrieval
	NSInteger			macroId;		// macro Id
}
@property (nonatomic,strong)	NSString*	originalNumber;
@property (nonatomic,strong)	NSString*	callNumber;

@property (nonatomic,strong)	NSString*	contactName;
@property (nonatomic,strong)	NSString*	phoneLabel;
@property (nonatomic,strong)	NSString*	macroName;

@property (nonatomic,strong)	NSDate*		callTime;
@property (nonatomic,strong)	CLLocation* location;

@property (nonatomic,strong)	NSString *	contactId;
@property (nonatomic,assign)	NSInteger	macroId;

-(RecentCallRecord*)initWithResultSet:(FMResultSet*)rs;
-(BOOL)saveIntoDatabase:(FMDatabase*)db table:(NSString*)aTable;
-(void)loadFromResultSet:(FMResultSet*)rs;
-(void)loadFromOldUsageResultSet:(FMResultSet*)rs;

//-(void)loadFromDictionary:(NSDictionary*)aDict;
//-(void)saveToDictionary:(NSMutableDictionary*)aDict;

-(NSString*)formattedCallTime;
-(double)latitude;
-(double)longitude;
-(NSString*)description;
-(int)commonPrefixLength:(RecentCallRecord*)aRecord;

@end
