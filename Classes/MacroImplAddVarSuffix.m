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

#import "MacroImplAddVarSuffix.h"


@implementation MacroImplAddVarSuffix
@synthesize varName;

-(MacroImplAddVarSuffix*)init{
	if (!(self = [super init])) return nil;
	varName = [[NSString alloc] init];
	return( self );
}


- (PhoneNumber*) apply:(PhoneNumber*)aNumber data:(NSDictionary*)aDict{
	if( varName ){
		[aNumber addSuffix:[aDict objectForKey:varName]];
	}
	return( aNumber );
}

// Macros Args
- (void)setArgument:(NSString*)key value:(NSString*)val
{
	if( [key isEqualToString:@"variable"] ){
		[self setVarName:val];
	}
}

-(NSArray*)argumentsNames{
	return( [NSArray arrayWithObject:@"variable"] );
}
-(NSString*)getArgument:(NSString*)key{
	return( varName );
}

-(NSArray*)myVariablesNames{
	return( [NSArray arrayWithObject:varName] );
}

-(NSString*)myToXML{
	return( [NSString stringWithFormat:@"<type>%@</type><variable>%@</variable>", [self type], varName] );
}

-(NSString*)argsDescription{
	return( varName );
}


@end
