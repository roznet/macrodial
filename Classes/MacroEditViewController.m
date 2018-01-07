//  MIT Licence
//
//  Created on 28/02/2009.
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

#import "MacroEditViewController.h"
#import "AppGlobals.h"
#import "FieldValuePreviewCell.h"
#import "MacroImplViewController.h"
#import "TextInputCell.h"
#import "MacroImplTypeViewController.h"
#import "RefreshProtocol.h"
#import "AppConstants.h"
#import "MacroNameViewController.h"


@implementation MacroEditViewController
@synthesize implHandler,variables,name,sampleNumber,organizerIndex;

#pragma mark Initialization

-(MacroEditViewController*)initWithIndex:(NSUInteger)aIdx{
	MacroOrganizer * organizer = [AppGlobals organizer];

	if (!(self = [self initWithName:[organizer macroNameAtIndex:aIdx] impl:[organizer macroImplAtIndex:aIdx]
		  andVariables:[organizer macroVariablesAtIndex:aIdx]])) return nil;
	[self setOrganizerIndex:aIdx];

	return( self );
}

-(MacroEditViewController*)initWithName:(NSString*)aName impl:(MacroImpl*)aImpl andVariables:(NSMutableDictionary*)aDict{
    if (!(self = [super init])) return nil;

	name		= aName;
	implHandler = [[MacroImplHandler alloc] initWithImplementor:aImpl];
	variables	= aDict;


	if (!(self = [super initWithStyle:UITableViewStyleGrouped])) return nil;
	organizerIndex = INVALID_ORGANIZER_IDX;

	return( self );
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


#pragma mark UITableViewController Methods
- (void)loadView
{
	[super loadView];
	UITableView*tv = (UITableView*)[self view ];
	[tv setDataSource:self];
	[tv setDelegate:self];

	self.navigationItem.rightBarButtonItem = self.editButtonItem;

}
- (void)setEditing:(BOOL)flag animated:(BOOL)animated
{
    [super setEditing:flag animated:animated];
	if( [[self navigationController] conformsToProtocol:@protocol(RefreshProtocol)] ){
		id<RefreshProtocol> refreshable = (id<RefreshProtocol>)[self navigationController];
		[refreshable refreshAfterDataChange];
	}
	[[self tableView] reloadData];
}

#pragma mark Process Implementor

-(MacroImpl*)implementorAtIndex:(NSUInteger)idx{
	return( [implHandler implementorAtIndex:idx] );
}

-(NSString*)implementorPreviewTillIndex:(NSUInteger)idx{
	NSString * previewText = @"";
	if( [sampleNumber length] > 0 ){
		previewText = [implHandler implementorExecuteOn:sampleNumber with:[self variables] untilIndex:idx];
	}
	return( previewText );
}

-(NSUInteger)implementorCount{
	return( [implHandler implementorCount] );
}

-(NSString*)variableNameAtIndex:(NSUInteger)idx{
	return( (NSString*)[[[implHandler implementor] variablesNames] objectAtIndex:idx] );
}
-(NSString*)variableValueAtIndex:(NSUInteger)idx{
	NSString * varname	= [self variableNameAtIndex:idx];
	NSString * value	= [variables objectForKey:varname];
	if( ! value ){
		value = [[AppGlobals organizer] macroVariablesValueGuess:varname];
		if( ! value )
			value = @"";
	}
	return( value );
}

-(NSUInteger)variableCount{
	return( [[[implHandler implementor] variablesNames] count] );
}

#pragma mark cell Definitions
-(UITableViewCell*) cellForVariable:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath{
	TextInputCell *cell = (TextInputCell*)[tableView dequeueReusableCellWithIdentifier:@"InputCell"];
	if (!cell) cell = [[TextInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InputCell"];

	// Set up the cell's text
	[[cell label] setText:[self variableNameAtIndex:(int)[indexPath row]]];

	[[cell textField] setText:[self variableValueAtIndex:(int)[indexPath row]]];
	[cell setIdentifierString:[self variableNameAtIndex:(int)[indexPath row]]];
	[cell setFeedbackDelegate:self];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];

	return cell;
}

-(UITableViewCell*) cellForDefinition:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath{
	FieldValuePreviewCell *cell = (FieldValuePreviewCell*)[tableView dequeueReusableCellWithIdentifier:@"FieldValuePreviewCell"];
	if (!cell) cell = [[FieldValuePreviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FieldValuePreviewCell"];

	if( [indexPath row] < [self implementorCount] ){
		NSString * type = [[self implementorAtIndex:(int)[indexPath row]] typeDescription];
		NSString * args = [[self implementorAtIndex:(int)[indexPath row]] argsDescription];

		[cell.field setText:type];
		[cell.value setText:args];

		[cell.preview setText:[self implementorPreviewTillIndex:(int)[indexPath row]]];

		cell.showsReorderControl = YES;

	}else{
		[cell.field		setText:NSLocalizedString( @"addnewdefinition", @"")];
		[cell.value		setText:@""];
		[cell.preview	setText:@""];
	}

	return cell;
}

-(UITableViewCell*) cellForName:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-cell"];
#if __IPHONE_3_0
	[[cell textLabel] setText:name];
#else
	[cell setText:name];
#endif

	return cell;
}


-(NSUInteger)remapSection:(NSUInteger)section{
	NSUInteger rv = section;
	if( [self variableCount] == 0 && section == SECTION_VARIABLE ){
		rv = SECTION_DEFINITION;
	}
	return( rv );
}


#pragma mark UITableTableDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self variableCount] > 0 ? 3 : 2;
}


-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section{
	NSString * rv = nil;
	switch ([self remapSection:section]) {
		case SECTION_NAME:
			rv = NSLocalizedString( @"name",		@"" );
			break;
		case SECTION_VARIABLE:
			rv = NSLocalizedString( @"variables",	@"" );
			break;
		case SECTION_DEFINITION:
			rv = NSLocalizedString( @"definition",	@"" );
			break;
	}
	return( rv );
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger rv ;
	switch ([self remapSection:section]) {
		case SECTION_NAME:
			rv = 1;
			break;
		case SECTION_VARIABLE:
			rv = [self variableCount];
			break;
		case SECTION_DEFINITION:
			rv = [self implementorCount];
			if( self.editing == YES ){
				rv ++;
			}
			break;
		default:
			rv = 0;
			break;
	}
	return( rv );
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell * rv = nil;

	switch ([self remapSection:[indexPath section]]) {
		case SECTION_NAME:
			rv= [self cellForName:tableView atIndexPath:indexPath];
			break;
		case SECTION_VARIABLE:
			rv= [self cellForVariable:tableView atIndexPath:indexPath];
			break;
		case SECTION_DEFINITION:
			rv= [self cellForDefinition:tableView atIndexPath:indexPath];
			break;
		default:
			rv = nil;
			break;
	}
	return( rv );
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
	BOOL rv = NO;
	if( [self remapSection:[indexPath section]] == SECTION_DEFINITION ){
		rv = YES;
	}
	return rv ;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
	BOOL rv = NO;
	if( [self remapSection:[indexPath section]] == SECTION_DEFINITION ){
		rv = YES;
	}
	return( rv );
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
	[implHandler moveImplementorFrom:[fromIndexPath row] to:[toIndexPath row]];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	if( [indexPath row] < [implHandler implementorCount] ){
		[implHandler deleteImplementorAt:[indexPath row]];
	}else{
		[implHandler insertImplementor:[implHandler createNewImplForType:@"prefix"] atIndex:[implHandler implementorCount]];
	}
	[tableView reloadData];
}

#pragma mark UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath
{
	switch ([self remapSection:[newIndexPath section]] ) {
		case SECTION_DEFINITION:
		{
			if( [[[implHandler implementorAtIndex:[newIndexPath row]] argumentsNames] count] ){
				MacroImplViewController * ivc = [[MacroImplViewController alloc] init];
				[ivc setImplIndex:[newIndexPath row]];
				[ivc setImplHandler:[self implHandler]];
				[[self navigationController] pushViewController:ivc animated:YES];

			}else{
				MacroImplTypeViewController * tvc = [[MacroImplTypeViewController alloc] init];
				[tvc setImplIndex:[newIndexPath row]];
				[tvc setImplHandler:[self implHandler]];
				[[self navigationController] pushViewController:tvc animated:YES];
			}
			break;
		}
		case SECTION_NAME:
		{
			MacroNameViewController * nvc = [[MacroNameViewController alloc] init];
			[nvc setOrganizerIndex:[self organizerIndex]];
			[[self navigationController] pushViewController:nvc animated:YES];
			break;
		}
		default:
			break;
	}
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	if( [self remapSection:[indexPath section]] == SECTION_DEFINITION  ){
		if( [indexPath row] < [self implementorCount] ){
			return( UITableViewCellEditingStyleDelete );
		}else{
			return( UITableViewCellEditingStyleInsert );
		}
	}
	return( UITableViewCellEditingStyleNone );
}
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath{
	if( [sourceIndexPath section] > [proposedDestinationIndexPath section ] ){
		return( [NSIndexPath indexPathForRow:0 inSection:[sourceIndexPath section]] );
	}
	if( [self remapSection:[sourceIndexPath section]] == SECTION_DEFINITION ){
		// don't move last "add new def" row
		if( [sourceIndexPath row] >= [self implementorCount] ){
			return( sourceIndexPath );
		}
	}
	return( proposedDestinationIndexPath );
}

#pragma mark FeedbackCellDelegateProtocol

-(void)cellWasChanged:(id)cell{
	TextInputCell * tic = (TextInputCell*) cell;
	if( organizerIndex != INVALID_ORGANIZER_IDX ){
		[variables setObject:[[tic textField] text] forKey:[tic identifierString]];
		[[AppGlobals organizer] saveMacroVariable:[self organizerIndex]];
		RefreshObject([self navigationController]);
	}

	//make sure all navigation back
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
	if( organizerIndex != INVALID_ORGANIZER_IDX ){
		[self setName:[[AppGlobals organizer] macroNameAtIndex:organizerIndex]];
	}
	if( [implHandler dirty] ){
		[AppGlobals recordEvent:RECORDEVENT_EDITED_MACRO   every:RECORDEVENT_STEP_FIRSTONLY];
		[AppGlobals recordEvent:RECORDEVENT_EDITED_MACRO10 every:10];
		[[AppGlobals organizer] addOrReplaceMacro:[self name] implementor:[implHandler implementor]];
	}
}

@end
