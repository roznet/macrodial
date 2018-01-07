//  MIT Licence
//
//  Created on 25/02/2009.
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

#import "MacroVariablesViewController.h"
#import "RefreshProtocol.h"
#import "AppGlobals.h"

@implementation MacroVariablesViewController
@synthesize dataSource, requiredKeys, currentEditField;

-(MacroVariablesViewController*)initWithDataSource:(MacroTableDataSource*)aData{
	if( self = [super init] ){
		dataSource = aData;
		MacroImpl*	imp = [dataSource selectedMacroImpl];
		requiredKeys	= [imp variablesNames];
		currentEditField = NULL;
	}
	return( self );
}


- (void)loadView {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain
																			  target:self action:@selector(saveVariables:)];

	UIView *contentView				= [[UIView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
	contentView.backgroundColor		=  [AppGlobals backgroundColor];
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask	= (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

	UILabel * test			= [[UILabel alloc] initWithFrame:CGRectMake(10.0, 64.0, 320-10, 32.0) ];
	test.backgroundColor	= [AppGlobals backgroundColor];
	test.text				= @"Enter values";

	UITableView * varTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 100, 320-5, 140 ) style: UITableViewStyleGrouped ];
	[varTableView setDelegate:self];
	[varTableView setDataSource:self];
	varTableView.backgroundColor = [AppGlobals backgroundColor];
	[contentView addSubview:varTableView];

	[contentView addSubview:test];

	self.view = contentView;
}

-(void)saveVariables:(id)sender{
	[[self navigationController] popViewControllerAnimated:YES];
	[[dataSource macroOrganizer] saveMacroVariable:[dataSource selectedMacro]];
	RefreshObject([self navigationController]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark UITableTableDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return( [requiredKeys count] );
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-cell"];

	// Set up the cell's text
	NSString * key   = [requiredKeys objectAtIndex:[indexPath row]];
	NSString * value = [[dataSource selectedMacroVariables] objectForKey:key];
	if( ! value ){
		value = [[AppGlobals organizer] macroVariablesValueGuess:key];
		if( value ){
			[[dataSource selectedMacroVariables] setObject:value forKey:key];
		}
	}
#ifdef __IPHONE_3_0
	[[cell textLabel] setText:key];
#else
	[cell setText:key];
#endif


	UITextField * e = [[UITextField alloc]initWithFrame:CGRectMake(120, 5, 300-120, 32)];
	if( value ){
		[e setText:value];
	};
	e.borderStyle		= UITextBorderStyleRoundedRect;
	e.tag				= [indexPath row];
//	e.backgroundColor	= [UIColor lightGrayColor];
	e.placeholder		= @"Enter Value";
	e.keyboardType		= UIKeyboardTypePhonePad;
	[e setDelegate:self];

	[cell addSubview:e];

	return cell;
}

#pragma mark UITableViewDelegateMethods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath
{
}

#pragma mark UITextFieldDelegateMethods

-(void)textFieldDidBeginEditing:(UITextField*)aField{
	[self setCurrentEditField:aField];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
											   initWithTitle:@"Done"
											   style:UIBarButtonItemStyleDone
											   target:self
											   action:@selector(doneEditing:)];

}

-(void)textFieldDidEndEditing:(UITextField*)aField{
	NSInteger i = [aField tag];
	NSString * value = [aField text];
	NSString * key   = [requiredKeys objectAtIndex:i];
	[[dataSource selectedMacroVariables] setObject:value forKey:key];

}


-(void)doneEditing:(id)sender{
	[currentEditField resignFirstResponder];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain
																			  target:self action:@selector(saveVariables:)];
	[self setCurrentEditField:NULL];
}


@end
