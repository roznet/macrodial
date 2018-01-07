//  MIT Licence
//
//  Created on 05/06/2009.
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

#import "RemoteDownloadLocation.h"
#import "AppConstants.h"


@implementation RemoteDownloadLocation


-(void)dataTaskDidFinishLoading:(NSData*)data response:(NSURLResponse*)response{
	// Special handling because yahoo zonetag returns APPTOKEN then the XML.
	NSString * received = [[NSString alloc] initWithData:data encoding:self.receivedEncoding];
	NSString * string = [received substringFromIndex:[APPTOKEN length]];
	NSXMLParser * parser = [[NSXMLParser alloc] initWithData:[string dataUsingEncoding:self.receivedEncoding]];

	[self setCurrentData:nil];
	[self setCurrentTag:nil];
	[self setDownloadedList:[NSMutableArray arrayWithCapacity:10]];
	[parser setDelegate:self];
	[parser parse];
	[self.downloadDelegate downloadArraySuccessful:self array:downloadedList];
}



#pragma mark XML parsing

-(BOOL)validTag:(NSString*)elementName{
	return( [elementName isEqualToString:@"location"] );
}

@end
