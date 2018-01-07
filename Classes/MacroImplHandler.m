//  MIT Licence
//
//  Created on 04/03/2009.
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

#import "MacroImplHandler.h"
#import "MacroNode.h"


@implementation MacroImplHandler
@synthesize implementor,dirty;

-(MacroImplHandler*)initWithImplementor:(MacroImpl*)aImpl{
	if (!(self = [super init])) return nil;
	if( self ){
		[self setImplementor:aImpl];
		dirty = FALSE;
	};
	return( self );
}
-(MacroImplHandler*)init{
	if (!(self = [super init])) return nil;
	dirty = FALSE;
	return( self );
}
-(MacroImpl*)implementorAtIndex:(NSUInteger)idx{
	NSUInteger cur_idx = 0;
	MacroImpl*rv = implementor;
    // 1024 is maximum number of implemtor to avoid recursion
	for( cur_idx = 0; cur_idx < MIN(idx,1024); cur_idx++ ){
		if( rv.nextImplementor ){
			rv = rv.nextImplementor;
		}
	}
	return( rv );
}

-(NSString*)implementorExecuteOn:(NSString*)aNumber with:(NSDictionary*)variables untilIndex:(NSUInteger)idx{
	NSString * previewText = @"";
	if( [aNumber length] > 0 ){
		int cur_idx = 0;
		MacroImpl*imp	= implementor;
		MacroImpl*upTo	= imp;

		for( cur_idx = 0; cur_idx <= idx; cur_idx++ ){
			upTo = [upTo nextImplementor];
		}
		if( upTo ){
			[[upTo parentImplementor] setNextImplementor:nil];
		}
		PhoneNumber*			pn			=	[[PhoneNumber alloc] initWithString:aNumber];
		NSMutableArray *		missing		=	[imp missingVariablesForDict:variables];

		if( [missing count] == 0 ){
			[imp execute:pn data:variables];
			previewText = [pn outputNumber];
		}else {
			previewText = NSLocalizedString(@"Missing Var", @"");
		}
		if( upTo ){
			[[upTo parentImplementor] setNextImplementor:upTo];
		};
	}
	return( previewText );
}

-(NSUInteger)implementorCount{
	NSUInteger n = 0;
	MacroImpl*rv = implementor;
	while( rv != nil ){
		MacroImpl*next = [rv nextImplementor];
		rv = next;
		n++;
	}
	return( n );
}

-(void)moveImplementorFrom:(NSUInteger)from to:(NSUInteger)to{
	if( from == to ){
		return;
	}
	MacroImpl * imp = [self extractImplementorAt:from];
	[self insertImplementor:imp atIndex:to];
}
-(MacroImpl*)extractImplementorAt:(NSUInteger)idx{
	MacroImpl * implFrom = [self implementorAtIndex:idx];
	// we don't own the memory, so make a copy and we'll return that.
	MacroImpl * implCopy = [implFrom copy];

	if( [implFrom parentImplementor] == nil ){
		// if first one, remove from implementor of self
		[self setImplementor:[implFrom nextImplementor]];
		[[self implementor] setParentImplementor:nil];
	}else{
		// else remove from parent
		MacroImpl * implParent = [implFrom parentImplementor];
		MacroImpl * implNext   = [implFrom nextImplementor];
		[implNext	setParentImplementor:	implParent];
		[implParent	setNextImplementor:		implNext];
	};
	dirty = TRUE;
	return( implCopy );
}

-(void)insertImplementor:(MacroImpl*)aImpl atIndex:(NSUInteger)idx{
	if( idx == 0 ){
		[implementor setParentImplementor:aImpl];
		[aImpl setNextImplementor:implementor];
		[aImpl setParentImplementor:nil];
		[self setImplementor:aImpl];
	}else{
		MacroImpl * parent = [self implementorAtIndex:(idx-1)];
		MacroImpl * next   = [parent nextImplementor];
		[aImpl setNextImplementor:next];
		[aImpl setParentImplementor:parent];
		[parent setNextImplementor:aImpl];
		[next setParentImplementor:aImpl];
	}
	dirty = TRUE;
}

-(void)appendImplementor:(MacroImpl*)aImpl{
	[self insertImplementor:aImpl atIndex:[self implementorCount]];
}
-(void)deleteImplementorAt:(NSUInteger)idx{
	MacroImpl * imp = [self implementorAtIndex:idx];

	if( [imp parentImplementor] == nil ){
		[self setImplementor:[imp nextImplementor]];
		[implementor setParentImplementor:nil];
	}else{
		[[imp parentImplementor] setNextImplementor:[imp nextImplementor]];
	}
	dirty = TRUE;
}

-(MacroImpl*)createNewImplForType:(NSString*)aType{
	Class cl = [MacroNode classForType:aType];
	MacroImpl* impl = [[cl alloc] init];
	[impl setType:aType];

	return( impl );
}

-(void)replaceImplementorAt:(NSUInteger)aIdx with:(MacroImpl*)aImpl{
	[self extractImplementorAt:aIdx];
	[self insertImplementor:aImpl atIndex:aIdx];
}

-(void)setArgumentImplementorAt:(NSUInteger)aIdx key:(NSString*)aKey value:(NSString*)aValue{
	dirty = TRUE;
	return( [[self implementorAtIndex:aIdx] setArgument:aKey value:aValue] );
}
@end
