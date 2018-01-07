//  MIT Licence
//
//  Created on 01/04/2011.
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

#import "MacroImplReplaceRegexp.h"


@implementation MacroImplReplaceRegexp
@synthesize regexpString,replaceString;

-(MacroImplReplaceRegexp*)init{
	if (!(self = [super init])) return nil;
	if( self ){
		regexpString	= [[NSString alloc] init];
		replaceString	= [[NSString alloc] init];
	}
	return( self );
}

- (PhoneNumber*) apply:(PhoneNumber*)aNumber data:(NSDictionary*)aDict{
	if( regexpString && replaceString ){
		[aNumber regexReplace:regexpString with:replaceString];
	}
	return( aNumber );
}

// Macros Args
- (void)setArgument:(NSString*)key value:(NSString*)val
{
	if( [key isEqualToString:@"regexp"] ){
		[self setRegexpString:val];
	}else if( [key isEqualToString:@"replace"] ){
		[self setReplaceString:val];
	}
}
-(NSArray*)argumentsNames{
	return( [NSArray arrayWithObjects:@"regexp", @"replace",nil] );
}
-(NSString*)getArgument:(NSString*)key{
	if( [key isEqualToString:@"regexp"] ){
		return( [self regexpString] );
	}else if( [key isEqualToString:@"replace"] ){
		return( [self replaceString] );
	}
	return( @"" );
}
-(UIKeyboardType) getKeyboardType:(NSString*)key{
    return( UIKeyboardTypeAlphabet );
}


-(NSString*)myToXML{
	return( [NSString stringWithFormat:@"<type>%@</type><regexp>%@</regexp><replace>%@</replace>", [self type], regexpString, replaceString] );
}

-(NSString*)argsDescription{
	return( [NSString stringWithFormat:@"%@ > %@", regexpString, replaceString] );
}


@end
