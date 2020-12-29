//  MIT Licence
//
//  Created on 15/05/2009.
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

#import "WebUploadViewController.h"
#import "TextInputCell.h"
#import "FieldValuePreviewCell.h"
#import "AppGlobals.h"
#import "HtmlViewController.h"
#import "AppConstants.h"

@interface WebUploadViewController ()
@property (nonatomic,strong) RemoteUploadPackage * remotePackage;

@end

@implementation WebUploadViewController
@synthesize actionButton;
@synthesize activityIndicator;
@synthesize macroNames;
@synthesize macroUploadFlag;

-(WebUploadViewController*)init{
	if (!(self = [super initWithStyle:UITableViewStyleGrouped])) return nil;

	if( self ){
		NSArray * names = [[AppGlobals organizer] macroNames];
		[self setMacroNames:names];
		NSMutableArray * selected = [NSMutableArray arrayWithCapacity:[names count]];
		for( int i = 0 ; i < [names count];i++ ){
			[selected addObject:[NSNumber numberWithBool:[self nameShouldBeSelected:[names objectAtIndex:i]]]];
		};
		[self setMacroUploadFlag:selected];
	}

	return(  self );
};

-(void)viewDidLoad {
    [super viewDidLoad];

	[self setActionButton:[[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonItemStylePlain target:self action:@selector(upload)]];

	UITableView * tableView = (UITableView*)[self view];
	[tableView setDelegate:self];
	[tableView setDataSource:self];
	[[self navigationItem] setRightBarButtonItem:actionButton];

	activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [activityIndicator setCenter:CGPointMake(160.0f, 208.0f)];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
	[activityIndicator stopAnimating];
	[[self view] addSubview:activityIndicator];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


#pragma mark UITableTableDataSource Methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return UPLOAD_SECTION_END;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case UPLOAD_SECTION_MACROS:
			return( UPLOAD_MACROS_END );
			break;
		case UPLOAD_SECTION_INFO:
			return( UPLOAD_INFO_END );
			break;
	}
	return 0;
}
-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section{
	switch( section ){
		case UPLOAD_SECTION_MACROS:
			return( NSLocalizedString( @"Macros", @"" ) );
		case UPLOAD_SECTION_INFO:
			return( NSLocalizedString( @"Info", @"" ) );
	}
	return( nil );
};

