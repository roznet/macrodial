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

@interface PhoneNumber : NSObject {
	//Inputs
	NSString * number;

	//Outputs
	NSString * digitsOnly;
	NSString * countryCode;
}
@property (nonatomic,strong) NSString * number;
@property (nonatomic,strong) NSString * digitsOnly;
@property (nonatomic,strong) NSString * countryCode;

-(id)initWithString:(NSString*)aNumber;

// Tests
-(BOOL)hasPrefix:(NSString*)aPrefix;
-(BOOL)hasSuffix:(NSString*)aSuffix;
-(NSString*)commonSuffixWithNumber:(PhoneNumber*)other;
-(NSString*)commonPrefixWithNumber:(PhoneNumber*)other;
-(NSString*)commonSuffix:(NSString*)other;
-(NSString*)commonPrefix:(NSString*)other;

-(void)performOperation:(SEL)sel;
-(void)performOperation:(SEL)sel withObject:(NSString*)a1;
-(void)performOperation:(SEL)sel withObject:(NSString *)a1 withObject:(NSString*)a2;

// Operations
-(void)addPrefix:(NSString*)aPrefix;
-(void)addSuffix:(NSString*)aSuffix;
-(void)removePrefix:(NSString*)aPrefix;
-(void)removeSuffix:(NSString*)aSuffix;
-(void)lastDigits:(int)n;
-(void)firstDigits:(int)n;
-(void)removeCountryCode;
-(void)removePlus;
-(void)addPlus;
-(void)addPausePrefix:(int)n;
-(void)addPauseSuffix:(int)n;
-(void)replaceString:(NSString*)aSubStr with:(NSString*)aNewStr;
-(void)replacePrefix:(NSString*)aSubStr with:(NSString*)aNewStr;
-(void)replaceSuffix:(NSString*)aSubStr with:(NSString*)aNewStr;
-(void)regexReplace:(NSString*)aRegex   with:(NSString*)aNewStr;

// Current processed number
-(NSString*)outputNumber;

// Parsing
+(NSString*)parseCountryCode:(NSString*)aNumber;
+(NSString*)filterDigitsOnly:(NSString*)aNumber;

@end
