//  MIT Licence
//
//  Created on 06/09/2010.
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

#import "WebURLroznet.h"
#import "RZUtils/RZUtils.h"

static NSString * UrlRoot = @"https://www.ro-z.net/macrodial/iphone";

void WebUseTestServer(){
	UrlRoot = @"http://localhost/macrodial/iphone";
}

void WebUseProdServer(){
	UrlRoot = @"https://www.ro-z.net/macrodial/iphone";
}


NSString * WebStandardURL( NSString * script, NSString * args, NSString * code )
{
	NSMutableString * urlstr = [NSMutableString stringWithFormat:@"%@/%@?%@", UrlRoot, script, RZWebEncodeURL( args )];
	if( code ){
		[urlstr appendFormat:@"&code=%@", RZWebEncodeURL( code )];
	}
	return( urlstr );
}
