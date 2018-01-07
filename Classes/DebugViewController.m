//  MIT Licence
//
//  Created on 28/06/2009.
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

#import "DebugViewController.h"
#import "FieldValuePreviewCell.h"
#import "DebugUsageViewController.h"
#import "DebugDictArrayViewController.h"
#import "AppGlobals.h"
#import "AppConstants.h"

#define DBGV_SEC_INFO	0
#define DBGV_SEC_LOC	1
#define DBGV_SEC_END	2

#define DBGV_INFO_LOC	0
#define DBGV_INFO_USG	1
#define DBGV_INFO_DICT  2
#define DBGV_INFO_END	3


@implementation DebugViewController
@synthesize sampleLocations;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

-(void)refresh{
	[[self tableView] reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	UIBarButtonItem * button = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = button;

	CLLocation * l_niseko			= [[CLLocation alloc] initWithLatitude:42.82	longitude:140.67];
	CLLocation * l_repulsebay		= [[CLLocation alloc] initWithLatitude:22.24	longitude:114.2];
	CLLocation * l_cheungkong		= [[CLLocation alloc] initWithLatitude:22.28	longitude:114.16];
	CLLocation * l_85broad			= [[CLLocation alloc] initWithLatitude:40.7		longitude:-74.01];
	CLLocation * l_cupertino		= [[CLLocation alloc] initWithLatitude:37.32	longitude:-122.04];
	CLLocation * l_paris			= [[CLLocation alloc] initWithLatitude:48.87	longitude:2.35];
	CLLocation * l_shenzhen			= [[CLLocation alloc] initWithLatitude:22.55	longitude:114.06];
	CLLocation * l_roppongihills	= [[CLLocation alloc] initWithLatitude:35.66	longitude:139.73];
	CLLocation * l_hkg				= [[CLLocation alloc] initWithLatitude:22.27	longitude:114.18];

	[self setSampleLocations:[NSArray arrayWithObjects:		@"Niseko",		l_niseko,
							  @"RepulseBay",	l_repulsebay,	@"CheungKong",	l_cheungkong,
							  @"85Broad",		l_85broad,		@"Cupertino",	l_cupertino,
							  @"Paris",		l_paris,		@"shenzhen",	l_shenzhen,
							  @"Tokyo",		l_roppongihills,@"Hkg",			l_hkg,
							  nil] ];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}
/*
- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}
*/
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return DBGV_SEC_END;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case DBGV_SEC_INFO:
			return( DBGV_INFO_END);
			break;
		case DBGV_SEC_LOC:
			return( [sampleLocations count]/2 );
			break;

		default:
			break;

	}
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"FieldValueCell";

    FieldValuePreviewCell *cell = (FieldValuePreviewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FieldValuePreviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

	if( [indexPath section] == DBGV_SEC_INFO ){
		switch ([indexPath row]) {
			case DBGV_INFO_LOC:
				[[cell field] setText:[NSString stringWithFormat:@"Lat:%f Long:%f",
									   [AppGlobals configGetDouble:CONFIG_LAST_LATITUDE  defaultValue:0.0],
									   [AppGlobals configGetDouble:CONFIG_LAST_LONGITUDE defaultValue:0.0]]];
				[[cell preview] setText:[[[AppGlobals settings] objectForKey:CONFIG_LAST_LOC_TIME] description]];
				break;
			case DBGV_INFO_USG:
				[[cell field] setText:@"Usage order"];
				[[cell preview] setText:@""];
				break;
			case DBGV_INFO_DICT:
				[[cell field] setText:@"Debug Data"];
				[[cell preview] setText:@""];
				break;
			default:
				break;
		}
	}else if( [indexPath section] == DBGV_SEC_LOC ){
		NSUInteger i_name = [indexPath row]*2;

		[[cell field] setText:[sampleLocations objectAtIndex:i_name]];
		CLLocation * loc = (CLLocation*)[sampleLocations objectAtIndex:i_name+1];
		[[cell preview] setText:[NSString stringWithFormat:@"Distance: %.3f", [[AppGlobals lastLocation] distanceFromLocation:loc]/1000]];
	}

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];

	if( [indexPath section] == DBGV_SEC_LOC ){
		NSUInteger i = [indexPath row] * 2 +1;
		CLLocation * locat  = (CLLocation*)[sampleLocations objectAtIndex:i];
		CLLocationCoordinate2D loc = [locat coordinate];
		NSNumber * longitude = [NSNumber numberWithDouble:loc.longitude];
		NSNumber * latitude  = [NSNumber numberWithDouble:loc.latitude];

		[[AppGlobals settings] setObject:latitude		forKey:CONFIG_LAST_LATITUDE];
		[[AppGlobals settings] setObject:longitude		forKey:CONFIG_LAST_LONGITUDE];
		[[AppGlobals settings] setObject:[NSDate date]	forKey:CONFIG_LAST_LOC_TIME];
		[self performSelector:@selector(deselectRow:)	withObject:indexPath afterDelay:0.2f];
	}
	else if( [indexPath section] == DBGV_SEC_INFO ){
		if( [indexPath row] == DBGV_INFO_USG ){
			DebugUsageViewController * duv = [[DebugUsageViewController alloc] init];
			[self.navigationController pushViewController:duv animated:YES];
		}else if( [indexPath row] == DBGV_INFO_DICT ){
			DebugDictArrayViewController * dav = [[DebugDictArrayViewController alloc] initWithStyle:UITableViewStyleGrouped];
			[dav setData:[NSArray arrayWithObjects:[[AppGlobals timer] timerRecord], [AppGlobals settings],nil]];
			[self.navigationController pushViewController:dav animated:YES];
		}
	}
}

- (void) deselectRow: (id) indexPath
{
	[[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
	[self refresh];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/




@end

