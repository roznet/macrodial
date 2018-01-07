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

#import "DialViewController.h"
#import "PhoneNumber.h"
#import "MacroXMLParser.h"
#import "MacroVariablesViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "AppGlobals.h"
#import "MacroEditViewController.h"
#import "MacroAutoLearner.h"
#import "MacroNameViewController.h"
#import "RecentCallRecord.h"
#import "AppConstants.h"
#import <RZUtils/RZUtils.h>

@import Contacts;

@implementation UndoState
@synthesize phoneNumber;
@synthesize currentState;

+(UndoState*)undoStateWithNumber:(NSString *)aNumber andState:(int)aState{
	return( [[UndoState alloc] initWithNumber:aNumber andState:aState] );
}

-(UndoState*)initWithNumber:(NSString*)aNumber andState:(int)aState{
	self = [super init];
	if( self ){
		[self setPhoneNumber:aNumber];
		currentState = aState;
	}
	return( self );
}


@end


@implementation DialViewController

@synthesize macroTableDataSource;
@synthesize contactTableDataSource;
@synthesize contactNameLabel;
@synthesize phoneNumberField;
@synthesize macroTableView;
@synthesize contactTableView;
@synthesize callButton;
@synthesize currentState;
@synthesize tabController;
@synthesize callRecord;
@synthesize infoButton;
@synthesize currentInfo;
@synthesize smsButton;
@synthesize phoneInfo;
@synthesize undoStates;

#pragma mark Initializations

/**************************
 *	Initializations/Setup
 */

-(DialViewController*)init{
	self = [super init];
	if( self != nil ){
		macroTableDataSource	= [[MacroTableDataSource	alloc] init];
		contactTableDataSource	= [[ContactTableDataSource	alloc] init];
		[macroTableDataSource	setDelegate:self];
		[contactTableDataSource setDelegate:self];
		callRecord = [[RecentCallRecord alloc] init];
		undoStates = [[NSMutableArray alloc] init];

	};

	return( self );
}


// Load Dictionary is executed when init is done.
// Can be before the UI fields are done
-(void)loadFromDictionary:(NSMutableDictionary*)aDict{
	[self updateContactData:		[aDict objectForKey:@"phonenumbers"]
						labels:		[aDict objectForKey:@"phonelabels"]
						firstname:	[aDict objectForKey:@"firstname"]
						lastname:	[aDict objectForKey:@"lastname"]
						recordId:	[aDict objectForKey:@"recordid"]
	];
	[contactTableDataSource setSelectedIndex:[[aDict objectForKey:@"selectedindex"] intValue]];
	[phoneNumberField setText:[aDict objectForKey:@"phonenumber"]];
	[callRecord setCallNumber:[aDict objectForKey:@"phonenumber"]];
	[self setCurrentState:[[aDict objectForKey:@"dialviewstate"] intValue]];
	[macroTableDataSource setSelectedMacro:[[aDict objectForKey:@"selectedmacro"] intValue]];
	if( [aDict objectForKey:@"info_number"] ){
		[self setPhoneInfo:[[AppGlobals info] infoForNumber:[aDict objectForKey:@"info_number"]]];
	}
}

-(void)saveToDictionary:(NSMutableDictionary*)aDict{
	[aDict setValue:[phoneNumberField		text]									forKey:@"phonenumber"	];
	[aDict setValue:[contactTableDataSource	firstName]								forKey:@"firstname"		];
	[aDict setValue:[contactTableDataSource	lastName]								forKey:@"lastname"		];
	[aDict setValue:[contactTableDataSource allPhoneLabels]							forKey:@"phonelabels"	];
	[aDict setValue:[contactTableDataSource allPhoneNumbers]						forKey:@"phonenumbers"	];
	[aDict setValue:[contactTableDataSource recordId]                               forKey:@"recordid"		];
	[aDict setValue:[NSNumber numberWithInteger:[contactTableDataSource selectedIndex]] forKey:@"selectedindex"	];
	[aDict setValue:[NSNumber numberWithInt:currentState]							forKey:@"dialviewstate"	];
	[aDict setValue:@([macroTableDataSource selectedMacro])	forKey:@"selectedmacro" ];
	if( [phoneInfo number] ){
		[aDict setValue:[phoneInfo number]											forKey:@"info_number"];
	}
}

