//  MIT Licence
//
//  Created on 28/05/2009.
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

#import <UIKit/UIKit.h>

@protocol MacroListPickerDelegate

-(NSArray*)obtainNames;
-(NSMutableArray*)obtainStatuses;
-(void)refreshStatuses:(NSMutableArray*)aStatuses;

@end


@interface MacroListPickerViewController : UITableViewController {
	NSArray * names;
	NSMutableArray * selectionStatuses;
	id<MacroListPickerDelegate> __weak refreshDelegate;

}
@property (nonatomic,strong) NSArray * names;
@property (nonatomic,strong) NSMutableArray * selectionStatuses;
@property (nonatomic,weak) id<MacroListPickerDelegate> refreshDelegate;

-(MacroListPickerViewController*)initWithDelegate:(id<MacroListPickerDelegate>)aDelegate;


@end