-(UITableViewCell*)cellForInput:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath{
	TextInputCell *cell = (TextInputCell*) [tableView dequeueReusableCellWithIdentifier:@"TextInputCell"];
	if (!cell) cell = [[TextInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TextInputCell"];

	switch( [indexPath row] ){
		case UPLOAD_INFO_CONTACT:
		{
			[[cell label] setText:NSLocalizedString( @"Contact Name", @"" )];
			[[cell textField] setText:[AppGlobals configGetString:UPLOAD_KEY_CONTACT defaultValue:@""]];
			[[cell textField] setKeyboardType:UIKeyboardTypeEmailAddress];
			break;
		}
		case UPLOAD_INFO_PACKAGE:
		{
			[[cell label] setText:NSLocalizedString( @"Package Name", @"" )];
			[[cell textField]	setText:[AppGlobals configGetString:UPLOAD_KEY_PACKAGE defaultValue:@""]];
			[[cell textField] setKeyboardType:UIKeyboardTypeAlphabet];
			break;
		}
		case UPLOAD_INFO_DESCRIPTION:
		{
			[[cell label] setText:NSLocalizedString( @"Description", @"" )];
			[[cell textField]	setText:[AppGlobals configGetString:UPLOAD_KEY_DESCRIPTION defaultValue:@""]];
			[[cell textField] setKeyboardType:UIKeyboardTypeAlphabet];
			break;
		}
		case UPLOAD_INFO_UNLOCK:
		{
			[[cell label] setText:NSLocalizedString( @"Unlock Code", @"" )];
			[[cell textField]	setText:[AppGlobals configGetString:UPLOAD_KEY_UNLOCKCODE defaultValue:@""]];
			[[cell textField] setKeyboardType:UIKeyboardTypeAlphabet];
			break;
		}
	}
	[cell setIdentifierInt:[indexPath row]];
	[cell setFeedbackDelegate:self];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return( cell );
}

-(UITableViewCell*)cellForNavigation:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath{
	FieldValuePreviewCell *cell = (FieldValuePreviewCell*) [tableView dequeueReusableCellWithIdentifier:@"ConfigCell"];
	if (!cell) cell = [[FieldValuePreviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ConfigCell"];

	cell.value.text = @"";
	cell.preview.text = @"";
	switch( [indexPath row] ){
		case UPLOAD_MACROS_HELP:
			cell.field.text = NSLocalizedString( @"helpupload", @"" );
			break;

		case UPLOAD_MACROS_CHOOSE:
			cell.field.text = NSLocalizedString( @"choosemacros", @"" );
			cell.preview.text = [NSString stringWithFormat:@"%d macros", [self numberOfMacros]];
			break;
	}
	return( cell );

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch( [indexPath section]){
		case UPLOAD_SECTION_INFO:
			return( [self cellForInput:tableView atIndexPath:indexPath] );

		case UPLOAD_SECTION_MACROS:
			return( [self cellForNavigation:tableView atIndexPath:indexPath] );
	}
	return nil;
}

#pragma mark UITableViewDelegateMethods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath
{
	switch ([newIndexPath section]) {
		case UPLOAD_SECTION_MACROS:{
			switch ([newIndexPath row]) {
				case UPLOAD_MACROS_HELP:
				{
					HtmlViewController * hvc = [[HtmlViewController alloc] initWithFile:@"beforeupload.html"];
					[self.navigationController pushViewController:hvc animated:YES];
					break;
				}
				case UPLOAD_MACROS_CHOOSE:
				{
					MacroListPickerViewController * mlpvc = [[MacroListPickerViewController alloc] initWithDelegate:self];
					[[self navigationController] pushViewController:mlpvc animated:true];
					break;
				}
				default:
					break;
			}
		}

		default:
			break;
	}
}

#pragma mark FeedbackCellDelegateProtocol



-(void)cellWasChanged:(id)cell{
	switch( [cell identifierInt] ){
		case UPLOAD_INFO_CONTACT:
		{
			[AppGlobals configSet:UPLOAD_KEY_CONTACT stringVal:[cell text]];
			break;
		}
		case UPLOAD_INFO_PACKAGE:
		{
			[AppGlobals configSet:UPLOAD_KEY_PACKAGE stringVal:[cell text]];
			break;
		}
		case UPLOAD_INFO_DESCRIPTION:
		{
			[AppGlobals configSet:UPLOAD_KEY_DESCRIPTION stringVal:[cell text]];
			break;
		}
		case UPLOAD_INFO_UNLOCK:
		{
			[AppGlobals configSet:UPLOAD_KEY_UNLOCKCODE stringVal:[cell text]];
			break;
		}
	}
	[[self navigationItem] setRightBarButtonItem:actionButton];
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

-(void)upload{
	int n = [self numberOfMacros];
	if( n == 0 ){
        [self presentSimpleAlertWithTitle:@"Upload Confirmation" message:@"Please select at least one macro before uploading?"];

	}else{
        UIAlertController * alert = [UIAlertController simpleConfirmWithTitle:@"Upload Confirmation"
                                                                      message:[NSString stringWithFormat:@"Are you sure you want to upload %d macros?", n]
                                                                       action:^(){
                                                                           [self uploadMacros];
                                                                       }];
        [self presentViewController:alert animated:YES completion:^(){}];
	}

};

-(void)uploadMacros{
    if( [self numberOfMacros] > 0){

        NSDictionary * postData = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [AppGlobals configGetString:UPLOAD_KEY_DESCRIPTION	defaultValue:@""],	@"macro_description",
                                   [AppGlobals configGetString:UPLOAD_KEY_DESCRIPTION	defaultValue:@""],	@"package_description",
                                   [AppGlobals configGetString:UPLOAD_KEY_CONTACT		defaultValue:@""],	@"package_contact",
                                   [AppGlobals configGetString:UPLOAD_KEY_PACKAGE		defaultValue:@""],	@"package_name",
                                   [AppGlobals configGetString:UPLOAD_KEY_UNLOCKCODE	defaultValue:@""],	@"unlock_code",
                                   nil];
        NSMutableArray * names = [NSMutableArray arrayWithCapacity:[macroNames count]];
        NSMutableArray * xml   = [NSMutableArray arrayWithCapacity:[macroNames count]];
        MacroOrganizer * organizer = [AppGlobals organizer];
        for( int i = 0 ; i < [macroNames count];i++ ){
            if( [[macroUploadFlag objectAtIndex:i] boolValue] ){
                NSUInteger idx = [organizer indexForMacroName:[macroNames objectAtIndex:i]];
                if( idx != INVALID_MACRO_INDEX ){
                    [names addObject:[macroNames objectAtIndex:i]];
                    [xml   addObject:[organizer macroDefinitionAtIndex:idx]];
                }
            }
        }

        [activityIndicator startAnimating];
        self.remotePackage = [[RemoteUploadPackage alloc] initWithMacroNames:names macroXml:xml basePost:postData andDelegate:self];
    }
}

-(void)downloadPackageSuccessful:(id)connection{
	[activityIndicator stopAnimating];
	[[self navigationController] popToRootViewControllerAnimated:YES];
}
-(void)downloadPackageFailed:(id)connection{
	[activityIndicator stopAnimating];
}

#pragma mark MacroListPickerDelegate

-(BOOL)nameShouldBeSelected:(NSString*)aName{
	NSDictionary * aDict = [[AppGlobals settings] objectForKey:CONFIG_LIST_STATUS];
	NSNumber * k = [aDict objectForKey:aName];
	if( k ){
		return( [k boolValue] );
	}else{
		return( FALSE );
	}
}

-(void)addStatusToSettings{
	NSDictionary * aDict = [NSDictionary dictionaryWithObjects:macroUploadFlag forKeys:macroNames];
	[[AppGlobals settings] setObject:aDict forKey:CONFIG_LIST_STATUS];
}

-(NSArray*)obtainNames{
	return( [self macroNames] );
}
-(NSMutableArray*)obtainStatuses{
	return( [self macroUploadFlag] );
}
-(void)refreshStatuses:(NSMutableArray*)aStatuses{
	[self setMacroUploadFlag:aStatuses];
	[self addStatusToSettings];
	[[self tableView] reloadData];
}

-(int)numberOfMacros{
	int rv = 0;
	for( int i = 0 ; i < [macroUploadFlag count]; i++ ){
		if( [[macroUploadFlag objectAtIndex:i] boolValue] )
			rv++;
	}
	return( rv );
}

@end
