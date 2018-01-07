//
//  FieldValuePreviewCell.h
//  MacroDial
//
//  Created by brice on 03/03/2009.
//  Copyright 2009 ro-z.net. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FieldValuePreviewCell : UITableViewCell {
	UILabel		*	field;
	UILabel		*	value;
	UILabel		*	preview;
}
@property (nonatomic,strong) UILabel	* field;
@property (nonatomic,strong) UILabel	* value;
@property (nonatomic,strong) UILabel	* preview;

@end
