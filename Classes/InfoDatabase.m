//  MIT Licence
//
//  Created on 11/06/2009.
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

#import "InfoDatabase.h"
#import "AppConstants.h"
#import "RZUtils/RZUtils.h"

@implementation InfoDatabase
@synthesize db,cache,defaultIdd;

-(InfoDatabase*)init{
	if (!(self = [super init])) return nil;
	if( self ){
		db = [[FMDatabase alloc] initWithPath:[RZFileOrganizer bundleFilePath:@"info.db"]];
		[db open];
		cache = [[NSMutableDictionary alloc] init];
		defaultIdd = nil;
	}
	return( self );
}


-(NSDictionary*)findInCache:(NSString*)aIdd andNumber:(NSString*)aNumber areaOnly:(BOOL)aAreaOnly{
	NSDictionary * rv = nil;
	NSUInteger n = [aNumber length];
	if( n > AREA_CODE_MAXSIZE )
		n= AREA_CODE_MAXSIZE;

	for( NSUInteger i = 0 ; i < n ; i++ ){
		NSString * key = [NSString stringWithFormat:@"%@%@", aIdd, [aNumber substringToIndex:(n-i)]];
		rv = [cache objectForKey:key];
		if( rv )
			break;
	}
	return( rv );
}

-(NSDictionary*)dictForResult:(FMResultSet*)rs {
	NSDictionary	* thisValue = nil;

	if( rs ){
		NSString *	readCountry		= [rs stringForColumn:SQLFIELD_COUNTRY];
		NSString *	readAreaName	= [rs stringForColumn:SQLFIELD_AREANAME];
		NSString *	readTimeZone	= [rs stringForColumn:SQLFIELD_TIMEZONE];
		int			readAreaCode	= [rs intForColumn:SQLFIELD_AREACODE];
		int			idd				= [rs intForColumn:SQLFIELD_IDDCODE];
		NSString *  iddCode			= [NSString stringWithFormat:@"%d", idd];

		if( readAreaCode ){
			NSString * areaCodeAsString = [NSString stringWithFormat:@"%d", readAreaCode];
			thisValue = [NSDictionary dictionaryWithObjectsAndKeys:
						 readCountry,		SQLFIELD_COUNTRY,
						 readTimeZone,		SQLFIELD_TIMEZONE,
						 iddCode,			SQLFIELD_IDDCODE,
						 areaCodeAsString,	SQLFIELD_AREACODE,
						 readAreaName,		SQLFIELD_AREANAME,
						 nil];
		}else{
			thisValue = [NSDictionary dictionaryWithObjectsAndKeys:
						 readCountry,		SQLFIELD_COUNTRY,
						 readTimeZone,		SQLFIELD_TIMEZONE,
						 iddCode,			SQLFIELD_IDDCODE,
						 nil];

		}
	}
	return( thisValue );
}

-(void)checkDbError{
#ifdef TARGET_IPHONE_SIMULATOR
	if( [db hadError] ){
		NSString * er = [db lastErrorMessage];
		NSLog(@"%@", er);
	}
#endif
}