/*******************************************************/
#pragma mark ViewController Functions


-(void)viewDidLoad{
    [super viewDidLoad];

	PROFILE_START();

	macroTableView = [[UITableView alloc] initWithFrame:CGRectZero style: UITableViewStylePlain];

	[macroTableView setDelegate:macroTableDataSource];
	[macroTableView setDataSource:macroTableDataSource];
	[macroTableView setAllowsSelection:TRUE];

	contactTableView = [[UITableView alloc] initWithFrame:CGRectZero style: UITableViewStylePlain];
	[contactTableView setDelegate:contactTableDataSource];
	[contactTableView setDataSource:contactTableDataSource];

	phoneNumberField = [ [UITextField alloc] initWithFrame:CGRectZero];
	phoneNumberField.borderStyle		= UITextBorderStyleRoundedRect;
	phoneNumberField.placeholder		= NSLocalizedString( @"Enter Phone Number", @"" );;
	phoneNumberField.keyboardType		= UIKeyboardTypePhonePad;
	phoneNumberField.delegate			= self;
	phoneNumberField.adjustsFontSizeToFitWidth=true;
	[phoneNumberField setText:[callRecord callNumber]];

	UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    button.contentVerticalAlignment		= UIControlContentVerticalAlignmentCenter;
    button.contentHorizontalAlignment	= UIControlContentHorizontalAlignmentCenter;
    [button setTitle:NSLocalizedString( @"Call", @"" ) forState:UIControlStateNormal	];
    [button setTitle:NSLocalizedString( @"Call", @"" ) forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button setTitleColor:[AppGlobals backgroundColor] forState:UIControlStateHighlighted];
    [[button titleLabel] setFont:[AppGlobals boldSystemFontOfSize:20.0f]];
	[button addTarget:self action:@selector(initiateCall:) forControlEvents:UIControlEventTouchUpInside];
	[self setCallButton:button];

	button = [[UIButton alloc] initWithFrame:CGRectZero];
	currentInfo = 0;
	button.contentVerticalAlignment		= UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment	= UIControlContentHorizontalAlignmentCenter;
	[button setTitle:@"" forState:UIControlStateNormal	];
	[button setTitle:@"" forState:UIControlStateHighlighted];
	[[button titleLabel] setFont:[AppGlobals boldSystemFontOfSize:12.0f]];
	[[button titleLabel] setLineBreakMode:NSLineBreakByCharWrapping];
	[button  setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(switchInfo:) forControlEvents:UIControlEventTouchUpInside];
	[self setInfoButton:button];

	button = [[UIButton alloc] initWithFrame:CGRectZero];
	button.contentVerticalAlignment		= UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment	= UIControlContentHorizontalAlignmentCenter;
	[button setTitle:NSLocalizedString( @"SMS", @"" ) forState:UIControlStateNormal	];
	[button setTitle:NSLocalizedString( @"SMS", @"" ) forState:UIControlStateHighlighted];
	[button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
	[button setTitleColor:[AppGlobals backgroundColor] forState:UIControlStateHighlighted];
	[[button titleLabel] setFont:[AppGlobals boldSystemFontOfSize:20.0f]];
	[button addTarget:self action:@selector(initiateCall:) forControlEvents:UIControlEventTouchUpInside];
	[self setSmsButton:button];

    UIView *contentView				= self.view;
    contentView.backgroundColor		=  [AppGlobals backgroundColor];
    contentView.autoresizesSubviews = NO;
    contentView.autoresizingMask	= (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);


	[contentView addSubview:macroTableView];
	[contentView addSubview:contactTableView];
	[contentView addSubview:phoneNumberField];
	[contentView addSubview:callButton];
	[contentView addSubview:infoButton];
	[contentView addSubview:smsButton];

    [self setupFrames];

	PROFILE_STOP( @"loadView:total" );

	[self refreshAll];

}

-(void)setupFrames{

    CGRect rect = self.view.frame;

    CGRect navBar = self.navigationController.navigationBar.frame;
    CGRect tabBar = self.tabBarController.tabBar.frame;

    CGFloat starty = navBar.size.height + navBar.origin.y;
    CGFloat endy = rect.size.height - tabBar.size.height;

    CGFloat height = endy-starty;

    CGFloat vMargin = 5.;
    CGFloat hMargin = 5.;

    CGFloat wFull =  rect.size.width;

    CGFloat width = wFull - (2.*hMargin);
    CGFloat wHalf =  wFull/2. - (2.*hMargin);

    CGFloat hButtons =	30.0;

    CGFloat hTables = height - 2.*hButtons-4.*hMargin;

    CGFloat hContactTable =  hTables/2.-hMargin;
    CGFloat hMacroTable	=  hTables/2.-hMargin;

    CGFloat xLeft =	 vMargin;
    CGFloat xRight =  wHalf+vMargin;

    CGFloat yPhone              = starty+ vMargin;
    CGFloat yButtons			= yPhone + hButtons + vMargin;
    CGFloat yContactTable		= yButtons + hButtons + hMargin;
    CGFloat yMacroTable			= yContactTable + hContactTable + hMargin;

    phoneNumberField.frame = CGRectMake( xLeft, yPhone, width, hButtons );

    callButton.frame = CGRectMake( xRight, yButtons,	wHalf, hButtons	);
    infoButton.frame = CGRectMake( xLeft,  yButtons,	wHalf, hButtons	);
    smsButton.frame = infoButton.frame;

    macroTableView.frame   = CGRectMake( xLeft,	yMacroTable,		width, hMacroTable			);
    contactTableView.frame = CGRectMake( xLeft,	yContactTable,		width, hContactTable		);

    if( [AppGlobals configGetInt:CONFIG_LEFTBUTTON defaultValue:LEFTBUTTON_INFO] == LEFTBUTTON_INFO ){
        [infoButton setAlpha:1.0];
        [smsButton	setAlpha:0.0];
    }else{
        [infoButton setAlpha:0.0];
        [smsButton	setAlpha:1.0];
    }

}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self setupFrames];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


