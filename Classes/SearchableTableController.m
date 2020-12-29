//
//  SearchableTableController.m
//  MacroDial
//
//  Created by brice on 08/03/2009.
//  Copyright 2009 ro-z.net. All rights reserved.
//

#import "SearchableTableController.h"

@implementation SearchableTableController
@synthesize dataArray,search,searchArray;

- (void)loadView
{
	[super loadView];
	
	[self buildSearchArrayFrom:@""];
	
	search = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f, 44.0f)];
	search.barStyle					= UIBarStyleDefault;
	search.delegate					= self;
	search.autocorrectionType		= UITextAutocorrectionTypeNo;
	search.autocapitalizationType	= UITextAutocapitalizationTypeNone;
	self.navigationItem.titleView	= search;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
	UITextField *searchField = [[search subviews] lastObject];
	[searchField setReturnKeyType:UIReturnKeyDone];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [searchArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Any Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = RZReturnAutorelease([[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]);
    }
	[[cell textLabel] setText:[searchArray objectAtIndex:[indexPath row]]];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


#pragma mark SearchFunctions

- (void) buildSearchArrayFrom: (NSString *) matchString
{
	NSString *upString = [matchString uppercaseString];
	
	searchArray = [[NSMutableArray alloc] init];
	for (NSString *word in dataArray)
	{
		if ([matchString length] == 0)
		{
			[searchArray addObject:word];
			continue;
		}
		
		NSRange range = [[[[word componentsSeparatedByString:@" #"] objectAtIndex:0] uppercaseString] rangeOfString:upString];
		if (range.location != NSNotFound) [searchArray addObject:word];
	}
	[searchArray sortUsingSelector:@selector(compare:)];
	
	[self.tableView reloadData];
}

// When the search text changes, update the array
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	[self buildSearchArrayFrom:searchText];
	if ([searchText length] == 0) [searchBar resignFirstResponder];
}

// When the search button (i.e. "Done") is clicked, hide the keyboard
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}



@end

