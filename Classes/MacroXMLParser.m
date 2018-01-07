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

#import "MacroXMLParser.h"

@implementation MacroXMLParser
@synthesize root;
@synthesize stack;

// Public parser returns the tree root
- (MacroNode *)parseXMLString: (NSString *) rulestr
{
	// Create a new clean stack
	[self setStack:[[NSMutableArray alloc] init]];

	[self setRoot:[[MacroNode alloc] init]];
	[stack addObject:self.root];

	NSData * dat = [NSData dataWithBytes:[rulestr UTF8String] length:[rulestr length]+1];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:dat ];
    [parser setDelegate:self];
	[parser parse];

	return [[root children] lastObject];
}


// Descend to a new element
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	MacroNode *leaf = [[MacroNode alloc] init];
	[leaf setParent:[stack lastObject]];
	[leaf.parent.children addObject:leaf];
	[self.stack addObject:leaf];

	[leaf setKey:qName ? qName : elementName];
}

// Pop after finishing element
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	[self.stack removeLastObject];
}

// Reached a leaf
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (![[self.stack lastObject] leafvalue])
	{
		[[self.stack lastObject] setLeafvalue:string];
		return;
	}
	[[self.stack lastObject] setLeafvalue:[NSString stringWithFormat:@"%@%@", [[self.stack lastObject] leafvalue], string]];
}

+(MacroImpl*)implementorForString:(NSString*)ruleStr{
	if( ruleStr == nil ){
		return( nil );
	}
	MacroXMLParser *parser = [[MacroXMLParser alloc] init];
	MacroNode *root = [parser parseXMLString:ruleStr];

	MacroImpl*imp = [root implementor];
	return( imp );
}

@end
