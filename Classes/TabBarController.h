//  MIT Licence
//
//  Created on 16/02/2009.
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
#import "DialViewController.h"
#import "RecentViewController.h"
#import "ScheduleViewController.h"
#import "TabControllerProtocol.h"
#import "RefreshProtocol.h"
#import "ConfigViewController.h"

@import ContactsUI;

@interface TabBarController : UITabBarController <CNContactPickerDelegate,TabControllerProtocol,RefreshProtocol,UITabBarControllerDelegate>{
	DialViewController				*	dialViewController;
	CNContactPickerViewController   *	contactPickerViewController;
	RecentViewController			*   recentViewController;
	ConfigViewController			*   configViewController;
	ScheduleViewController			*   scheduleViewController;

}

@property (nonatomic,strong) DialViewController				*	dialViewController;
@property (nonatomic,strong) CNContactPickerViewController	*	contactPickerViewController;
@property (nonatomic,strong) RecentViewController			*	recentViewController;
@property (nonatomic,strong) ConfigViewController			*	configViewController;
@property (nonatomic,strong) ScheduleViewController			*   scheduleViewController;

-(void)loadFromDictionary:(NSMutableDictionary*)aDict;
-(void)saveToDictionary:(NSMutableDictionary*)aDict;

@end
