//  MIT Licence
//
//  Created on 04/03/2009.
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
#import	"MacroImpl.h"

@interface MacroImplHandler : NSObject {
	MacroImpl * implementor;
	BOOL dirty;
}
@property (nonatomic,strong) MacroImpl*implementor;
@property BOOL dirty;

-(MacroImplHandler*)initWithImplementor:(MacroImpl*)aImpl;
-(MacroImpl*)		implementorAtIndex:(NSUInteger)idx;
-(NSString*)		implementorExecuteOn:(NSString*)aNumber with:(NSDictionary*)aDict untilIndex:(NSUInteger)idx ;
-(NSUInteger)				implementorCount;

-(void)				deleteImplementorAt:(NSUInteger)idx;
-(void)				moveImplementorFrom:(NSUInteger)from to:(NSUInteger)to;
-(MacroImpl*)		extractImplementorAt:(NSUInteger)idx;
-(void)				insertImplementor:(MacroImpl*)aImpl atIndex:(NSUInteger)idx;
-(void)				appendImplementor:(MacroImpl*)aImpl;
-(void)				replaceImplementorAt:(NSUInteger)aIdx with:(MacroImpl*)aImpl;
-(void)				setArgumentImplementorAt:(NSUInteger)aIdx key:(NSString*)aKey value:(NSString*)aValue;

-(MacroImpl*)		createNewImplForType:(NSString*)aType;




@end