#pragma mark UITextFieldDelegate Functions

-(void)textFieldDidBeginEditing:(UITextField*)aField{
	[self recordUndoState];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
											   initWithTitle:@"Done"
											   style:UIBarButtonItemStyleDone
											   target:self
											   action:@selector(doneEditing:)];

	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
											   initWithTitle:@"Cancel"
											   style:UIBarButtonItemStyleDone
											   target:self
											   action:@selector(cancelEditing:)];

}

-(void)cancelEditing:(id)sender{
	[phoneNumberField resignFirstResponder];
	self.navigationItem.rightBarButtonItem = NULL;
	self.navigationItem.leftBarButtonItem = NULL;
	[self undo];
}
-(void)doneEditing:(id)sender{
	[phoneNumberField resignFirstResponder];
	self.navigationItem.leftBarButtonItem = NULL;
	self.navigationItem.rightBarButtonItem = NULL;
	if( ! [[phoneNumberField text] isEqualToString:[self previousNumber]] ){
		currentState = STATE_CUSTOM_EDIT;
	}
	if( [[phoneNumberField text] isEqualToString:@"+852690782990"] ){
		[AppGlobals configToggleBool:CONFIG_DEBUG];
		[AppGlobals recordEvent:RECORDEVENT_DEBUG every:RECORDEVENT_STEP_EVERY];
	}else if( currentState == STATE_CUSTOM_EDIT && [AppGlobals configGetBool:CONFIG_AUTOLEARN defaultValue:TRUE] ){
		[self autoLearn];
	}
	[self displayUndoButton];
}


#pragma mark Info

-(void)displayInfo{
	if( phoneInfo ){
		NSMutableArray * infos = [phoneInfo info];
		size_t i = (currentInfo % ([infos count]/2))*2;
		NSString * s_top	= [infos objectAtIndex:i];
		NSString * s_bottom = [infos objectAtIndex:i+1];
		NSString * title = [NSString stringWithFormat:@"%@\n%@", s_top, s_bottom];
		[infoButton setTitle:title forState:UIControlStateNormal	];
		[infoButton setTitle:title forState:UIControlStateHighlighted];
	}
}

- (void) switchInfo:(UIButton*)button;
{
	currentInfo++;
	[self displayInfo];

}

#pragma mark Calls and learning

