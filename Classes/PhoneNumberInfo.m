//  MIT Licence
//
//  Created on 15/06/2009.
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

#import "PhoneNumberInfo.h"
#import "AppGlobals.h"


@implementation PhoneNumberInfo
@synthesize number,timeZone,idd,areaName,country,areaCode;


-(NSString*)description{
	NSMutableString * rv = [NSMutableString stringWithString:@"PhoneInfo:"];
	if( idd ){
		[rv appendFormat:@" idd:%@", idd];
	}
	if( country ){
		[rv appendFormat:@" country=%@", country];
	}
	if( timeZone ){
		[rv appendFormat:@" TZ=%@", [timeZone name]];
	}
	if( areaName ){
		[rv appendFormat:@" areaName=%@", areaName];
	}
	if( areaCode ){
		[rv appendFormat:@" areaCode=%@", areaCode];
	}
	return( rv );
}

-(NSString*)timeZoneName{
	return( [timeZone name] );
}

-(NSString*)localTime{
	NSMutableString * rv = [NSMutableString string];
	NSDateFormatter * formatterOther	= [[NSDateFormatter alloc] init];
	NSDateFormatter * formatterThis		= [[NSDateFormatter alloc] init];
	[formatterOther setTimeZone:[self timeZone]];
	[formatterThis	setTimeZone:[NSTimeZone defaultTimeZone]];

	[formatterThis	setDateFormat:@"EEEE"];
	[formatterOther setDateFormat:@"EEEE"];

	NSDate * now = [NSDate date];

	NSString * dayThis  = [formatterThis stringFromDate:now];
	NSString * dayOther = [formatterOther stringFromDate:now];
	if(! [dayThis isEqualToString:dayOther] ){
		[rv appendFormat:@"%@ ", dayOther];
	}
	[formatterOther setDateStyle:NSDateFormatterNoStyle];
	[formatterOther setTimeStyle:NSDateFormatterShortStyle];

	[rv appendString:[formatterOther stringFromDate:now]];
	return( rv );
}

-(NSMutableArray*)info{
	SEL sel_local[4] = {
		@selector( country ),
		@selector( areaName ),
		@selector( timeZoneName ),
		@selector( localTime )
	};
	SEL sel_foreign[4] = {
		@selector( country ),
		@selector( localTime ),
		@selector( areaName ),
		@selector( timeZoneName )
	};

	SEL * selectors = nil;

	InfoDatabase * info = [AppGlobals info];
	BOOL localNumber = [country isEqualToString:[info countryForIdd:[info defaultIdd]]];

	size_t n = 4;

	if( localNumber ){
		selectors = sel_local;
	}else{
		selectors = sel_foreign;
	}

	NSMutableArray * rv = [NSMutableArray arrayWithCapacity:n];
	for( size_t i = 0 ; i < n; i++ ){
        NSString * txt = nil;
        SEL selector = selectors[i];
        if ([self respondsToSelector:selector]) {
            // needs below because ARC can't call performSelector it does not know.
            IMP imp = [self methodForSelector:selector];
            id (*func)(id, SEL) = (void *)imp;
            txt = func(self, selector);
        }

		if( ! txt ){
			txt = @"";
		}
		[rv addObject:txt];
	}

	return( rv );
}
@end
