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

#import "RecentCallRecord.h"
#import "PhoneNumber.h"

@implementation RecentCallRecord
@synthesize originalNumber,callNumber,contactName,contactId,macroName,callTime,phoneLabel,location,macroId;

-(RecentCallRecord*)init{
	if (!(self = [super init])) return nil;
	if( self ){
		originalNumber	=[[NSString alloc] init];
		callNumber		=[[NSString alloc] init];
		contactName		=[[NSString alloc] init];
		callTime		=[[NSDate	alloc] init];
		macroName		=[[NSString alloc] init];
		phoneLabel		=[[NSString alloc] init];

		location		=[[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
	}
	return( self );
}

-(RecentCallRecord*)initWithResultSet:(FMResultSet*)rs{
	if (!(self = [super init])) return nil;
	if( self ){
		[self loadFromResultSet:rs];
	}
	return( self );
}


-(BOOL)saveIntoDatabase:(FMDatabase*)db table:(NSString*)aTable{

	NSString * query = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES(%@);",
						aTable,
						@"macro_name,contact_identifier,contact_name,call_number,call_time,phone_label,original_number,macro_id,latitude,longitude",
						@"?,?,?,?,?,?,?,?,?,?"];


	CLLocationCoordinate2D coord = [location coordinate];
	BOOL rv = [db executeUpdate:query,
			   macroName,
			   self.contactId,
			   contactName,
			   callNumber,
			   callTime,
			   phoneLabel,
			   originalNumber,
			   @(macroId),

			   @(coord.latitude),
			   @(coord.longitude)
			   ];
	if( ! rv ){
		RZLog( RZLogError, @"Save error: %@ query:%@", [db lastErrorMessage], query);
	}
	return( rv );
}
/*

-(void)loadFromDictionary:(NSMutableDictionary*)aDict{
	OBJECT_OR(		setCallNumber,		@"record_call_number",		@"" );
	OBJECT_OR(		setOriginalNumber,	@"record_original_number",	@"" );
	OBJECT_OR(		setContactName,		@"record_contact_name",		@"" );
	OBJECT_OR(		setMacroName,		@"record_macro_name",		@"" );
	OBJECT_OR(		setPhoneLabel,		@"record_phone_label",		@"" );
	OBJECT_OR_INT(	setMacroId,			@"record_macro_id",			INVALID_MACRO_ID );
	OBJECT_OR_INT(	setContactId,		@"record_contact_id",		1);

}

-(void)saveToDictionary:(NSMutableDictionary*)aDict{

}*/

-(void)loadFromResultSet:(FMResultSet*)rs{
	[self setCallNumber:	[rs stringForColumn:	@"call_number"]];
	[self setOriginalNumber:[rs stringForColumn:	@"original_number"]];

	[self setCallTime:		[rs dateForColumn:		@"call_time"]];

	[self setContactName:	[rs stringForColumn:	@"contact_name"]];
	[self setMacroName:		[rs stringForColumn:	@"macro_name"]];
	[self setPhoneLabel:	[rs stringForColumn:	@"phone_label"]];

	[self setMacroId:		[rs intForColumn:		@"macro_id"]];
	[self setContactId:		[rs stringForColumn:    @"contact_identifier"]];

	double latitude  = [rs doubleForColumn:@"latitude"];
	double longitude = [rs doubleForColumn:@"longitude"];
	if( fabs( latitude ) > 1e-7 && fabs( longitude ) > 1e-7 ){
		[self setLocation:[[CLLocation alloc] initWithLatitude:[rs doubleForColumn:@"latitude"] longitude:[rs doubleForColumn:@"longitude"] ]];
	}else{
		[self setLocation:nil];
	}

}
-(void)loadFromOldUsageResultSet:(FMResultSet*)rs{
	int idd = [rs intForColumn:@"idd"];
	NSString * number = [NSString stringWithFormat:@"+%d", idd];
	[self setCallNumber:	number];
	[self setOriginalNumber:number];

	[self setCallTime:		[NSDate dateWithTimeIntervalSince1970:[rs doubleForColumn:		@"lastcall"]]];

	[self setContactName:	@""];
	[self setMacroName:		@""];
	[self setPhoneLabel:	@""];

	[self setMacroId:		[rs intForColumn:		@"macro_id"]];
	[self setContactId:		[rs stringForColumn:		@"contact_identifier"]];

	double latitude  = [rs doubleForColumn:@"latitude"];
	double longitude = [rs doubleForColumn:@"longitude"];
	if( fabs( latitude ) > 1e-7 && fabs( longitude ) > 1e-7 ){
		[self setLocation:[[CLLocation alloc] initWithLatitude:[rs doubleForColumn:@"latitude"] longitude:[rs doubleForColumn:@"longitude"] ]];
	}else{
		[self setLocation:nil];
	}
}


-(NSString*)formattedCallTime{
	NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateStyle:NSDateFormatterShortStyle];
	[dateFormat setTimeStyle:NSDateFormatterNoStyle];

	NSDate * today = [NSDate date];
	if( [[dateFormat stringFromDate:today] isEqualToString:[dateFormat stringFromDate:[self callTime]]] ){
		// same date
		[dateFormat setDateStyle:NSDateFormatterNoStyle];
		[dateFormat setTimeStyle:NSDateFormatterShortStyle];
	}else{
		// old day
		if( [today timeIntervalSinceDate:[self callTime]] < 60*60*24*7 ){
			[dateFormat setDateStyle:NSDateFormatterNoStyle];
			[dateFormat setTimeStyle:NSDateFormatterNoStyle];
			[dateFormat setDateFormat:@"EEEE"];
		}else{
			[dateFormat setDateStyle:NSDateFormatterShortStyle];
			[dateFormat setTimeStyle:NSDateFormatterNoStyle];
		}
	}

	return( [dateFormat stringFromDate:[self callTime] ] );
}

-(double)latitude{
	if( location )
		return( [location coordinate].latitude );
	return( 0.0 );
}
-(double)longitude{
	if( location )
		return( [location coordinate].longitude );
	return( 0.0 );
}
-(NSString*)description{
	return( [NSString stringWithFormat:@"n=%@ m=%ld c=%@ l=%.2f/%.2f d=%@", originalNumber, (long)macroId, contactId, [location coordinate].latitude,
			 [location coordinate].longitude, [callTime description]]);
}
-(int)commonPrefixLength:(RecentCallRecord*)aRecord{
	const char * thisPn = [originalNumber cStringUsingEncoding:NSUTF8StringEncoding];
	const char * otherPn = [[aRecord originalNumber] cStringUsingEncoding:NSUTF8StringEncoding];

	int rv = 0;
	while ( *thisPn && *otherPn && *thisPn == *otherPn) {
		thisPn++;
		otherPn++;
		rv++;
	}

	return( rv );
}


@end
