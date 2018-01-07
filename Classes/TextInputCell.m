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

#import "TextInputCell.h"
#import "AppGlobals.h"

@implementation TextInputCell
@synthesize label,textField;

- (id)initWithStyle:(UITableViewCellStyle)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:frame reuseIdentifier:reuseIdentifier]) {
		label						= [[UILabel alloc] initWithFrame:CGRectZero];
		label.backgroundColor		= [UIColor clearColor];
		label.font					= [AppGlobals boldSystemFontOfSize:16];
		label.textColor				= [UIColor blackColor];

		textField					= [[UITextField alloc] initWithFrame:CGRectZero];
		textField.backgroundColor	= [UIColor clearColor];
		textField.font				= [AppGlobals systemFontOfSize:16];
		textField.textColor			= [UIColor blueColor];
		textField.keyboardType		= UIKeyboardTypePhonePad;
		textField.borderStyle		= UITextBorderStyleRoundedRect;

		[textField setDelegate:self];

		[self.contentView addSubview:textField];
		[self.contentView addSubview:label];

    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	// Rect that start at 5 from left bound x
	CGRect baseRect = CGRectInset( self.contentView.bounds, 5, 5);
	CGRect rect = baseRect;
	CGSize labelSize	= [label.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:label.font,NSFontAttributeName, nil]];

	rect.size.width		= labelSize.width;
	rect.size.height	= labelSize.height;
	rect.origin.y		= (baseRect.size.height-labelSize.height)/2;
	label.frame			= rect;

	rect.origin.x		= labelSize.width + 10;
	rect.size.height	= labelSize.height + 5;
	//rect.origin.y	   -= 5;
	rect.size.width     = baseRect.size.width - 20 - labelSize.width;

	textField.frame		= rect;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(void)textFieldDidBeginEditing:(UITextField*)aField{
	[feedbackDelegate baseNavigationItem].rightBarButtonItem = [[UIBarButtonItem alloc]
												initWithTitle:@"Done"
												style:UIBarButtonItemStyleDone
												target:self
												action:@selector(doneEditing:)];

}

-(void)textFieldDidEndEditing:(UITextField*)aField{
	[feedbackDelegate cellWasChanged:self];
}


-(void)doneEditing:(id)sender{
	[[self textField] resignFirstResponder];
	[feedbackDelegate cellWasChanged:self];
}

-(NSString*)text{
	return( [textField text] );
}
@end
