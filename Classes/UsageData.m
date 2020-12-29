//  MIT Licence
//
//  Created on 20/06/2009.
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

#import "UsageData.h"

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

@implementation UsageData
@synthesize db;
@synthesize usageData;

-(UsageData*)initUsageWithDb:(FMDatabase*)aDb{
	if (!(self = [super init])) return nil;
	if( self ){
		[self setUsageData:[NSMutableArray arrayWithCapacity:25]];
		[self setDb:aDb];
		[self loadFromDb];
	}
	return( self );
}


-(void)loadFromDb{
	PROFILE_START();
	if( ! db )
		return;
	FMResultSet * rs = [db executeQuery:@"SELECT * FROM usage_data"];
	[usageData removeAllObjects];
	while( [rs next] ){
		RecentCallRecord * record = [[RecentCallRecord alloc] initWithResultSet:rs];
		[usageData addObject:record];
	}
	[rs close];
	PROFILE_STOP( @"usage_data loadFromDb:total" );
}

-(void)orderFor:(RecentCallRecord*)aCurrent{
	PROFILE_START()
    [usageData sortUsingComparator:^(RecentCallRecord*l, RecentCallRecord*r){
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
    }];
	PROFILE_STOP( @"sort:total" );
}

-(int)rankMacroId:(MacroId)aMacroId{
	NSUInteger n = [usageData count];
	for( NSUInteger i = 0; i < n ; i++ ){
		if( [[usageData objectAtIndex:i] macroId] == aMacroId ){
			return( (int)i );
		}
	}
	return( (int)n );
}

@end

