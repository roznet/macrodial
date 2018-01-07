//  MIT Licence
//
//  Created on 07/03/2009.
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


#import "MacroListController.h"
#import "AppGlobals.h"
#import "FieldValuePreviewCell.h"
#import "AppConstants.h"
#import "MacroEditViewController.h"

@implementation MacroListController
@synthesize organizer;

- (void)viewDidLoad {
    [super viewDidLoad];

	[self setOrganizer:[AppGlobals organizer]];
	UITableView * tableView = (UITableView*)[self view];
	[tableView setDelegate:self];
	[tableView setDataSource:self];
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if( self.editing == YES ){
		return( [organizer numberOfMacros] + 1 );
	}
    return [organizer numberOfMacros];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    FieldValuePreviewCell *cell = (FieldValuePreviewCell*)[tableView dequeueReusableCellWithIdentifier:@"FieldValue"];
    if (cell == nil) {
        cell = [[FieldValuePreviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FieldValue"];
    }
	if( [indexPath row] < [organizer numberOfMacros] ){
		cell.field.text		= [organizer macroNameAtIndex:(int)[indexPath row]];
		cell.preview.text	= [organizer macroEvaluate:(int)[indexPath row] forNumber:[AppGlobals configGetString:CONFIG_SAMPLE_NUMBER defaultValue:@""]];
		cell.accessoryType	= UITableViewCellAccessoryDisclosureIndicator;
	}else{
		cell.field.text = NSLocalizedString( @"createnewmacro", @"" );
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	MacroEditViewController * mvc = [[MacroEditViewController alloc] initWithIndex:(int)[indexPath row]];
	[mvc setSampleNumber:[AppGlobals configGetString:CONFIG_SAMPLE_NUMBER defaultValue:@""]];
	[[self navigationController] pushViewController:mvc animated:YES];
}



- (void)setEditing:(BOOL)flag animated:(BOOL)animated
{
	[super setEditing:flag animated:animated];
	if( flag == NO ){
		RefreshObject([self navigationController]);
	}
	UITableView * tv = (UITableView*)[self view];
	[tv reloadData];

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	if( [indexPath row] < [organizer numberOfMacros] ){
		[organizer removeMacroAtIndex:(int)[indexPath row]];
	}else{
		NSString * name = [organizer nextNewName];
		[AppGlobals recordEvent:RECORDEVENT_CREATE_NEW_MACRO every:RECORDEVENT_STEP_EVERY];
		[organizer addOrReplaceMacro:name definition:@"<rule><type>prefix</type><prefix></prefix></rule>"];
	}
	[tableView reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	if( [indexPath row] < [[self organizer] numberOfMacros] ){
		return( UITableViewCellEditingStyleDelete );
	}else{
		return( UITableViewCellEditingStyleInsert );
	}
}

-(void)refreshAfterDataChange{
	UITableView * tv = (UITableView*)[self view];
	[tv reloadData];
}


@end

