//  MIT Licence
//
//  Created on 14/03/2009.
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

#import "MacroImplReplacePlus.h"


@implementation MacroImplReplacePlus
@synthesize replaceString;

-(MacroImplReplacePlus*)init{
	if (!(self = [super init])) return nil;
	if( self ){
		replaceString	= [[NSString alloc] init];
	}
	return( self );
}

- (PhoneNumber*) apply:(PhoneNumber*)aNumber data:(NSDictionary*)aDict{
	if( replaceString ){
		[aNumber replaceString:@"+" with:replaceString];
	}
	return( aNumber );
}

// Macros Args
- (void)setArgument:(NSString*)key value:(NSString*)val
{
	if( [key isEqualToString:@"replace"] ){
		[self setReplaceString:val];
	}
}
-(NSArray*)argumentsNames{
	return( [NSArray arrayWithObject:@"replace"] );
}
-(NSString*)getArgument:(NSString*)key{
	if( [key isEqualToString:@"replace"] ){
		return( [self replaceString] );
	}
	return( @"" );
}

-(NSString*)myToXML{
	return( [NSString stringWithFormat:@"<type>%@</type><replace>%@</replace>", [self type], replaceString] );
}

-(NSString*)argsDescription{
	return( replaceString );
}


@end
