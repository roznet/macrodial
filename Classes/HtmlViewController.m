//  MIT Licence
//
//  Created on 30/05/2009.
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

#import "HtmlViewController.h"

@implementation HtmlViewController
@synthesize filePath;
@synthesize contentDelegate;

-(HtmlViewController*)initWithDelegate:(id<HtmlViewControllerDelegate>)aDelegate{
	if (!(self = [super init])) return nil;
	if( self ){
		contentDelegate = aDelegate;
		filePath = nil;
	}
	return( self );
}

-(HtmlViewController*)initWithFile:(NSString*)aFile{
	if (!(self = [super init])) return nil;
	if( self ){
		contentDelegate = nil;
		[self setFilePath:aFile];
	}
	return( self );
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIWebView *contentView	= [[UIWebView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];

	if( contentDelegate ){
		NSString * content = [contentDelegate htmlContentString];
		[contentView loadHTMLString:content  baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
	}else{
		NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:[RZFileOrganizer bundleFilePath:filePath]];
		NSURLRequest *req = [NSURLRequest requestWithURL:fileURL];
		[contentView loadRequest:req];
	};
	//[contentView setScalesPageToFit:YES];

	[self setView:contentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


@end
