//  MIT Licence
//
//  Created on 13/02/2009.
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

#import "MacroImpl.h"

@implementation MacroImpl
@synthesize type;
@synthesize nextImplementor;
@synthesize parentImplementor;
@synthesize beingCalculated;

-(MacroImpl*)init{
	if (!(self = [super init])) return nil;
	if( self ){
		type = nil;
		nextImplementor = nil;
	}
	return( self );
}

-(MacroImpl*)initWithImpl:(MacroImpl*)aImpl{
	if (!(self = [super init])) return nil;
	if( self ){
		[self setType:[aImpl type]];
		[self setNextImplementor:[aImpl nextImplementor]];
		[self setParentImplementor:[aImpl parentImplementor]];
		NSString * key;
		for( key in [aImpl argumentsNames] ){
			[self setArgument:key value:[aImpl getArgument:key]];
		}
	}
	return( self );
}

-(id)copyWithZone:(NSZone*)zone{
	return( [[[self class] allocWithZone:zone] initWithImpl:self]);
}


#pragma mark Recursive Functions
- (PhoneNumber*) execute:(PhoneNumber*)aNumber data:(NSDictionary*)aDict
{
	if( beingCalculated ){
		RZLog( RZLogError, @"MacroImpl Cycle Dectected!" );
		beingCalculated = FALSE;
		return( aNumber );
	}
	beingCalculated = true;
	[self apply:aNumber data:aDict];
	if( nextImplementor )
		[nextImplementor execute:aNumber data:aDict];
	beingCalculated = false;
	return( aNumber );
}

-(NSMutableArray*)variablesNames {
	NSMutableArray*rv = [NSMutableArray arrayWithArray:[self myVariablesNames]];
	if( !rv ){
		rv = [[NSMutableArray alloc] init];
	};
	if( nextImplementor ){
		[rv addObjectsFromArray:[nextImplementor variablesNames]];
	}
	//FIX: remove duplicates?
	return( rv );
}

-(NSMutableArray*)	missingVariablesForDict:(NSDictionary*)aDict{
	NSString*		key;
	NSMutableArray* vars    = [self variablesNames];
	NSMutableArray* missing = [[NSMutableArray alloc] init];

	for( key in vars ) {
		if( ! [aDict objectForKey:key] ){
			[missing addObject:key];
		}
	}
	return( missing );
}

-(NSString*)toXML{
	return( [NSString stringWithFormat:@"<rule>%@%@</rule>",
												[self myToXML],
												nextImplementor ? [nextImplementor toXML] : @""
					] );
}

#pragma mark Specific Implementation functions
- (PhoneNumber*) apply:(PhoneNumber*)aNumber data:(NSDictionary*)aDict{
	return( aNumber );
}

- (bool)test:(PhoneNumber*)aNumber data:(NSDictionary*)aDict{
	return( TRUE );
}

// Macros Args
- (void)setArgument:(NSString*)key value:(NSString*)val
{
}

- (void)setSubMacro:(NSString*)key macro:(MacroImpl*)val
{
}

-(NSArray*)myVariablesNames{
	return( nil );
}

-(NSString*)myToXML{
	return( @"" );
}

-(NSArray*)argumentsNames{
	return( nil );
}
-(NSString*)	getArgument:(NSString*)key{
	return( @"" );
}
-(UIKeyboardType) getKeyboardType:(NSString*)key{
    if( [key isEqualToString:@"variable" ] ){
        return( UIKeyboardTypeAlphabet );
    }
    return( UIKeyboardTypePhonePad );
}

#pragma mark description

-(NSString*)description{
	return( [NSString stringWithFormat:@"%@ %@", [self typeDescription], [self argsDescription]] );
}

-(NSString*)typeDescription{
	return( NSLocalizedString( type, @"" ) );
}
-(NSString*)argsDescription{
	return( @"" );
}

-(void)dump{
	[self dumpForLevel:0];
}

-(void)dumpForLevel:(int)i{
	if( beingCalculated ){
		RZLog( RZLogError, @"%02d: %@ %p CYCLE!!!", (int)i, [self description], self );
		beingCalculated = FALSE;
		return;
	}
	beingCalculated = TRUE;
	RZLog( RZLogError, @"%02d: %@ %p parent:%p", (int)i, [self description], self, parentImplementor );
	if( self.nextImplementor ){
		[self.nextImplementor dumpForLevel:i+1];
	}
	beingCalculated = FALSE;
}
@end
