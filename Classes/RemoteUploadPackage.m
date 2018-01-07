//  MIT Licence
//
//  Created on 24/05/2009.
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

#import "RemoteUploadPackage.h"
#import "RZUtils/RZUtils.h"
#import "WebURLroznet.h"

@interface RemoteUploadPackage ()
@property (nonatomic,strong) RZRemoteDownload * remoteDownload;

@end

@implementation RemoteUploadPackage
@synthesize currentIndex;
@synthesize basePostData;
@synthesize macroNames;
@synthesize macroXml;
@synthesize uploadDelegate;

-(RemoteUploadPackage*)initWithMacroNames:(NSArray*)aNamesArray macroXml:(NSArray*)aXmlArray basePost:(NSDictionary*)aDict
							 andDelegate:(id<RemoteUploadPackageDelegate>)aDeleg{
	if (!(self = [super init])) return nil;
	if( self ){
		[self setBasePostData:aDict];
		[self setMacroNames:aNamesArray];
		[self setMacroXml:aXmlArray];
		[self setUploadDelegate:aDeleg];
		currentIndex = 0;
		[self uploadNextMacro];
	}
	return( self );
}

-(void)uploadNextMacro{
	if( currentIndex < [macroNames count] && currentIndex < [macroXml count] ){
		NSMutableDictionary * postData = [NSMutableDictionary dictionaryWithDictionary:basePostData];

		[postData setObject:[macroNames objectAtIndex:currentIndex] forKey:@"macro_name"];
		[postData setObject:[macroXml objectAtIndex:currentIndex] forKey:@"macro_xml"];

		self.remoteDownload = [[RZRemoteDownload alloc] initWithURL:WebStandardURL(@"upload.php", @"", nil) postData:postData andDelegate:self];
	}else{
		[uploadDelegate downloadPackageSuccessful:self];
	}
}

#pragma mark RemoteDownloadDelegate

-(void)downloadFailed:(id)connection{
	[uploadDelegate downloadPackageFailed:self];
}

-(void)downloadArraySuccessful:(id)connection array:(NSArray*)theArray{
	[uploadDelegate downloadPackageFailed:self];
}
-(void)downloadStringSuccessful:(id)connection string:(NSString*)theString{
	currentIndex++;
	[self uploadNextMacro];
}


@end
