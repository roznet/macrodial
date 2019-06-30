//  MIT Licence
//
//  Created on 11/03/2009.
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

#import "MacroNameViewController.h"
#import "AppGlobals.h"
#import "AppConstants.h"
#import "RefreshProtocol.h"
#import "RZUtils/RZUtils.h"

@implementation MacroNameViewController
@synthesize organizerIndex,textField,forceRename;

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIView *contentView				= [[UIView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
	contentView.backgroundColor		=  [AppGlobals backgroundColor];
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask	= (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);


	UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(5, 42, 300, 32 )];
	[label setText:NSLocalizedString( @"Enter Macro Name", @"")];
	[label setBackgroundColor:[AppGlobals backgroundColor]];
	[contentView addSubview:label];

	UITextField * name = [[UITextField alloc] initWithFrame:CGRectMake(5, 70, 300, 32)];
	name.borderStyle = UITextBorderStyleRoundedRect;
	[contentView addSubview:name];
	[name setDelegate:self];
	[name setText:[[AppGlobals organizer] macroNameAtIndex:[self organizerIndex]]];
	[self setTextField:name];

	self.view = contentView;

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}



#pragma mark UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField*)aField{
	[self navigationItem].rightBarButtonItem = [[UIBarButtonItem alloc]
																 initWithTitle:@"Done"
																 style:UIBarButtonItemStyleDone
																 target:self
																 action:@selector(doneEditing:)];

}

-(void)textFieldDidEndEditing:(UITextField*)aField{
	[self navigationItem].rightBarButtonItem = [[UIBarButtonItem alloc]
												 initWithTitle:@"Done"
												 style:UIBarButtonItemStyleDone
												 target:self
												 action:@selector(doneEditing:)];
}


-(void)doneEditing:(id)sender{
	[[self textField] resignFirstResponder];
	[self navigationItem].rightBarButtonItem = nil;

	// Rename
	if( ![[textField text] isEqualToString:[[AppGlobals organizer] macroNameAtIndex:[self organizerIndex]]] ){
		if( forceRename ){
			[[AppGlobals organizer] renameMacroAtIndex:[self organizerIndex] newName:[textField text]];
			RefreshObject([self navigationController]);
			[[self navigationController] popToRootViewControllerAnimated:YES];
		}else{
			[self renameOrCreate];
		}
	}
}

- (void) renameOrCreate
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                    message:NSLocalizedString( @"Do you want to rename or create new?",@"")
                                                             preferredStyle:UIAlertControllerStyleAlert];


    [alert addCancelAction];
    [alert addAction:[UIAlertAction actionWithTitle:@"Create"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction*action){
                                                [AppGlobals recordEvent:RECORDEVENT_COPIED_MACRO every:RECORDEVENT_STEP_EVERY];
                                                [[AppGlobals organizer] addOrReplaceMacro:[self.textField text] implementor:[[AppGlobals organizer] macroImplAtIndex:self.organizerIndex]];
                                                RefreshObject([self navigationController]);
                                                [[self navigationController] popToRootViewControllerAnimated:YES];

                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Rename"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction*action){
                                                [[AppGlobals organizer] renameMacroAtIndex:[self organizerIndex] newName:[self.textField text]];
                                                RefreshObject([self navigationController]);
                                            }]];
    [self presentViewController:alert animated:YES completion:^(){}];
}

@end
