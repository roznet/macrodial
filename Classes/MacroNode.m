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

#import "MacroNode.h"
#import "MacroImplAddPrefix.h"
#import "MacroImplAddSuffix.h"
#import "MacroImplRemoveCountryCode.h"
#import "MacroImplRemovePlus.h"
#import "MacroImplLastDigits.h"
#import "MacroImplFirstDigits.h"
#import "MacroImplAddVarSuffix.h"
#import "MacroImplAddVarPrefix.h"
#import "MacroImplRemovePrefix.h"
#import "MacroImplRemoveSuffix.h"
#import "MacroImplReplace.h"
#import "MacroImplReplacePlus.h"
#import "MacroImplNoOp.h"
#import "MacroImplPausePrefix.h"
#import "MacroImplPauseSuffix.h"
#import "MacroImplReplacePrefix.h"
#import "MacroImplReplaceSuffix.h"
#import "MacroImplReplaceRegexp.h"

@implementation MacroNode

@synthesize parent;
@synthesize children;
@synthesize key;
@synthesize leafvalue;

+(NSDictionary*)implDefinitionDictionary{
	static NSDictionary * dict = NULL;
	if( ! dict ){
		dict = [NSDictionary dictionaryWithObjectsAndKeys:
				 [MacroImplAddPrefix			class],		@"prefix",
				 [MacroImplAddSuffix			class],		@"suffix",
				 [MacroImplRemoveCountryCode	class],		@"local",
				 [MacroImplLastDigits			class],		@"lastdigits",
				 [MacroImplFirstDigits			class],		@"firstdigits",
				 [MacroImplAddVarPrefix			class],		@"varprefix",
				 [MacroImplAddVarSuffix			class],		@"varsuffix",
				 [MacroImplRemovePlus			class],		@"removeplus",
				 [MacroImplRemovePrefix			class],		@"removeprefix",
				 [MacroImplRemoveSuffix			class],		@"removesuffix",
				 [MacroImplReplace				class],		@"replace",
				 [MacroImplReplacePlus			class],		@"replaceplus",
				 [MacroImplReplacePrefix		class],		@"replaceprefix",
				 [MacroImplReplaceSuffix		class],		@"replacesuffix",
				 [MacroImplPauseSuffix			class],		@"pausesuffix",
				 [MacroImplPausePrefix			class],		@"pauseprefix",
				 [MacroImplNoOp					class],		@"noop",
                 [MacroImplReplaceRegexp        class],     @"replaceregexp",
				 nil];
	};
	return( dict );
}

+(Class)classForType:(NSString*)type{
	Class rv = [[MacroNode implDefinitionDictionary] objectForKey:type];
	return( rv );
}

// Initialize all nodes as branches
- (MacroNode *) init
{
	if (self = [super init]) {
		leafvalue	= NULL;
		parent		= NULL;
		key			= NULL;

		[self setChildren:[NSMutableArray array]];

	}
	return self;
}


// Determine whether the node is a leaf or a branch
- (BOOL) isLeaf
{
	return (self.leafvalue != NULL);
}

// Return the first child that matches the key
- (MacroNode *) objectForKey: (NSString *) aKey
{
	for (MacroNode *node in self.children)
		if ([[node key] isEqualToString: aKey]) return node;
	return NULL;
}

// Return the last child leaf value that matches the key
- (NSString *) leafForKey: (NSString *) aKey
{
	for (MacroNode *node in self.children)
		if ([[node key] isEqualToString: aKey]) return node.leafvalue;
	return NULL;
}

// Print the tree to standard out
- (void) dumpAtIndent: (int) indent
{
	for (int i = 0; i < indent; i++) printf("--");

	printf("[%2d] Key: %s ", indent, [self.key UTF8String]);
	if (leafvalue) printf("(%s)", [self.leafvalue UTF8String]);
	printf("\n");

	for (MacroNode *node in self.children) [node dumpAtIndent:indent + 1];
}

- (void) dump
{
	[self dumpAtIndent:0];
}

- (MacroImpl*)implementor{
	MacroImpl * implementor = nil;

	if( [[self key] isEqualToString:@"rule"] ){
		NSString*type = [self leafForKey:@"type"];
		Class cl = [MacroNode classForType:type];
		implementor = [[cl alloc] init];
		[implementor setType:type];
	}
	// process possible arguments
	for (MacroNode *node in self.children) {
		if( [[node key] isEqualToString:@"rule"] ){
			MacroImpl * nextImp = [node implementor];
			[implementor setNextImplementor:nextImp];
			[nextImp setParentImplementor:implementor];
		}else if( [node leafvalue] ){
			[implementor setArgument:[node key] value:[node leafvalue]];
		}
	}
	return( implementor );
}

@end
