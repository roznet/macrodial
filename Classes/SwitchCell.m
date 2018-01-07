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

#import "SwitchCell.h"
#import "AppGlobals.h"

@implementation SwitchCell
@synthesize label,toggle;

- (id)initWithStyle:(UITableViewCellStyle)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:frame reuseIdentifier:reuseIdentifier]) {

		label						= [[UILabel alloc] initWithFrame:CGRectZero];
		label.backgroundColor		= [UIColor clearColor];
		label.font					= [AppGlobals boldSystemFontOfSize:16];
		label.textColor				= [UIColor blackColor];

		toggle						= [[UISwitch alloc] initWithFrame:CGRectZero];
		[toggle addTarget:self action:@selector(switchElement:) forControlEvents:UIControlEventValueChanged];

		[self.contentView addSubview:label];
		[self.contentView addSubview:toggle];

    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	// Rect that start at 5 from left bound x
	CGRect baseRect = CGRectInset( self.contentView.bounds, 5, 0);
	CGRect rect = baseRect;
	int toggleWidth = 100;
	CGRect toggleRect = CGRectMake(5, 5, toggleWidth, 28);

	rect.size.width		= baseRect.size.width-toggleWidth;
	rect.origin.x		= toggleWidth+10;

	label.frame			= rect;
	toggle.frame		= toggleRect;
}

-(void)switchElement:(id)sender{
	[feedbackDelegate cellWasChanged:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
