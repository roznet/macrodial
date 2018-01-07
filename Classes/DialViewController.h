//  MIT Licence
//
//  Created on 12/02/2009.
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
#import "MacroTableDataSource.h"
#import "ContactTableDataSource.h"
#import "DialControllerProtocol.h"
#import "TabControllerProtocol.h"
#import "PhoneNumberInfo.h"
#import "RefreshProtocol.h"


@interface UndoState : NSObject
{
	NSString *	phoneNumber;
	int			currentState;
}
@property (nonatomic,strong) NSString * phoneNumber;
@property (nonatomic,assign) int		currentState;

+(UndoState*)undoStateWithNumber:(NSString*)aNumber andState:(int)aState;
-(UndoState*)initWithNumber:(NSString*)aNumber andState:(int)aState;

@end


@interface DialViewController : UIViewController <DialControllerProtocol, UITextFieldDelegate,RefreshProtocol> {
	id<TabControllerProtocol> tabController;

	// Data
	MacroTableDataSource	*	macroTableDataSource;
	ContactTableDataSource	*	contactTableDataSource;
	RecentCallRecord		*   callRecord;

	//UIViews
	UILabel					*	contactNameLabel;
	UIButton				*   infoButton;
	UITextField				*	phoneNumberField;
	UITableView				*	contactTableView;
	UITableView				*   macroTableView;
	UIButton				*	callButton;
	UIButton				*   smsButton;

	// States
	int							currentState;
	int							currentInfo;
	PhoneNumberInfo			*   phoneInfo;

	NSMutableArray		    *   undoStates;
}
@property (nonatomic,strong) MacroTableDataSource	*	macroTableDataSource;
@property (nonatomic,strong) ContactTableDataSource	*	contactTableDataSource;
@property (nonatomic,strong) UILabel				*	contactNameLabel;
@property (nonatomic,strong) UIButton				*   infoButton;
@property (nonatomic,strong) UITextField			*	phoneNumberField;
@property (nonatomic,strong) UITableView			*	contactTableView;
@property (nonatomic,strong) UITableView			*	macroTableView;
@property (nonatomic,strong) UIButton				*	callButton;
@property (nonatomic,strong) UIButton				*	smsButton;
@property					 int						currentState;
@property					 int						currentInfo;
@property (nonatomic,strong) id<TabControllerProtocol>  tabController;
@property (nonatomic,strong) RecentCallRecord		*	callRecord;
@property (nonatomic,strong) PhoneNumberInfo		*	phoneInfo;
@property (nonatomic,strong) NSMutableArray			*   undoStates;

-(void)updateContactDataFromId:(NSString*)aId;
-(void)updateContactData:(NSArray*)phoneNumbers labels:(NSArray*)phoneLabels
						firstname:(NSString*)fn lastname:(NSString*)ln recordId:(NSString*)aId;
-(void)autoLearn;
-(void)displayInfo;


// ---- DialControllerProtocol ----

-(void)macroSelected;		// macro was selected, execute it.
-(void)phoneNumberChanged;	// update phone number to current contact selected number. Set state to original and establish links
-(void)refreshAll;			// refresh all

-(void)macroAccessorySelected;
-(void)saveToDictionary:(NSMutableDictionary*)aDict;
-(void)loadFromDictionary:(NSMutableDictionary*)aDict;

// ----- Undo
-(void)recordUndoState;
-(void)displayUndoButton;
-(void)undo;
-(NSString*)previousNumber;
@end
