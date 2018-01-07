//  MIT Licence
//
//  Created on 19/03/2009.
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

#import "WebListViewController.h"
#import "RemoteDownloadList.h"
#import "RefreshProtocol.h"
#import "RZUtils/RZUtils.h"
#import "WebURLroznet.h"
#import "AppConstants.h"
#import "AppGlobals.h"

@interface WebListViewController ()
@property (nonatomic,strong) RemoteDownloadList * remoteList;
@property (nonatomic,strong) RemoteDownloadPackage * remotePackage;

@end

@implementation WebListViewController
@synthesize packages,code;
#pragma mark Init
-(WebListViewController*)init{
	if (!(self = [super init])) return nil;
	[self setCode:nil];
	return( self );
}

-(WebListViewController*)initWithCode:(NSString*)aCode{
	if (!(self = [super init])) return nil;
	[self setCode:aCode];
	return( self );
}

-(NSString*)packageProperty:(NSString*)aProperty atIndex:(NSUInteger)aIdx{
	NSDictionary * dict = [packages objectAtIndex:aIdx];
	return( [dict objectForKey:aProperty] );
}

#pragma mark UIViewController

-(void)loadView{
	[super loadView];
	activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [activityIndicator setCenter:CGPointMake(160.0f, 208.0f)];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
	[activityIndicator startAnimating];
	[[self view] addSubview:activityIndicator];
	// will be free by delegate methods
	NSMutableString * args = [NSMutableString stringWithString:@"packages"];
	if( [AppGlobals configGetBool:CONFIG_INCLUDE_UPLOAD defaultValue:TRUE] ){
		[args appendString:@"&upload"];
	}
	self.remoteList = [[RemoteDownloadList alloc] initWithURL:WebStandardURL(@"list.php", args, code) andDelegate:self];
}

#pragma mark RemoteDownloadDelegate

-(void)downloadFailed:(id)connection{
    if ([NSThread isMainThread]) {
        UIAlertController * ac = [UIAlertController simpleAlertWithTitle:@"Error" andMessage:@"Download Failed"];
        [self presentViewController:ac animated:YES completion:^(){}];
    }else{
        [self performSelectorOnMainThread:@selector(downloadFailed:) withObject:nil waitUntilDone:NO];
    }
}

-(void)processArray:(NSArray*)theArray{
    [self setPackages:theArray];
    NSMutableArray * data = [NSMutableArray arrayWithCapacity:[theArray count]];
    NSUInteger n = [theArray count];
    for( NSUInteger i=0;i<n;i++){
        [data addObject:[self packageProperty:@"name" atIndex:i]];
    }
    [self setDataArray:data];
    [self buildSearchArrayFrom:@""];
    [activityIndicator stopAnimating];

}


-(void)downloadArraySuccessful:(id)connection array:(NSArray*)theArray{
    [self performSelectorOnMainThread:@selector(processArray:) withObject:theArray waitUntilDone:NO];
}

-(void)downloadStringSuccessful:(id)connection string:(NSString*)theString{
    if ([NSThread isMainThread]) {
        UIAlertController * ac = [UIAlertController simpleAlertWithTitle:@"Error" andMessage:@"Download Failed"];
        [self presentViewController:ac animated:YES completion:^(){}];
    }else{
        [self performSelectorOnMainThread:@selector(downloadFailed:) withObject:nil waitUntilDone:NO];
    }

}


#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath{
	NSString * name = [searchArray objectAtIndex:[newIndexPath row]];
	int i = 0;
	for(i = 0; i< [packages count];i++){
		if( [[self packageProperty:@"name" atIndex:i] isEqualToString:name] ){
			break;
		}
	}
	int packid=[[self packageProperty:@"id" atIndex:i] intValue];
	self.remotePackage = [[RemoteDownloadPackage alloc] initForPackageId:packid andCode:code withDelegate:self];
	[activityIndicator startAnimating];
}

#pragma mark RemoteDownloadPackageDelegate

-(void)downloadPackageSuccessful:(id)connection package:(NSArray*)theArray{
	MacroOrganizer * organizer = [AppGlobals organizer];
	for( int i = 0;i<[theArray count];i++) {
		NSString* name = [[theArray objectAtIndex:i] objectForKey:@"name"];
		NSString* xml  = [[theArray objectAtIndex:i] objectForKey:@"xml"];

		[organizer addOrReplaceMacro:name definition:xml];
	}

	[activityIndicator stopAnimating];

	if( [[self navigationController] conformsToProtocol:@protocol(RefreshProtocol)] ){
		id<RefreshProtocol> refreshable = (id<RefreshProtocol>)[self navigationController];
		[refreshable refreshAfterDataChange];
	}

	[[self navigationController] popToRootViewControllerAnimated:YES];

}
-(void)downloadPackageFailed:(id)connection{
	[activityIndicator stopAnimating];
}


@end
