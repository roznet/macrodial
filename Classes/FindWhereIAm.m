//  MIT Licence
//
//  Created on 05/06/2009.
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

#import "FindWhereIAm.h"
#import "AppGlobals.h"
#import "AppConstants.h"


@interface  FindWhereIAm ()
@property (nonatomic,strong) RemoteDownloadLocation * remoteLocation;
@end
@implementation FindWhereIAm
@synthesize locationManager;
@synthesize currentLocation;
@synthesize locatorDelegate;
@synthesize locationData;

-(FindWhereIAm*)initWithDelegate:(id<FindWhereIAmDelegate>)aDelegate reverse:(BOOL)aFlag{
	if (!(self = [super init])) return nil;
	if( self ){
		locationManager = [[CLLocationManager alloc] init];
		[locationManager setDelegate:self];
		[locationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];
		locationData = nil;
		currentLocation = nil;
		if( aFlag ){
			locationData = [NSMutableDictionary dictionary];
		}
		if( [CLLocationManager locationServicesEnabled] ){
			[locationManager startUpdatingLocation];
		}
		locatorDelegate = aDelegate;
	}
	return( self );
}


#pragma mark locationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
	[locationManager stopUpdatingLocation];
    CLLocation * newLocation = locations.lastObject;
    if( newLocation ){
        [self setCurrentLocation:newLocation];
        
        if( locationData ){
            NSString *requestString = [NSString stringWithFormat:@"http://zonetag.research.yahooapis.com/services/rest/V1/suggestedTags.php?apptoken=%@&latitude=%f&longitude=%f&output=xml",
                                       APPTOKEN,
                                       [currentLocation coordinate].latitude,
                                       [currentLocation coordinate].longitude ];
            self.remoteLocation = [[RemoteDownloadLocation alloc] initWithURL:requestString andDelegate:self];
        }else{
            [locatorDelegate foundLocation];
        }
    }
}

#pragma mark downloadDelegate

-(void)downloadFailed:(id)connection{
}

-(void)downloadArraySuccessful:(id)connection array:(NSArray*)theArray{
	if( [theArray count] == 1 ){
		[self setLocationData:[theArray objectAtIndex:0]];
		// refresh config
		[self country];
		[self city];
		[locatorDelegate foundLocation];
	}
}
-(void)downloadStringSuccessful:(id)connection string:(NSString*)theString{
}

-(NSString*)findTag:(NSString*)aTag{
	NSString * candidate = nil;
	NSString * configKey = [NSString stringWithFormat:@"location_%@", aTag];
	if( locationData ) {
		candidate = [locationData objectForKey:aTag];
	}
	if( ! candidate ){
		candidate = [AppGlobals configGetString:configKey defaultValue:LOCATION_UNKNOWN];
	}
	if( candidate ){
		[AppGlobals configSet:configKey stringVal:candidate];
	}
	return( candidate );
}

-(NSString*)country{
	return( [self findTag:@"country"] );
}
-(NSString*)city{
	return( [self findTag:@"city" ] );
}
-(NSString*)state{
	return( [self findTag:@"state" ] );
}


@end