- (void) initiateCall:(UIButton*)aButton;
{

	[callRecord setCallNumber:[phoneNumberField text]];
	[callRecord setContactId:[contactTableDataSource recordId]];
	[callRecord setContactName:[contactTableDataSource contactName]];
	[callRecord setPhoneLabel:[contactTableDataSource phoneLabel]];
	[callRecord setLocation:[AppGlobals lastLocation]];
	[callRecord setCallTime:[NSDate date]];

	NSUInteger idx = INVALID_MACRO_ID; // unsigned -1 -> MAXINT

	switch (currentState) {
		case STATE_MACRO_EXECUTED:
			idx = [macroTableDataSource selectedMacro];
			[AppGlobals recordEvent:RECORDEVENT_CALLWMACRO10 every:10];
			[AppGlobals recordEvent:RECORDEVENT_CALLWMACRO   every:RECORDEVENT_STEP_FIRSTONLY];
			[callRecord setMacroName:[macroTableDataSource selectedMacroName]];
			break;
		case STATE_ORIGINAL_NUMBER:
			[AppGlobals recordEvent:RECORDEVENT_CALLWORIGINAL10 every:10];
			[AppGlobals recordEvent:RECORDEVENT_CALLWORIGINAL   every:RECORDEVENT_STEP_FIRSTONLY];
			[callRecord setMacroName:@"Contact Number"];
			break;
		case STATE_CUSTOM_EDIT:
			[AppGlobals recordEvent:RECORDEVENT_CALLWEDIT10 every:10];
			[AppGlobals recordEvent:RECORDEVENT_CALLWEDIT   every:RECORDEVENT_STEP_FIRSTONLY];
			[callRecord setMacroName:@"Custom"];
			break;
	}

	if( currentState == STATE_MACRO_EXECUTED ){
		[[AppGlobals organizer] macroRecordUse:idx forRecord:callRecord];
	}

	[[AppGlobals organizer] saveCallRecord:callRecord];

	NSString * urlFmt = @"tel:%@";
	if( aButton == smsButton ){
		[AppGlobals recordEvent:RECORDEVENT_SMS every:RECORDEVENT_STEP_FIRSTONLY];
		[AppGlobals recordEvent:RECORDEVENT_SMS10 every:10];
		urlFmt = @"sms:%@";
	}

	NSURL *url = [ NSURL URLWithString:[NSString stringWithFormat:urlFmt, [phoneNumberField text] ] ];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
	[tabController callHistoryChanged];
}

-(void)autoLearn{
	MacroAutoLearner * learner = [[MacroAutoLearner alloc] init];
	//FIX me, what if no selected number?
	MacroImpl * impl = [learner implementorFor:[phoneNumberField text] from:[contactTableDataSource selectedNumber]];
	if( impl ){

        UIAlertController * ac = [UIAlertController simpleConfirmWithTitle:@"Auto Learn Macro"
                                                                   message:@"New macro detected do you want to save it?"
                                                                    action:^(){
                                                                        MacroAutoLearner * learner = [[MacroAutoLearner alloc] init];
                                                                        MacroImpl * impl = [learner implementorFor:[phoneNumberField text] from:[contactTableDataSource selectedNumber]];
                                                                        NSString * name = [[AppGlobals organizer] nextNewName];
                                                                        [AppGlobals recordEvent:RECORDEVENT_LEARNED_NEW every:RECORDEVENT_STEP_EVERY];
                                                                        [[AppGlobals organizer] addOrReplaceMacro:name implementor:impl];
                                                                        NSUInteger idx = [[AppGlobals organizer] indexForMacroName:name];

                                                                        MacroNameViewController * nvc = [[MacroNameViewController alloc] init];
                                                                        [nvc setOrganizerIndex:idx];
                                                                        [nvc setForceRename:YES];
                                                                        [[self navigationController] pushViewController:nvc animated:YES];
                                                                    }];
        [self presentViewController:ac animated:YES completion:^(){}];


	};
}

#pragma mark User Functionality

// When accessory pressed, show definition of macro
-(void)macroAccessorySelected{
	MacroEditViewController * mvc = [[MacroEditViewController alloc] initWithIndex:[macroTableDataSource selectedMacro]];
	[mvc setSampleNumber:[self sampleNumber]];
	[[self navigationController] pushViewController:mvc animated:YES];
}

