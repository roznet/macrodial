//  MIT Licence
//
//  Created on 13/02/2009.
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

#import "PhoneNumber.h"

@interface MacroImpl : NSObject <NSCopying> {
	NSString  *	type;
	MacroImpl * nextImplementor;
	MacroImpl * __weak parentImplementor;
	BOOL beingCalculated;
}

@property (nonatomic, strong) 	MacroImpl*	nextImplementor;
@property (nonatomic, weak)	MacroImpl*  parentImplementor;
@property (nonatomic, strong)   NSString*	type;
@property BOOL beingCalculated;

-(MacroImpl*)initWithImpl:(MacroImpl*)aImpl;

// Execution functions, execute recursively, should not need to override
-(PhoneNumber*)		execute:(PhoneNumber*)	aNumber		data:(NSDictionary*)aDict;
-(bool)				test:(PhoneNumber*)		aNumber		data:(NSDictionary*)aDict;
-(NSArray*)			argumentsNames;
-(NSMutableArray*)	variablesNames;
-(NSMutableArray*)	missingVariablesForDict:(NSDictionary*)aDict;
-(NSString*)		toXML;

// Implementation Functions to override
-(PhoneNumber*) apply:(PhoneNumber*)aNumber		data:(NSDictionary*)aDict;
-(UIKeyboardType) getKeyboardType:(NSString*)key;
-(NSString*)	getArgument:(NSString*)key;
-(void)			setArgument:(NSString*)key		value:(NSString*)val;//any key values for example <prefix>1966</prefix>
-(void)			setSubMacro:(NSString*)key		macro:(MacroImpl*)macro;// a subrule to use inside the macro (for example <if><cond>)
-(NSArray*)		myVariablesNames;
-(NSString*)	myToXML;

-(NSString*)	description;
-(NSString*)	typeDescription;
-(NSString*)	argsDescription;

//Debug fns
-(void)				dump;
-(void)				dumpForLevel:(int)i;


@end
