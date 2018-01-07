//  MIT Licence
//
//  Created on 06/03/2009.
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

#import "ConfigViewController.h"
#import "SwitchCell.h"
#import "FieldValuePreviewCell.h"
#import "AppGlobals.h"
#import "MacroEditViewController.h"
#import "MacroListController.h"
#import "AppConstants.h"
#import "SetupWizardViewController.h"
#import "WebListViewController.h"
#import "WebCodeViewController.h"
#import "TextInputCell.h"
#import "WebUploadViewController.h"
#import "HtmlViewController.h"
#import "DebugViewController.h"

@implementation ConfigViewController

-(ConfigViewController*)init{
	if (!(self = [super initWithStyle:UITableViewStyleGrouped])) return nil;
	return(  self );
};


- (void)viewDidLoad {
    [super viewDidLoad];

	UITableView * tableView = (UITableView*)[self view];
	[tableView setDelegate:self];
	[tableView setDataSource:self];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}



#pragma mark UITableTableDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if( [AppGlobals configGetBool:CONFIG_DEBUG defaultValue:FALSE] ){
		return 3;
	}else{
		return 2;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case SECTION_MACROS:
			return( MACROS_END );
			break;
		case SECTION_SETTINGS:
			return( SETTINGS_END );
			break;
		case SECTION_DEBUG:
			return( DEBUG_END );
			break;
	}
	return 0;
}
-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section{
	switch( section ){
		case SECTION_MACROS:
			return( NSLocalizedString( @"Macros", @"" ) );
		case SECTION_SETTINGS:
			return( NSLocalizedString( @"Settings", @"" ) );
		case SECTION_DEBUG:
			return( NSLocalizedString( @"Debug", @"" ) );
	}
	return( nil );
};

