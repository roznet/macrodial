//
//  SearchableTableController.h
//  MacroDial
//
//  Created by brice on 08/03/2009.
//  Copyright 2009 ro-z.net. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SearchableTableController : UITableViewController<UISearchBarDelegate> {
	NSMutableArray * dataArray;
	NSMutableArray * searchArray;
	UISearchBar *search;
}
@property	(nonatomic,strong)	NSMutableArray	*	dataArray;
@property	(nonatomic,strong)	NSMutableArray	*	searchArray;
@property	(nonatomic,strong)	UISearchBar		*	search;

- (void) buildSearchArrayFrom: (NSString *) matchString;
@end