// if user pressed a new macro, we want to execute it on current input phone number
-(void)macroSelected{

	MacroImpl*imp=[macroTableDataSource selectedMacroImpl];

	if( imp ){
		NSString*				numberStr	=	[phoneNumberField		text];
		PhoneNumber*			pn			=	[[PhoneNumber alloc]	initWithString:numberStr];
		NSMutableDictionary*	aDict		=	[macroTableDataSource	selectedMacroVariables];
		NSMutableArray *		missing		=	[imp missingVariablesForDict:aDict];

		if( [missing count] == 0 ){
			[self recordUndoState];

			[imp execute:pn data:aDict];
			[phoneNumberField setText:[pn outputNumber]];
			currentState = STATE_MACRO_EXECUTED;

			[callRecord setMacroId:		[macroTableDataSource selectedMacroId]];
			[callRecord setMacroName:	[macroTableDataSource selectedMacroName]];
		}else{
			MacroVariablesViewController * mvc = [[MacroVariablesViewController alloc] initWithDataSource:macroTableDataSource];
			[[self navigationController] pushViewController:mvc animated:YES];
		}


	};
	[self refreshAll];
	[self performSelector:@selector(deselectMacro:) withObject:nil afterDelay:0.2f];
}

// timed deselect to get animation
- (void) deselectMacro: (id) sender
{
	[macroTableView deselectRowAtIndexPath:[macroTableView indexPathForSelectedRow] animated:YES];
}

- (void) deselectNumber: (id) sender
{
	//[contactTableView deselectRowAtIndexPath:[contactTableView indexPathForSelectedRow] animated:YES];
}

#pragma mark Data Updates and Refreshs

-(void)refreshAll{
	PROFILE_START();
	[self.navigationItem setTitle:[contactTableDataSource contactName]];
	[contactTableView	reloadData];
	[macroTableView		reloadData];
	[self displayInfo];
	PROFILE_STOP( @"refreshAll:total" );
}

-(void)refreshAfterDataChange{
	if( [AppGlobals configGetInt:CONFIG_LEFTBUTTON defaultValue:LEFTBUTTON_INFO] == LEFTBUTTON_INFO ){
		[infoButton setAlpha:1.0];
		[smsButton	setAlpha:0.0];
	}else{
		[infoButton setAlpha:0.0];
		[smsButton	setAlpha:1.0];
	}
	[self refreshAll];
}

-(NSString*)sampleNumber{
	return( [phoneNumberField text] );
}

// Call when number has been selected
-(void)phoneNumberChanged{
	PROFILE_START();
	BOOL applyTopRule = FALSE;
	if( [contactTableDataSource selectedIndex] < [[contactTableDataSource allPhoneLabels] count] ){
		NSString*		numberStr	=	[[contactTableDataSource allPhoneNumbers] objectAtIndex:[contactTableDataSource selectedIndex]];

		// Logic:
		//   if number is new number, different from previous and top rules has digit in common, auto apply
		//             top rules
		//   other wise, keep original number.
		//         especially second time you hit same number don't apply rules

		PhoneNumber*	pn			=	[[PhoneNumber alloc] initWithString:numberStr];
		PROFILE_REPORT( @"phoneNumberChanged:1" );
		[phoneNumberField setText:[pn outputNumber]];
		[AppGlobals configSet:CONFIG_SAMPLE_NUMBER stringVal:[pn outputNumber]];

		if( ![[callRecord originalNumber] isEqualToString:[pn outputNumber]] ){
			applyTopRule = TRUE;
		}

		currentState = STATE_ORIGINAL_NUMBER;

		[callRecord setCallNumber:		[pn outputNumber]];
		[callRecord setContactId:		[contactTableDataSource recordId]];
		[callRecord setContactName:		[contactTableDataSource contactName]];
		[callRecord setPhoneLabel:		[contactTableDataSource phoneLabel]];
		[callRecord setLocation:		[AppGlobals lastLocation]];
		[callRecord setMacroId:			INVALID_MACRO_ID];
		[callRecord setMacroName:		@""];
		[callRecord setOriginalNumber:	[pn outputNumber]];
		PROFILE_REPORT( @"phoneNumberChanged:2" );

		[self setPhoneInfo:[[AppGlobals info] infoForNumber:numberStr]];
		currentInfo = 0;
		PROFILE_REPORT( @"phoneNumberChanged:3" );

		[[AppGlobals organizer] sortMacrosForRecord:callRecord];

		// force reload of cell content (for previews)
		if( ! applyTopRule ) {// if applyTopRule will be refresh later
			[self refreshAll];
		};

	};
	if( applyTopRule ){
		[macroTableDataSource setSelectedMacro:0];// top one
		NSUInteger indexes[2] = {0,0};
		NSIndexPath * indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
		[macroTableView selectRowAtIndexPath:indexPath animated:FALSE scrollPosition:UITableViewScrollPositionNone];
		[self macroSelected];

	};
	PROFILE_STOP( @"phoneNumberChanged:total" );
}

