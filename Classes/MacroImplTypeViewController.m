//  MIT Licence
//
//  Created on 08/03/2009.
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

#import "MacroImplTypeViewController.h"
#import "MacroNode.h"
#import "RefreshProtocol.h"


@implementation MacroImplTypeViewController
@synthesize implHandler,implIndex,localizedTypeMap;

-(MacroImplTypeViewController*)init{
	if (!(self = [super init])) return nil;
	NSArray* keys = [[MacroNode implDefinitionDictionary] allKeys];
	NSMutableArray*localized = [NSMutableArray arrayWithCapacity:[keys count]];
	NSString *type = nil;
	for( type in keys ){
		[localized addObject:NSLocalizedString(type, @"" )];
	}
	localizedTypeMap = [[NSMutableDictionary alloc] initWithObjects:keys forKeys:localized];
	[self setDataArray:localized];
	return( self );
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString * type = [localizedTypeMap objectForKey:[searchArray objectAtIndex:[indexPath row]]];
	[implHandler replaceImplementorAt:implIndex with:[implHandler createNewImplForType:type]];
	RefreshObject([self navigationController]);
	[[self navigationController] popViewControllerAnimated:YES];

}

@end

