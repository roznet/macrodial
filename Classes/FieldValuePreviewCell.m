//
//  FieldValuePreviewCell.m
//  MacroDial
//
//  Created by brice on 03/03/2009.
//  Copyright 2009 ro-z.net. All rights reserved.
//

#import "FieldValuePreviewCell.h"

#import "AppGlobals.h"

@implementation FieldValuePreviewCell
@synthesize field,value,preview;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
		preview						= [[UILabel alloc] initWithFrame:CGRectZero];
		preview.textColor			= [UIColor lightGrayColor];
		preview.font				= [AppGlobals systemFontOfSize:12];
		preview.backgroundColor		= [UIColor clearColor];
		
		field						= [[UILabel alloc] initWithFrame:CGRectZero];
		field.backgroundColor		= [UIColor clearColor];
		field.font					= [AppGlobals boldSystemFontOfSize:16];
		field.textColor				= [UIColor blackColor];
		
		value						= [[UILabel alloc] initWithFrame:CGRectZero];
		value.backgroundColor		= [UIColor clearColor];
		value.font					= [AppGlobals systemFontOfSize:16];
		value.textColor				= [UIColor blueColor];
		
		[self.contentView addSubview:preview];
		[self.contentView addSubview:field];
		[self.contentView addSubview:value];
		
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	// Rect that start at 5 from left bound x
	CGRect baseRect = CGRectInset( self.contentView.bounds, 5, 0);
	CGRect rect = baseRect;
	CGSize fieldSize	= [field.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:field.font,NSFontAttributeName,nil]];
	CGSize previewSize	= [preview.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:preview.font,NSFontAttributeName, nil]];
	
	rect.size.width		= fieldSize.width;
	rect.size.height	= fieldSize.height;
	field.frame			= rect;
	
	if( [value.text length] > 0 ){
		rect.origin.x		+= fieldSize.width+3;
		rect.size.width		= baseRect.size.width-rect.origin.x-5;
		value.frame			= rect;
	}else{
		value.frame			= CGRectZero;
	}
	
	if( [[preview text] length] > 0 ){
		rect.size.width		= baseRect.size.width;
		rect.size.height	= previewSize.height;
		rect.origin.x		= baseRect.origin.x;
		rect.origin.y		= baseRect.origin.y+fieldSize.height;
		preview.frame		= rect;
	}else{
		preview.frame = CGRectZero;
	}
	

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
