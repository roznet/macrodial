//  MIT Licence
//
//  Created on 30/03/2009.
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

#import "AppGlobals.h"
#import "AppConstants.h"
#import "SetupWizardViewController.h"
#import "FieldValuePreviewCell.h"
#import "WebCodeViewController.h"
#import "WebListViewController.h"
#import "RefreshProtocol.h"

// Provider/Location
// Generic Sample Rules
// Code
// Web
// Clear all existing rules


@implementation SetupWizardViewController
@synthesize standardPackages;

-(SetupWizardViewController*)init{
	if (!(self = [super initWithStyle:UITableViewStyleGrouped])) return nil;
	if( self ){
		[self setStandardPackages:[[AppGlobals organizer] packagesArray]];
	}
	return( self );
}


- (void)viewDidLoad {
    [super viewDidLoad];

	[self.navigationItem setTitle:NSLocalizedString( @"Setup Wizard", @"" )];
	if( ![AppGlobals configGetBool:CONFIG_TIP_SHOWN defaultValue:FALSE] ){
		[AppGlobals configSet:CONFIG_TIP_SHOWN boolVal:TRUE];
        UIAlertController * ac = [UIAlertController simpleAlertWithTitle:@"Welcome" andMessage:@"You can use the wizard to set up your first rules from a standard package. Later the easiest way to define a new rule is to edit a number, the program will try to learn the rule automatically."];
        [self presentViewController:ac animated:YES completion:^(){}];
	}

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark UITableTableDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case WIZARD_STANDARD_PACKAGES:
			return( [standardPackages count] );
			break;
		case WIZARD_OTHER_SETUP:
			return( WIZARD_END );
			break;
	}
	return 0;
}
-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section{
	switch( section ){
		case WIZARD_STANDARD_PACKAGES:
			return( NSLocalizedString( @"Standard Packages", @"" ) );
		case WIZARD_OTHER_SETUP:
			return( NSLocalizedString( @"Other setup", @"" ) );
	}
	return( nil );
};

-(UITableViewCell*)cellForPackage:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath{
	FieldValuePreviewCell *cell = (FieldValuePreviewCell*) [tableView dequeueReusableCellWithIdentifier:@"ConfigCell"];
	if (!cell) cell = [[FieldValuePreviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ConfigCell"];

	cell.field.text		= [standardPackages objectAtIndex:[indexPath row]];
	cell.value.text		= @"";
	cell.preview.text	= @"";

	return( cell );
}

-(UITableViewCell*)cellForNavigation:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath{
	FieldValuePreviewCell *cell = (FieldValuePreviewCell*) [tableView dequeueReusableCellWithIdentifier:@"ConfigCell"];
	if (!cell) cell = [[FieldValuePreviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ConfigCell"];

	switch( [indexPath row] ){
		case WIZARD_WEB:
			cell.field.text = NSLocalizedString( @"weblist", @"" );
			break;
		case WIZARD_WEB_CODE:
			cell.field.text = NSLocalizedString(@"weblistcode", @"");
			break;
		case WIZARD_CLEAR_ALL:
			cell.field.text = NSLocalizedString(@"clearall", @"");
			break;
	}
	cell.value.text = @"";
	cell.preview.text = @"";
	return( cell );
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch( [indexPath section]) {
		case WIZARD_STANDARD_PACKAGES:
			return( [self cellForPackage:tableView atIndexPath:indexPath] );
		case WIZARD_OTHER_SETUP:
			return( [self cellForNavigation:tableView atIndexPath:indexPath] );
	}
	return nil;
}

#pragma mark Actions

-(BOOL)didSelectSetup:(NSUInteger)row{
	BOOL pop = FALSE;
	switch (row) {
		case WIZARD_WEB:
		{
			WebListViewController * wlc = [[WebListViewController alloc] init];
			[self.navigationController pushViewController:wlc animated:YES];
			break;
		}
		case WIZARD_WEB_CODE:
		{
			WebCodeViewController * wcc = [[WebCodeViewController alloc] init];
			[self.navigationController pushViewController:wcc animated:YES];
			break;
		}
		case WIZARD_CLEAR_ALL:
		{
			if( [[AppGlobals organizer] numberOfMacros] > 0 ){
                UIAlertController * ac = [UIAlertController simpleConfirmWithTitle:@"Clear All" message:@"This will delete all macros, are you sure?" action:^(){
                    [[AppGlobals organizer] clearAllMacros];
                    [[self navigationController] popViewControllerAnimated:YES];
                }];
                [self presentViewController:ac animated:YES completion:^(){}];
			}else{
				[[AppGlobals organizer] clearAllMacros];
				pop = TRUE;
				break;
			};
		}
		default:
			break;
	}
	return( pop );
}


-(BOOL)didSelectPackage:(NSUInteger)row{
	[[AppGlobals organizer] addPackage:[standardPackages objectAtIndex:row]];
	return( TRUE );
}

#pragma mark UITableViewDelegateMethods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	BOOL pop = FALSE;
	switch ([indexPath section]) {
		case WIZARD_STANDARD_PACKAGES:
			pop = [self didSelectPackage:[indexPath row]];
			break;
		default:
			pop = [self didSelectSetup:[indexPath row]];
			break;
	}
	RefreshObject([self navigationController]);

	[[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
	if( pop )
		[[self navigationController] popViewControllerAnimated:YES];
}



@end
