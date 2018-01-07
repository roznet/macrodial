//  MIT Licence
//
//  Created on 20/03/2009.
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

#import "WebCodeViewController.h"
#import "AppGlobals.h"
#import "WebListViewController.h"

@implementation WebCodeViewController
@synthesize code,label;


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIView *contentView				= [[UIView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
	contentView.backgroundColor		=  [AppGlobals backgroundColor];
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask	= (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

	CGFloat currentY	= 10.0 ;
	CGFloat elemHeight	= 32.0;
	CGFloat marginLeft	= 2.0;
	CGFloat elemWidth	= 320-2*marginLeft;
	CGFloat spaceHeight = 5.0;

	currentY	+=	elemHeight;
	currentY    +=	spaceHeight+3;
	elemHeight	=	32.0;
	CGRect labelRect = CGRectMake(marginLeft, currentY, elemWidth, elemHeight );
	label = [[UILabel alloc] initWithFrame:labelRect];

	currentY	+= elemHeight;
	currentY    += spaceHeight+2.0;
	elemHeight	= 32.0;
	CGRect codeRect = CGRectMake(marginLeft, currentY, elemWidth, elemHeight );
	code = [ [UITextField alloc] initWithFrame:codeRect];
	code.borderStyle		= UITextBorderStyleRoundedRect;
	code.backgroundColor	= [AppGlobals backgroundColor];
	code.placeholder		= @"Enter code";
	code.keyboardType		= UIKeyboardTypeAlphabet;
	code.delegate			= self;
	[contentView addSubview:code];

	self.view = contentView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark UITextFieldDelegate Functions
-(void)textFieldDidBeginEditing:(UITextField*)aField{
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
											   initWithTitle:@"Done"
											   style:UIBarButtonItemStyleDone
											   target:self
											   action:@selector(doneEditing:)];

	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
											  initWithTitle:@"Cancel"
											  style:UIBarButtonItemStyleDone
											  target:self
											  action:@selector(cancelEditing:)];

}

-(void)cancelEditing:(id)sender{
	[code resignFirstResponder];
	self.navigationItem.rightBarButtonItem = NULL;
	self.navigationItem.leftBarButtonItem = NULL;
	[[self navigationController] popViewControllerAnimated:YES];
}
-(void)doneEditing:(id)sender{
	[code resignFirstResponder];
	self.navigationItem.leftBarButtonItem = NULL;
	self.navigationItem.rightBarButtonItem = NULL;

	WebListViewController * wlc = [[WebListViewController alloc] initWithCode:[code text]];
	[self.navigationController pushViewController:wlc animated:YES];
}



@end
