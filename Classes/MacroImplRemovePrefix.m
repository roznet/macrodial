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

#import "MacroImplRemovePrefix.h"


@implementation MacroImplRemovePrefix
@synthesize prefix;

-(MacroImplRemovePrefix*)init{
	if (!(self = [super init])) return nil;
	prefix = [[NSString alloc] init];
	return( self );
}


- (PhoneNumber*) apply:(PhoneNumber*)aNumber data:(NSDictionary*)aDict{
	if( prefix ){
		[aNumber removePrefix:prefix];
	}
	return( aNumber );
}

// Macros Args
- (void)setArgument:(NSString*)key value:(NSString*)val
{
	if( [key isEqualToString:@"prefix"] ){
		[self setPrefix:val];
	}
}
-(NSArray*)argumentsNames{
	return( [NSArray arrayWithObject:@"prefix"] );
}
-(NSString*)getArgument:(NSString*)key{
	return( prefix );
}

-(NSString*)myToXML{
	return( [NSString stringWithFormat:@"<type>%@</type><prefix>%@</prefix>", [self type], prefix] );
}

-(NSString*)argsDescription{
	return( prefix );
}



@end