-(UITableViewCell*)cellForSwitch:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath{
	FeedbackCell*rv = nil;

	if( [indexPath row] == SETTINGS_HOME_IDD ){
		TextInputCell * cell = (TextInputCell*)[tableView dequeueReusableCellWithIdentifier:@"TextInputCell"];
		if (!cell) cell = [[TextInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TextInputCell"];

		[[cell label] setText:NSLocalizedString( @"Home Country Code", @"" )];
		[[cell textField] setText:[AppGlobals configGetString:CONFIG_DEFAULT_IDD defaultValue:@""]];
		rv = cell;
	}else{
		SwitchCell *cell = (SwitchCell*) [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
		if (!cell) cell = [[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SwitchCell"];

		switch( [indexPath row] ){
			case SETTINGS_MACRO_SORT:
			{
				[[cell label] setText:NSLocalizedString( @"sortlastuse", @"" )];
				[[cell toggle]setOn:[AppGlobals configGetBool:CONFIG_SORTLASTUSE defaultValue:TRUE]];
				break;
			}
			case SETTINGS_MACRO_LEARN:
			{
				[[cell label] setText:NSLocalizedString( @"autolearn", @"" )];
				[[cell toggle]setOn:[AppGlobals configGetBool:CONFIG_AUTOLEARN defaultValue:TRUE]];
				break;
			}
			case SETTINGS_INCLUDE_UPLOAD:
			{
				[[cell label] setText:NSLocalizedString( @"includeupload", @"" )];
				[[cell toggle]setOn:[AppGlobals configGetBool:CONFIG_INCLUDE_UPLOAD defaultValue:TRUE]];
				break;
			}
			case SETTINGS_SMS_BUTTON:
			{
				[[cell label] setText:NSLocalizedString( @"Show SMS Button", @"" )];
				[[cell toggle]setOn:[AppGlobals configGetInt:CONFIG_LEFTBUTTON defaultValue:LEFTBUTTON_INFO]];
				break;
			}
			case SETTINGS_AUTO_EXEC:
			{
				[[cell label] setText:NSLocalizedString( @"Auto Rules", @"" )];
				[[cell toggle]setOn:[AppGlobals configGetInt:CONFIG_AUTOEXEC defaultValue:TRUE]];
				break;
			}
		}
		rv = cell;
	}
	[rv setIdentifierInt:[indexPath row]];
	[rv setFeedbackDelegate:self];
	[rv setSelectionStyle:UITableViewCellSelectionStyleNone];

	return( rv );
}

-(UITableViewCell*)cellForNavigation:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath{
	FieldValuePreviewCell *cell = (FieldValuePreviewCell*) [tableView dequeueReusableCellWithIdentifier:@"ConfigCell"];
	if (!cell) cell = [[FieldValuePreviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ConfigCell"];

	cell.value.text = @"";
	cell.preview.text = @"";
	if( [indexPath section] == SECTION_MACROS ){
		switch( [indexPath row] ){
			case MACROS_EDIT_MACROS:
				cell.field.text = NSLocalizedString( @"editmacros", @"" );
				cell.preview.text = [NSString stringWithFormat:@"%lu macros", (unsigned long)[[AppGlobals organizer] numberOfMacros]];
				break;
			case MACROS_WEB:
				cell.field.text = NSLocalizedString(@"weblist", @"");
				break;
			case MACROS_WEB_CODE:
				cell.field.text = NSLocalizedString(@"weblistcode", @"");
				break;
			case MACROS_SETUP_WIZARD:
				cell.field.text = NSLocalizedString(@"setupwizard", @"");
				break;
			case MACROS_WEB_UPLOAD:
				cell.field.text = NSLocalizedString(@"webupload", @"");
				break;
			case MACROS_INFO:
				cell.field.text = NSLocalizedString(@"about",@"");
				break;
		}
	}
	else{
		switch ([indexPath row]) {
			case DEBUG_INFO:
				cell.field.text = NSLocalizedString(@"Info",@"");
				break;
			default:
				break;
		}
	}
	return( cell );

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch( [indexPath section]){
		case SECTION_SETTINGS:
			return( [self cellForSwitch:tableView atIndexPath:indexPath] );
		case SECTION_MACROS:
		case SECTION_DEBUG:
			return( [self cellForNavigation:tableView atIndexPath:indexPath] );
	}
	return nil;
}


#pragma mark UITableViewDelegateMethods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath
{
	switch ([newIndexPath section]) {
		case SECTION_MACROS:
			switch ([newIndexPath row]) {
				case MACROS_EDIT_MACROS:
				{
					MacroListController * mlc = [[MacroListController alloc] init];
					[self.navigationController pushViewController:mlc animated:YES];
					break;
				}
				case MACROS_WEB:
				{
					WebListViewController * wlc = [[WebListViewController alloc] init];
					[self.navigationController pushViewController:wlc animated:YES];
					break;
				}
				case MACROS_WEB_UPLOAD:
				{
					WebUploadViewController * wuc = [[WebUploadViewController alloc] init];
					[self.navigationController pushViewController:wuc animated:YES];
					break;
				}

				case MACROS_WEB_CODE:
				{
					WebCodeViewController * wcc = [[WebCodeViewController alloc] init];
					[self.navigationController pushViewController:wcc animated:YES];
					break;
				}
				case MACROS_SETUP_WIZARD:
				{
					SetupWizardViewController * swc = [[SetupWizardViewController alloc] init];
					[self.navigationController pushViewController:swc animated:YES];
					break;
				}
				case MACROS_INFO:
				{
					HtmlViewController * hvc = [[HtmlViewController alloc] initWithFile:@"about.html"];
					[self.navigationController pushViewController:hvc animated:YES];
					break;
				}

				default:
					break;
			}
			break;
		case SECTION_DEBUG:{
			switch ([newIndexPath row]) {
				case DEBUG_INFO:
				{
					DebugViewController * dvc = [[DebugViewController alloc] initWithStyle:UITableViewStyleGrouped];
					[self.navigationController pushViewController:dvc animated:YES];
					break;
				}
			}
			break;
		}
		default:
			break;
	}
}

#pragma mark FeedbackCellDelegateProtocol

-(void)cellWasChanged:(id)cell{
	if( [cell identifierInt] == SETTINGS_HOME_IDD ){
		[AppGlobals configSet:CONFIG_DEFAULT_IDD stringVal:[[cell textField] text]];
		[[AppGlobals info] setDefaultIdd:[[cell textField] text]];

	}else{
		switch( [cell identifierInt] ){
			case SETTINGS_MACRO_SORT:
			{
				[AppGlobals configSet:CONFIG_SORTLASTUSE boolVal:[[cell toggle] isOn]];
				break;
			}
			case SETTINGS_MACRO_LEARN:
			{
				[AppGlobals configSet:CONFIG_AUTOLEARN boolVal:[[cell toggle] isOn]];
				break;
			}
			case SETTINGS_INCLUDE_UPLOAD:
			{
				[AppGlobals configSet:CONFIG_INCLUDE_UPLOAD boolVal:[[cell toggle] isOn]];
				break;
			}
			case SETTINGS_SMS_BUTTON:
			{
				[AppGlobals configSet:CONFIG_LEFTBUTTON boolVal:[[cell toggle] isOn]];
				RefreshObject([self navigationController]);
				break;
			}
			case SETTINGS_AUTO_EXEC:
			{
				[AppGlobals configSet:CONFIG_AUTOEXEC boolVal:[[cell toggle] isOn]];
				break;
			}
		}
	}

}
-(UINavigationController*)baseNavigationController{
	return( [self navigationController] );
}
-(UINavigationItem*)baseNavigationItem{
	return( [self navigationItem] );
}

-(void)refreshAfterDataChange{
	[[self tableView] reloadData];
}

@end
