//  MIT Licence
//
//  Created on 12/03/2009.
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

#import "MacroAutoLearner.h"
#import "MacroImplHandler.h"


@implementation MacroAutoLearner

-(MacroImpl*)implementorFor:(NSString*)output from:(NSString*)input{
	MacroImplHandler * handler	= [[MacroImplHandler alloc] init];
	PhoneNumber * pn_input		= [[PhoneNumber alloc] initWithString:input ];
	PhoneNumber * pn_local		= [[PhoneNumber alloc] initWithString:input ];
	PhoneNumber * pn_output		= [[PhoneNumber alloc] initWithString:output];
	BOOL identifiedRule			= FALSE;

	[pn_local removeCountryCode];

	// first check no plus
	if( ![pn_output hasPrefix:@"+"] ){
		MacroImpl * imp = [handler createNewImplForType:@"removeplus"];
		[handler insertImplementor:imp atIndex:0];
		[pn_input removePlus];//make sure from now on we ignore plus in comparisons
	}

	NSString *commonSuffixInputOutput = [pn_output commonSuffix:[pn_input digitsOnly]];

	// Check if something was removed from the suffix of the number
	if( [commonSuffixInputOutput length] != [[pn_input digitsOnly] length] ){
		if( [pn_output hasSuffix:[pn_local digitsOnly]] && ! [pn_output hasSuffix:[pn_input digitsOnly]] ){
			// First candidate is country code was removed?
			[handler appendImplementor:[handler createNewImplForType:@"local"]];
			identifiedRule = TRUE;
		}else if( ([[pn_input digitsOnly] length] - [commonSuffixInputOutput length] ) == 1 && [pn_input hasPrefix:@"0"]) {
			// second if only 0 is gone, specific case
			MacroImpl * removezero = [handler createNewImplForType:@"removeprefix"];
			[removezero setArgument:@"prefix" value:@"0"];
			[handler appendImplementor:removezero];
			identifiedRule = TRUE;
		}else if( [commonSuffixInputOutput length] >= 6){//else keep last n digits assuming at least 6
			MacroImpl * lastn = [handler createNewImplForType:@"lastdigits"];
			[lastn setArgument:@"n" value:[NSString stringWithFormat:@"%d", (int)[commonSuffixInputOutput length]]];
			[handler appendImplementor:lastn];
			identifiedRule = TRUE;
		}
	}else{// the whole original number is there
		identifiedRule = TRUE;
	}

	if( identifiedRule ){
		//Lets see if prefix was added
		[pn_output removeSuffix:commonSuffixInputOutput];
		NSString * prefix = [pn_output digitsOnly];
		if( [prefix length] > 0 ) {
			MacroImpl * addprefix = [handler createNewImplForType:@"prefix"];
			[addprefix setArgument:@"prefix" value:prefix];
			[handler appendImplementor:addprefix];
			identifiedRule = TRUE;
		}
	}
	MacroImpl * rv = nil;
	if( identifiedRule ){
		rv = [handler implementor];
	};
	return( rv );
}
@end