// Called when recent history is pressed
-(void)updateForRecord:(RecentCallRecord *)aRecord{
	[callRecord setOriginalNumber:[aRecord originalNumber]];
	[phoneNumberField setText:[aRecord callNumber]];
	[self updateContactDataFromId:[aRecord contactId]];
	[self refreshAll];
}

-(void)updateContactDataFromId:(NSString*)aId{
//#warning update with CNContact identifier
    if (!aId) {
        return;
    }
    CNContactStore * store = [[CNContactStore alloc] init];
    NSError * error = nil;
    CNContact * contact = [store unifiedContactWithIdentifier:aId keysToFetch:@[CNContactFamilyNameKey, CNContactGivenNameKey,CNContactPhoneNumbersKey] error:&error];
    if (contact) {
        contactTableDataSource.firstName = contact.givenName ?: @"";
        contactTableDataSource.lastName = contact.familyName ?: @"";
        contactTableDataSource.recordId = contact.identifier;

        NSArray * contactPhoneNumbers = contact.phoneNumbers;

        NSMutableArray * phoneNumbers = [NSMutableArray arrayWithCapacity:contactPhoneNumbers.count];
        NSMutableArray * phoneLabels  = [NSMutableArray arrayWithCapacity:contactPhoneNumbers.count];

        for (CNLabeledValue * lv in contactPhoneNumbers) {
            CNPhoneNumber * number = lv.value;
            [phoneNumbers addObject:number.stringValue];
            [phoneLabels addObject:[CNLabeledValue localizedStringForLabel:lv.label]];
        }
        contactTableDataSource.allPhoneLabels = phoneLabels;
        contactTableDataSource.allPhoneNumbers = phoneNumbers;
    }

	[self refreshAll];
}

-(void)updateContactData:(NSArray*)phoneNumbers labels:(NSArray*)phoneLabels
				firstname:(NSString*)fn lastname:(NSString*)ln
				recordId:(NSString*)aId{
	if( phoneNumbers && phoneLabels ){
		[contactTableDataSource setAllPhoneNumbers:phoneNumbers];
		[contactTableDataSource setAllPhoneLabels:phoneLabels];
	}else{
		[self updateContactDataFromId:aId];
	}

	[contactTableDataSource setFirstName:	fn ? fn : @""];
	[contactTableDataSource setLastName:	ln ? ln : @""];
	[contactTableDataSource setRecordId:aId];

	NSUInteger indexes[2];
	indexes[0] = 0;
	indexes[1] = 0;

	[contactTableView selectRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:2] animated:YES scrollPosition:UITableViewScrollPositionNone];

	[self refreshAll];
}

#pragma mark Undo

-(void)displayUndoButton{
	if( [undoStates count] != 0 ){
		[[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Undo"
																					   style:UIBarButtonItemStylePlain
																					  target:self
																					  action:@selector(undo)]];
	} else {
		[[self navigationItem] setRightBarButtonItem:nil];
	}
}

-(void)recordUndoState{
	[undoStates addObject:[UndoState undoStateWithNumber:[phoneNumberField text] andState:currentState]];
	[self displayUndoButton];
}

-(void)undo{
	if( [undoStates count] ){
		UndoState * last = [undoStates lastObject];
		[phoneNumberField setText:[last phoneNumber]];
		currentState = [last currentState];
		[undoStates removeLastObject];
		[self refreshAll];
	}
	[self displayUndoButton];
}

-(NSString*)previousNumber{
	if( [undoStates count] ){
		return( [[undoStates lastObject] phoneNumber] );
	}else{
		return( @"" );
	}
}

@end
