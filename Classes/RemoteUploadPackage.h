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

#import <Foundation/Foundation.h>
#import "RZUtils/RZUtils.h"

@protocol RemoteUploadPackageDelegate
-(void)downloadPackageSuccessful:(id)connection;
-(void)downloadPackageFailed:(id)connection;
@end

@interface RemoteUploadPackage : NSObject<RZRemoteDownloadDelegate> {
	NSArray * macroNames;
	NSArray * macroXml;
	NSDictionary * basePostData;
	int currentIndex;
	id<RemoteUploadPackageDelegate> __weak uploadDelegate;
}
@property (nonatomic,strong) NSArray*macroNames;
@property (nonatomic,strong) NSArray*macroXml;
@property (nonatomic,strong) NSDictionary * basePostData;
@property (nonatomic,assign) int currentIndex;
@property (nonatomic,weak) id<RemoteUploadPackageDelegate> uploadDelegate;

-(RemoteUploadPackage*)initWithMacroNames:(NSArray*)aNamesArray macroXml:(NSArray*)aXmlArray basePost:(NSDictionary*)aDict
							  andDelegate:(id<RemoteUploadPackageDelegate>)aDeleg;

-(void)uploadNextMacro;

@end
