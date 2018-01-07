//  MIT Licence
//
//  Created on 16/02/2009.
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

#import "ContactTableDataSource.h"
#import "FieldValuePreviewCell.h"


@implementation ContactTableDataSource
@synthesize allPhoneNumbers;
@synthesize allPhoneLabels;
@synthesize selectedIndex;
@synthesize delegate;
@synthesize firstName;
@synthesize lastName;
@synthesize recordId;


-(CGFloat)useFontSize{
	CGFloat rv = 20.0;
	if( [allPhoneLabels count] < 3 ){
		rv = 20.0;
	}
	return( rv );
}
-(CGFloat)useCellHeight{
	CGFloat rv = 30.0;
	if( [allPhoneLabels count] < 3 ){
		rv = 30.0;
	}
	return( rv );

}

#pragma mark UITableTableDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [allPhoneNumbers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	FieldValuePreviewCell *cell = (FieldValuePreviewCell*)[tableView dequeueReusableCellWithIdentifier:@"PhoneCell"];
	if (!cell) cell = [[FieldValuePreviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PhoneCell"];

	// Set up the cell's text
	NSUInteger	r		= [indexPath		row];
	NSString *	label	= [allPhoneLabels	objectAtIndex:r];
	NSString *	number	= [allPhoneNumbers	objectAtIndex:r];

	[cell.field setText:label];
	[cell.value setText:number];
	[cell.value setTextAlignment:NSTextAlignmentRight];
	[cell.value setTextColor:[UIColor blackColor]];

	return cell;
}

#pragma mark UITableViewDelegateMethods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath
{
	selectedIndex = [newIndexPath row];
	[delegate phoneNumberChanged];
}

-(NSString*)contactName{
	BOOL vfn = firstName && ( [ firstName length] > 0 );
	BOOL vln = lastName  && ( [ lastName  length] > 0 );

	if( vfn && vln ){
		return( [NSString stringWithFormat:@"%@ %@", firstName, lastName] );
	}else if( vfn ){
		return( [NSString stringWithFormat:@"%@", firstName] );
	}else if( vln ){
		return( [NSString stringWithFormat:@"%@", lastName] );
	}
	return( @"" );
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return( [self useCellHeight] );
}

-(NSString*)selectedNumber{
	return( [[self allPhoneNumbers] objectAtIndex:[self selectedIndex]] );
}

-(NSString*)phoneLabel{
	if( [self selectedIndex] < [allPhoneLabels count] ){
		return( [[self allPhoneLabels] objectAtIndex:[self selectedIndex]] );
	}else{
		return( @"" );
	}

}

@end
