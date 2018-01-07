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

#import "MacroImplViewController.h"
#import "MacroImplTypeViewController.h"
#import "AppConstants.h"
#import "TextInputCell.h"
#import "RefreshProtocol.h"

@implementation MacroImplViewController
@synthesize implHandler,implIndex;

-(MacroImplViewController*)init{
	return( [super initWithStyle:UITableViewStyleGrouped] );
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

-(MacroImpl*)implementor{
	return( [implHandler implementorAtIndex:implIndex] );
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if( [[self implementor] argumentsNames]){
		return( 2 );
	}else{
		return 1;
	}
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if( section == SECTION_TYPE ){
		return 1;
	}else{
		return( [[[self implementor] argumentsNames] count] );
	}
}


- (UITableViewCell *)cellForType:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell=nil;

	static NSString *CellIdentifier = @"Cell";

	cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
#if __IPHONE_3_0
	[[cell textLabel] setText:NSLocalizedString([[self implementor] type], @"")];
#else
	[cell setText:NSLocalizedString([[self implementor] type], @"")];
#endif
	return( cell );
}

-(UITableViewCell*)cellForArg:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	TextInputCell * cell=nil;

	static NSString *CellIdentifier = @"ArgCell";

	cell = (TextInputCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[TextInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	[cell setFeedbackDelegate:self];
	NSString * arg = [[[self implementor] argumentsNames] objectAtIndex:[indexPath row]];
	NSString * val = [[self implementor] getArgument:arg];
	[cell setIdentifierString:arg];
	[[cell label] setText:arg];
    [[cell textField] setKeyboardType:[[self implementor] getKeyboardType:arg]];
	if( val ){
		[[cell textField] setText:val];
	}else{
		[[cell textField] setText:@""];
		[[cell textField] setPlaceholder:NSLocalizedString(@"entervalue", @"" )];
	}

	return( cell );

}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if( [indexPath section] == SECTION_TYPE ){
		return( [self cellForType:tableView cellForRowAtIndexPath:indexPath] );
	}else{
		return( [self cellForArg:tableView cellForRowAtIndexPath:indexPath] );
	}

    return nil;
}

-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section{
	switch( section ){
		case SECTION_TYPE:
			return( NSLocalizedString( @"elementtype", @"" ) );
		case SECTION_ARGUMENT:
			return( NSLocalizedString( @"elementargument", @"" ) );
	}
	return( nil );
};

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if( [indexPath section] == SECTION_TYPE){
		MacroImplTypeViewController * tvc = [[MacroImplTypeViewController alloc] init];
		[tvc setImplIndex:[self implIndex]];
		[tvc setImplHandler:[self implHandler]];
		[[self navigationController] pushViewController:tvc animated:YES];
	};
}


#pragma mark FeedbackCellDelegateProtocol

-(void)cellWasChanged:(id)cell{
	TextInputCell * tic = (TextInputCell*) cell;
	[implHandler setArgumentImplementorAt:implIndex key:[tic identifierString] value:[[tic textField] text]];
	RefreshObject([self navigationController]);

	self.navigationItem.rightBarButtonItem = nil;
}

-(UINavigationController*)baseNavigationController{
	return( [ self navigationController] );
}
-(UINavigationItem*)baseNavigationItem{
	return( [self navigationItem] );
}

-(void)refreshAfterDataChange{
	UITableView * tv = (UITableView*)[self view];
	[tv reloadData];

}

@end

