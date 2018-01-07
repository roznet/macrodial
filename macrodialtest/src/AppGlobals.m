//  MIT Licence
//
//  Created on 24/02/2009.
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

#import "AppGlobals.h"

#import "MacroDialTestAppDelegate.h"

@implementation AppGlobals

static NSMutableDictionary * s_settings = nil;

+(MacroOrganizer*)organizer{
	MacroDialTestAppDelegate *appDelegate = (MacroDialTestAppDelegate *)[[UIApplication sharedApplication] delegate];
    return( [appDelegate macroOrganizer] );
}

+(InfoDatabase*)info{
	MacroDialTestAppDelegate *appDelegate = (MacroDialTestAppDelegate *)[[UIApplication sharedApplication] delegate];
    return( [appDelegate info] );
}
+(UIColor*)backgroundColor{
	return( [UIColor groupTableViewBackgroundColor] );
}

+(NSMutableDictionary*)settings{
	if( s_settings == nil ){
		s_settings = [[NSMutableDictionary alloc] init];
	}
	return( s_settings );
}
+(void)newSettings{
	;
	s_settings = [[NSMutableDictionary alloc] init];
}

+(void)publishEvent:(NSString*)name{
	[self configIncInt:[self publishKey:name]];
}
+(NSString*)publishKey:(NSString*)name{
	return( [NSString stringWithFormat:@"publish_%@", name ] );
}
+(UIFont*)              systemFontOfSize:(CGFloat)size{
    return [UIFont fontWithName:@"HelveticaNeue-light" size:size];
}
+(UIFont*)              boldSystemFontOfSize:(CGFloat)size{
    return [UIFont fontWithName:@"HelveticaNeue" size:size];

}

@end
