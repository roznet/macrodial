//  MIT Licence
//
//  Created on 03/04/2009.
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

#import "RemoteDownloadPackage.h"
#import "RemoteDownloadList.h"
#import "WebURLroznet.h"

@interface  RemoteDownloadPackage ()
@property (nonatomic,strong) RemoteDownloadList * remoteList;
@property (nonatomic,strong) RZRemoteDownload * remoteDownload;
@end

@implementation RemoteDownloadPackage
@synthesize list,downloadDelegate,code;


-(NSString*)listProperty:(NSString*)aProperty atIndex:(int)aIdx{
	return( [[list objectAtIndex:aIdx] objectForKey:aProperty] );
}

-(RemoteDownloadPackage*)initForPackageId:(int)aPId andCode:(NSString*)aCode withDelegate:(id<RemoteDownloadPackageDelegate>)aDelegate{
	if (!(self = [super init])) return nil;
	if( self){
		[self setCode:aCode];
		downloadDelegate = aDelegate;
		NSString * args = [NSString stringWithFormat:@"macros&pid=%d", aPId];
		// released in delegate func
		self.remoteList = [[RemoteDownloadList alloc] initWithURL:WebStandardURL(@"list.php", args, code) andDelegate:self];
	}
	return( self);
}

-(void)downloadNextMacro{
	if( list ){
		if( currentIndex < [list count] ){
			NSString * args = [NSString stringWithFormat:@"id=%d", [[self listProperty:@"id" atIndex:currentIndex] intValue]];
			self.remoteDownload = [[RZRemoteDownload alloc] initWithURL:WebStandardURL(@"download.php", args, code) andDelegate:self];
		}else{
			[downloadDelegate downloadPackageSuccessful:self package:list];
		}
	}else{
		[downloadDelegate downloadPackageFailed:self];
	}
}

#pragma mark RemoteDownloadDelegate

-(void)downloadFailed:(id)connection{
	[downloadDelegate downloadPackageFailed:self];
}

-(void)downloadArraySuccessful:(id)connection array:(NSArray*)theArray{
	[self setList:theArray];
	currentIndex = 0;
	[self downloadNextMacro];
}
-(void)downloadStringSuccessful:(id)connection string:(NSString*)theString{
	[(NSMutableDictionary*)[list objectAtIndex:currentIndex] setObject:theString forKey:@"xml"];
	currentIndex++;
	[self downloadNextMacro];
}

@end
