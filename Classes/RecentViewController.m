//  MIT Licence
//
//  Created on 22/02/2009.
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

#import "RecentViewController.h"
#import "AppGlobals.h"
#import "RZUtils/RZUtils.h"


@implementation RecentViewController
@synthesize recentCalls;

-(RecentViewController*)init{
	if (!(self = [super init])) return nil;

	recentCalls = [[RecentCallsDataSource alloc] init];

	return( self );
}

- (void)viewDidLoad {
    [super viewDidLoad];

	UITableView * tableView = (UITableView*)[self view];
	[[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Clear"
																					style:UIBarButtonItemStylePlain
																					target:self
																				  action:@selector(clear)]];

	[tableView setDelegate:recentCalls];
	[tableView setDataSource:recentCalls];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


-(void)reloadData{
	[recentCalls reloadCalls];
	UITableView * tableView = (UITableView*)[self view];
	[tableView reloadData];
}

-(void)clear{
    UIAlertController * ac = [UIAlertController simpleConfirmWithTitle:@"Clear Call History" message:@"Are you sure you want to delete your call history?" action:^(){
        [[AppGlobals organizer] clearCallRecords];
        [self reloadData];
    }];
    [self presentViewController:ac animated:YES completion:^(){}];
};


@end
