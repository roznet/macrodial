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

#import <Foundation/Foundation.h>

@protocol RemoteDownloadPackageDelegate
-(void)downloadPackageSuccessful:(id)connection package:(NSArray*)theArray;
-(void)downloadPackageFailed:(id)connection;
@end

@interface RemoteDownloadPackage : NSObject<RZRemoteDownloadDelegate>{
	NSArray * list;
	NSString * code;
	int currentIndex;
	id<RemoteDownloadPackageDelegate> __weak downloadDelegate;
}
@property (nonatomic,strong) NSArray * list;
@property (nonatomic,weak) id<RemoteDownloadPackageDelegate> downloadDelegate;
@property (nonatomic,strong) NSString * code;

-(RemoteDownloadPackage*)initForPackageId:(int)aPId andCode:(NSString*)aCode withDelegate:(id<RemoteDownloadPackageDelegate>)aDelegate;
-(NSString*)listProperty:(NSString*)aProperty atIndex:(int)aIdx;

@end
