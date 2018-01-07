//  MIT Licence
//
//  Created on 21/02/2009.
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

#import "MacroImplLastDigits.h"


@implementation MacroImplLastDigits
@synthesize numberOfDigits;

- (PhoneNumber*) apply:(PhoneNumber*)aNumber data:(NSDictionary*)aDict{
	[aNumber lastDigits:numberOfDigits];
	return( aNumber );
}

// Macros Args
- (void)setArgument:(NSString*)key value:(NSString*)val
{
	if( [key isEqualToString:@"n"] ){
		numberOfDigits = [val intValue];
	}
}
-(NSString*)getArgument:(NSString*)key{
	return( [NSString stringWithFormat:@"%d", numberOfDigits] );
}
-(NSArray*)argumentsNames{
	return( [NSArray arrayWithObject:@"n"] );
}

-(NSString*)myToXML{
	return( [NSString stringWithFormat:@"<type>%@</type><n>%d</n>", [self type], numberOfDigits] );
}

-(NSString*)argsDescription{
	return( [NSString stringWithFormat:@"%d", numberOfDigits] );
}


@end
