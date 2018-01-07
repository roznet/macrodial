//  MIT Licence
//
//  Created on 06/03/2009.
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

#import "RecentCallsDataSource.h"
#import "AppGlobals.h"
#import "AppConstants.h"
#import "FieldValuePreviewCell.h"
#import "RZUtils/RZUtils.h"



@implementation RecentCallsDataSource
@synthesize delegate,recentCalls;

-(RecentCallsDataSource*)init{
	if (!(self = [super init])) return nil;
	recentCalls = [[NSMutableArray alloc] initWithCapacity:20];
	[self reloadCalls];
	return( self );
}


-(void)reloadCalls{
	[self setRecentCalls:[[AppGlobals organizer] retrieveCallRecords]];
}

#pragma mark UITableTableDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [recentCalls count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	FieldValuePreviewCell *cell = (FieldValuePreviewCell*) [tableView dequeueReusableCellWithIdentifier:@"RecentCallCell"];
	if (!cell) cell = [[FieldValuePreviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RecentCallCell"];


	RecentCallRecord * record = (RecentCallRecord*)[recentCalls objectAtIndex:[indexPath row]];

	cell.field.text = [record contactName];
	cell.value.text = [record formattedCallTime];
	cell.value.textAlignment = NSTextAlignmentRight;
	if( [record phoneLabel] && [[record phoneLabel] length] ){
		cell.preview.text = [NSString stringWithFormat:@"%@ - %@", [record phoneLabel], [record macroName]];
	}else{
		cell.preview.text = [record macroName];
	}
	return cell;
}

#pragma mark UITableViewDelegateMethods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath
{
	RecentCallRecord * record = (RecentCallRecord*)[recentCalls objectAtIndex:[newIndexPath row]];
	[delegate updateForRecord:record];
	[AppGlobals selectTab:TAB_DIAL];
}



@end
