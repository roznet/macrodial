//  MIT Licence
//
//  Created on 16/02/2009.
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

#import "MacroTableDataSource.h"
#import "AppGlobals.h"
#import "AppConstants.h"
#import "FieldValuePreviewCell.h"


@implementation MacroTableDataSource
@synthesize selectedMacro,delegate,macroOrganizer;

-(MacroTableDataSource*) init {
	if( self = [super init] ){
		macroOrganizer = [AppGlobals organizer];
		[macroOrganizer loadCurrentMacros];

		selectedMacro			= -1;
	};
	return( self );
}

-(NSString*)selectedMacroDefinition{
	if( selectedMacro <0){
		return( nil );
	}
	return( [macroOrganizer macroDefinitionAtIndex:selectedMacro] );
}

-(NSString*)selectedMacroName{
	if( selectedMacro <0){
		return( @"" );
	}
	return( [macroOrganizer macroNameAtIndex:selectedMacro] );
}


-(NSInteger)selectedMacroId{
	if( selectedMacro <0){
		return( INVALID_MACRO_ID );
	}
	return( [macroOrganizer macroIdAtIndex:selectedMacro] );
}

-(MacroImpl*)selectedMacroImpl{
	if( selectedMacro <0){
		return( nil );
	}
	return( [macroOrganizer macroImplAtIndex:selectedMacro] );
}

-(NSMutableDictionary*)selectedMacroVariables{
	if( selectedMacro <0){
		return( nil );
	}
	return( [macroOrganizer macroVariablesAtIndex:selectedMacro] );
}


-(CGFloat)useFontSize{
	CGFloat rv = 20.0;
	if( [macroOrganizer numberOfMacros] < 3 ){
		rv = 20.0;
	}
	return( rv );
}
-(CGFloat)useCellHeight{
	CGFloat rv = 40.0;
	if( [macroOrganizer numberOfMacros] < 3 ){
		rv = 40.0;
	}
	return( rv );
}

#pragma mark UITableTableDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [macroOrganizer numberOfMacros];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	FieldValuePreviewCell *cell = (FieldValuePreviewCell*) [tableView dequeueReusableCellWithIdentifier:@"MacroChoiceCell"];
	if (!cell) cell = [[FieldValuePreviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MacroChoiceCell"];

	cell.field.text		= [macroOrganizer macroNameAtIndex:(int)[indexPath row]];
	cell.preview.text	= [macroOrganizer macroEvaluate:(int)[indexPath row] forNumber:[delegate sampleNumber]];
	cell.accessoryType	= UITableViewCellAccessoryDetailDisclosureButton;
	return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	selectedMacro = (int)[indexPath row];
	[delegate macroAccessorySelected];
}

#pragma mark UITableViewDelegateMethods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath
{
	selectedMacro = (int)[newIndexPath row];
	[delegate macroSelected];
}

@end