-(NSDictionary*)searchForIDD:(NSString*)aIdd andNumber:(NSString*)aNumber{
	PROFILE_START();
	NSDictionary * rv = [self findInCache:aIdd andNumber:aNumber areaOnly:TRUE];
	if( !rv ){
		NSString		* thisKey ;
		int n = AREA_CODE_MAXSIZE;

// First with area code
		NSMutableString * query = [NSMutableString stringWithFormat:@"SELECT * FROM idd_info WHERE idd_code = %@ ", aIdd];
		BOOL closeAND = false;
		for( int i = 0; i < n ; i++ ){
			if( i < [aNumber length] ){
				[query appendFormat:@"%@ area_code = %@", ( i == 0 ? @"AND (" : @" OR" ), [aNumber substringToIndex:i+1]];
				closeAND = true;
			}
		}
		[query appendFormat:@"%@ ORDER BY area_code DESC", closeAND ? @")" : @""];

		FMResultSet * rs = [db executeQuery:query, nil];
		BOOL found = FALSE;
		[self checkDbError];

		while( [rs next] ){

			NSDictionary	* thisValue = [self dictForResult:rs];

			found	= TRUE;
			NSString * areaCode = [thisValue objectForKey:SQLFIELD_AREACODE];
			thisKey = [NSString stringWithFormat:@"%@%@", aIdd, ( areaCode ? areaCode : @"" ) ];
			[cache setObject:thisValue forKey:thisKey];
		}


		// Check if we have country;
		rv = [self findInCache:aIdd andNumber:aNumber areaOnly:FALSE];

		if( rv == nil ){
			NSMutableString * query = [NSMutableString stringWithFormat:@"SELECT * FROM idd_info WHERE idd_code = %@ AND area_code ISNULL", aIdd];

			FMResultSet * rs = [db executeQuery:query, nil];

			while( [rs next] ){
				NSString		* thisKey ;
				NSDictionary	* thisValue;

				thisKey		= [NSString stringWithFormat:@"%@", aIdd ];
				thisValue   = [self dictForResult:rs];
				[cache setObject:thisValue forKey:thisKey];
				rv = thisValue;
			}

			if( rv == nil ){
				NSMutableString * query = [NSMutableString stringWithFormat:@"SELECT * FROM idd_info WHERE idd_code = %@ LIMIT 1", aIdd];

				FMResultSet * rs = [db executeQuery:query, nil];

				while( [rs next] ){
					NSString		* thisKey ;
					NSDictionary	* thisValue;

					thisKey		= [NSString stringWithFormat:@"%@", aIdd ];
					thisValue   = [self dictForResult:rs];
					NSMutableDictionary * fixedValue = [NSMutableDictionary dictionaryWithDictionary:thisValue];
					[fixedValue removeObjectForKey:SQLFIELD_AREACODE];
					[fixedValue removeObjectForKey:SQLFIELD_AREANAME];

					[cache setObject:fixedValue forKey:thisKey];
					rv = fixedValue;
				}

			}
			if( ! found ){
				if( [aNumber length] > 1){
					thisKey		= [NSString stringWithFormat:@"%@%@", aIdd, [aNumber substringToIndex:1] ];
				}else{
					thisKey     = [NSString stringWithString:aIdd];
				}
				if( rv )
					[cache setObject:rv forKey:thisKey];
			}
		}
	};
	PROFILE_STOP( @"searchForIDD" );
	return( rv );
}

-(NSString*)defaultIddForTimeZone:(NSString*)aTimeZone{
	NSString * query = @"SELECT DISTINCT(idd_code) as idd FROM idd_info WHERE time_zone = ?";
	FMResultSet * rs = [db executeQuery:query, aTimeZone, nil ];
	NSString * rv = nil;
	while( [rs next] ){
		rv = [NSString stringWithFormat:@"%d", [rs intForColumn:@"idd"]];
	}
	return( rv );
}

-(NSString*)countryForIdd:(NSString*)aIdd{
	NSDictionary * data = [self searchForIDD:aIdd andNumber:@""];
	if( data ){
		return( [data objectForKey:SQLFIELD_COUNTRY] );
	};
	return( @"" );
}

-(PhoneNumberInfo*)infoForNumber:(NSString*)aNumber{
	NSDictionary * data = nil;
	PhoneNumberInfo * rv = nil;
	PhoneNumber * pn = [[PhoneNumber alloc] initWithString:aNumber];

	if( [pn hasPrefix:@"+"] ){ //Easy, start with +
		[pn removeCountryCode];
		data = [self searchForIDD:[pn countryCode] andNumber:[pn outputNumber]];
	}else if( [pn hasPrefix:@"0"] ){ // start with 0, remove and use standard idd
		[pn removePrefix:@"0"];
		data = [self searchForIDD:defaultIdd andNumber:[pn outputNumber]];
	}else if( [pn hasPrefix:defaultIdd] ){ // start with idd but no + (for ex in hkg)
		[pn removeCountryCode];
		data = [self searchForIDD:[pn countryCode] andNumber:[pn outputNumber]];
	}else{ // otherwise, assume the number with defaultIdd
		data = [self searchForIDD:defaultIdd andNumber:[pn outputNumber]];
	}

	if( data ){
		rv = [[PhoneNumberInfo alloc] init];
		[rv setIdd:[data objectForKey:SQLFIELD_IDDCODE]];
		[rv setCountry:[data objectForKey:SQLFIELD_COUNTRY]];
		[rv setAreaName:[data objectForKey:SQLFIELD_AREANAME]];
		[rv setAreaCode:[data objectForKey:SQLFIELD_AREACODE]];
		[rv setTimeZone:[NSTimeZone timeZoneWithName:[data objectForKey:SQLFIELD_TIMEZONE]]];
		[rv setNumber:aNumber];
	}
	return( rv );

}


@end
