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

#import "TabBarController.h"
#import "DialViewController.h"
#import "NavigationControllerWithRefresh.h"
#import "RecentViewController.h"
#import "SetupWizardViewController.h"
#import "ConfigViewController.h"
#import "AppGlobals.h"
#import "AppConstants.h"

@implementation TabBarController
@synthesize dialViewController,contactPickerViewController,recentViewController,configViewController,scheduleViewController;

#pragma mark Initializations


-(void)loadFromDictionary:(NSMutableDictionary*)aDict{
	[dialViewController loadFromDictionary:aDict];
	NSString * selectedStr = [aDict objectForKey:CONFIG_SELECTEDTAB];
	if( selectedStr ){
		[self setSelectedIndex:[selectedStr intValue]];
	}
}
-(void)saveToDictionary:(NSMutableDictionary*)aDict{
	[dialViewController saveToDictionary:aDict];
	[aDict setValue:[NSNumber numberWithInteger:self.selectedIndex] forKey:CONFIG_SELECTEDTAB];
}

#pragma mark UIViewController Methods

-(void)loadView{
	[super loadView];

    contactPickerViewController = [[CNContactPickerViewController		alloc] init];
	dialViewController			= [[DialViewController				alloc] init];
	configViewController		= [[ConfigViewController			alloc] init];
	recentViewController		= [[RecentViewController			alloc] init];
	//scheduleViewController		= [[ScheduleViewController			alloc] init];

    contactPickerViewController.delegate = self;
	[[recentViewController recentCalls] setDelegate:dialViewController];
	[dialViewController setTabController:self];

	UIImage * contactIcon	= [UIImage imageNamed:@"779-users"];
	UIImage * dialIcon		= [UIImage imageNamed:@"839-mobile-phone"];
	UIImage * recentIcon	= [UIImage imageNamed:@"760-refresh-3"];
	UIImage * configIcon	= [UIImage imageNamed:@"742-wrench"];

	UITabBarItem * contactItem	= [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Contact",		@"")	image:contactIcon	tag:0];
	UITabBarItem * dialItem		= [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Dial",		@"")	image:dialIcon		tag:1];
	UITabBarItem * recentItem	= [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Recent",		@"")	image:recentIcon	tag:2];
	UITabBarItem * configItem	= [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Config",		@"")	image:configIcon	tag:3];

    UIViewController *      contactVC   = [[UIViewController alloc] init];
	UINavigationController *dialNav		= [[NavigationControllerWithRefresh alloc] initWithRootViewController:dialViewController];
	UINavigationController *configNav   = [[NavigationControllerWithRefresh alloc] initWithRootViewController:configViewController];
	UINavigationController *recentNav   = [[NavigationControllerWithRefresh alloc] initWithRootViewController:recentViewController];

	UIBarStyle style = UIBarStyleBlackOpaque;
	style = UIBarStyleDefault;

	dialNav.navigationBar.barStyle						= style;
	configNav.navigationBar.barStyle					= style;
	recentNav.navigationBar.barStyle					= style;

	contactVC.tabBarItem	= contactItem;
	dialNav.tabBarItem						= dialItem;
	recentNav.tabBarItem					= recentItem;
	configNav.tabBarItem					= configItem;

	[self view].autoresizesSubviews = YES;
	[self view].autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

    [self setViewControllers:[NSArray arrayWithObjects:contactVC,dialNav,recentNav,configNav,nil]];

	if( [AppGlobals configGetBool:CONFIG_FIRST_USE defaultValue:TRUE] ){
		[AppGlobals configSet:CONFIG_FIRST_USE boolVal:FALSE];
        [AppGlobals saveSettings];

		SetupWizardViewController * swc = [[SetupWizardViewController alloc] init];
		[configNav pushViewController:swc animated:TRUE];
		[self setSelectedIndex:TAB_CONFIG];
    }else{
        [self setSelectedIndex:TAB_DIAL];
    }
	[AppGlobals recordTime:@"loadView"];
}


#pragma mark ABPeoplePickerNavigationController Methods

-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
    NSString * firstName = contact.givenName;
    NSString * lastName  = contact.familyName;
    NSString * identifier = contact.identifier;

    NSArray * contactPhoneNumbers = contact.phoneNumbers;

    NSMutableArray * phoneNumbers = [NSMutableArray arrayWithCapacity:contactPhoneNumbers.count];
    NSMutableArray * phoneLabels  = [NSMutableArray arrayWithCapacity:contactPhoneNumbers.count];

    for (CNLabeledValue * lv in contactPhoneNumbers) {
        CNPhoneNumber * number = lv.value;
        [phoneNumbers addObject:number.stringValue];
        [phoneLabels addObject:[CNLabeledValue localizedStringForLabel:lv.label]];
    }

    [dialViewController updateContactData:phoneNumbers labels:phoneLabels firstname:firstName lastname:lastName recordId:identifier];
    [dialViewController phoneNumberChanged];
    [self setSelectedIndex:TAB_DIAL];

}

-(void)contactPickerDidCancel:(CNContactPickerViewController *)picker{
    [self setSelectedIndex:TAB_DIAL];
}
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if (item.tag==0 && self.viewControllers[0] != self.contactPickerViewController) {
        self.viewControllers[0].view.backgroundColor = [UIColor whiteColor];
        [self presentViewController:self.contactPickerViewController animated:YES completion:^(){}];
    }
}

// Handle a user's Cancel tap


#pragma mark TabControllerProtocol

-(void)selectTab:(int)t{
	[self setSelectedIndex:t];
}
-(void)callHistoryChanged{
	[recentViewController reloadData];
}

#pragma mark RefreshProtocol
-(void)refreshAfterDataChange{
	[dialViewController refreshAfterDataChange];
}

@end
