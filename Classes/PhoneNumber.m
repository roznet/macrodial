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

//#define MIN(a,b) a < b ? a : b

#import "PhoneNumber.h"

#pragma mark Init Functions
@implementation PhoneNumber
@synthesize number;
@synthesize digitsOnly;
@synthesize countryCode;


-(id)initWithString:(NSString*)aNumber
{
	if( ( self = [super init] ) ){
		number			= [aNumber copy];
		digitsOnly		= [PhoneNumber filterDigitsOnly:number];
		countryCode		= [PhoneNumber parseCountryCode:digitsOnly];
	}
	return( self );
}

-(NSString*)outputNumber{
	return( digitsOnly );
}

#pragma mark Parsing Functions

+(NSString*)parseCountryCode:(NSString*)aNumber{
	const char * a = [aNumber UTF8String];
	const char *ca = a;

	char firstDigits[4];
	char *cb = firstDigits;

	int i=0;
	while( *ca != '\0' && i < 3 ){
		if( *ca >= '0' && *ca <= '9' ){
			*cb=*ca;
			cb++;
			i++;
		};
		ca++;
	};
	*cb = '\0';
	i=0;
	switch( firstDigits[0] ){
		case '1':
			i = 1;
			break;
		case '2'://africa
			switch( firstDigits[1] ){
				case '7':
				case '0':
					i = 2;
					break;
				default:
					i = 3;
					break;
			};
			break;
		case '3'://europe
			switch( firstDigits[1] ){
				case '5':
				case '7':
				case '8':
					i = 3;
					break;
				default:
					i = 2;
			};
			break;
		case '4':	//europe
			switch( firstDigits[1] ){
				case '2':
					i = 3;
					break;
				default:
					i = 2;
			};
			break;
		case '5':	// Mexico, central america
			switch( firstDigits[1] ){
				case '0':
				case '9':
					i = 3;
					break;
				default:
					i = 2;
			};
			break;
		case '6':	//Southeast asia
			switch( firstDigits[1] ){
				case '7':
				case '8':
				case '9':
					i = 3;
					break;
				default:
					i = 2;
			};
			break;
		case '7':	// russia
			i = 1;
			break;
		case '8':	// East Asia
			switch( firstDigits[1] ){
				case '0':
				case '5':
				case '7':
				case '8':
				case '9':
					i = 3;
					break;
				default:
					i = 2;
			};
			break;
		case '9':	// West, South central asia
			switch( firstDigits[1] ){
				case '6':
				case '7':
				case '9':
					i = 3;
					break;
				default:
					i = 2;
			};
			break;
	}
	firstDigits[i]='\0';

	return( [[NSString alloc] initWithUTF8String:firstDigits] );

}

+(NSString*)filterDigitsOnly:(NSString*)aNumber{
	char a[256];
	char b[256];
	char * ca = a;
	char * cb = b;

	[aNumber getCString:a maxLength:256 encoding:[NSString defaultCStringEncoding]];

	while( *ca != '\0' ){
		if( ( *ca >= '0' && *ca <= '9' ) || *ca == ',' || *ca == '*' || *ca == '#' || *ca == '+' ){
			*cb=*ca;
			cb++;
		};
		ca++;
	};
	*cb='\0';
	return( [[NSString alloc] initWithUTF8String:b] );
}

#pragma mark Process Functions

-(void)performOperation:(SEL)sel{
    // needs below because ARC can't call performSelector it does not know.
    IMP imp = [self methodForSelector:sel];
    void (*func)(id, SEL) = (void*)imp;
    func(self, sel);

}
-(void)performOperation:(SEL)sel withObject:(NSString*)a1{
    // needs below because ARC can't call performSelector it does not know.
    IMP imp = [self methodForSelector:sel];
    void (*func)(id, SEL,NSString*) = (void*)imp;
    func(self, sel,a1);

    //[self performSelector:sel withObject:a1];
}
-(void)performOperation:(SEL)sel withObject:(NSString *)a1 withObject:(NSString*)a2{
    // needs below because ARC can't call performSelector it does not know.
    IMP imp = [self methodForSelector:sel];
    void (*func)(id, SEL,NSString*,NSString*) = (void*)imp;
    func(self, sel,a1,a2);
    //[self performSelector:sel withObject:a1 withObject:a2];
}


-(NSString*)pauseString:(int)n{
	NSString * rv = @"";
	if( n > 0 && n < 10 ){// no reason to want more than 10 protect overflows
		for( int i = 0 ; i < n; i++){
			rv = [rv stringByAppendingString:@"," ];
		}
	}
	return( rv );
}

-(void)addPausePrefix:(int)n{
	[self addPrefix:[self pauseString:n]];
}

-(void)addPauseSuffix:(int)n{
	[self addSuffix:[self pauseString:n]];
}

-(void)removePlus{
	if( [digitsOnly hasPrefix:@"+"] ){
		[self setDigitsOnly:[digitsOnly substringFromIndex:1]];
	}
}
-(void)removePrefix:(NSString*)aPrefix{
	if( [digitsOnly hasPrefix:aPrefix] ){
		[self setDigitsOnly:[digitsOnly substringFromIndex:[aPrefix length]]];
	};
}
-(void)removeSuffix:(NSString*)aSuffix{
	if( [digitsOnly hasSuffix:aSuffix] ){
		[self setDigitsOnly:[digitsOnly substringToIndex:([digitsOnly length]-[aSuffix length])]];
	}
}

-(void)removeCountryCode{
	if( [digitsOnly hasPrefix:countryCode] ){
		[self setDigitsOnly:[digitsOnly substringFromIndex:[countryCode length]]];
	}else if( [digitsOnly hasPrefix:[NSString stringWithFormat:@"+%@", countryCode]] ){
		[self setDigitsOnly:[digitsOnly substringFromIndex:([countryCode length]+1)]];
	}
}

-(void)addPrefix:(NSString*)aPrefix{
	[self setDigitsOnly:[aPrefix stringByAppendingString:digitsOnly]];
}
-(void)addSuffix:(NSString*)aSuffix{
	[self setDigitsOnly:[digitsOnly stringByAppendingString:aSuffix]];
}
-(void)addPlus{
	[self addPrefix:@"+"];
}

-(void)firstDigits:(int)n{
	[self setDigitsOnly:[digitsOnly substringToIndex:n]];
}

-(void)lastDigits:(int)n{
	NSUInteger startIndex = [digitsOnly length];
	if( startIndex > n ){
        startIndex-=n;
		[self setDigitsOnly:[digitsOnly substringFromIndex:startIndex]];
	};
}

-(void)replaceString:(NSString*)aSubStr with:(NSString*)aNewStr{
	NSMutableString * rv = [NSMutableString stringWithString:digitsOnly];
	[rv replaceOccurrencesOfString:aSubStr withString:aNewStr options:NSCaseInsensitiveSearch range:NSMakeRange(0, [rv length])];
	[self setDigitsOnly:rv];
}

-(void)replacePrefix:(NSString*)aSubStr with:(NSString*)aNewStr{
	if( [self hasPrefix:aSubStr] ){
		[self removePrefix:aSubStr];
		[self addPrefix:aNewStr];
	}
}

-(void)replaceSuffix:(NSString*)aSubStr with:(NSString*)aNewStr{
	if( [self hasSuffix:aSubStr] ){
		[self removeSuffix:aSubStr];
		[self addSuffix:aNewStr];
	}
}


#pragma mark Compare Functions

-(BOOL)hasPrefix:(NSString*)aPrefix{
	return( [[self digitsOnly] hasPrefix:aPrefix] );
}
-(BOOL)hasSuffix:(NSString*)aSuffix{
	return( [[self digitsOnly] hasSuffix:aSuffix] );
}
-(NSString*)commonSuffixWithNumber:(PhoneNumber*)other{
	return( [self commonSuffix:[other digitsOnly]] );
}
-(NSString*)commonPrefixWithNumber:(PhoneNumber*)other{
	return( [self commonPrefix:[other digitsOnly]] );
}

-(NSString*)commonSuffix:(NSString*)other{
	NSUInteger n = MIN( [other length], [[self digitsOnly] length]);
	NSRange range_other = NSMakeRange([other length]-n, n);
	NSRange range_self  = NSMakeRange([[self digitsOnly] length]-n, n);
	while( range_self.length > 0 && ![[other substringWithRange:range_other] isEqualToString:[[self digitsOnly] substringWithRange:range_self]] ){
		range_self.location++;
		range_self.length--;
		range_other.location++;
		range_other.length--;
	}
	return( [[self digitsOnly] substringWithRange:range_self] );
}

-(NSString*)commonPrefix:(NSString*)other{
	NSUInteger n = MIN( [other length], [[self digitsOnly] length]);
	int i = 0;
	NSRange range = NSMakeRange(i, n);
	while( n > i && [other compare:[[self digitsOnly] substringWithRange:range] options:NSCaseInsensitiveSearch range:range] ){
		range = NSMakeRange(i, --n);
	}
	return( [[self digitsOnly] substringWithRange:range] );
}

-(void)regexReplace:(NSString*)aRegex   with:(NSString*)aNewStr{
    NSError * error = NULL;
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:aRegex options:NSRegularExpressionCaseInsensitive error:&error];
    if( error == nil ){
        [self setDigitsOnly:[regex stringByReplacingMatchesInString:[self digitsOnly] options:0 range:NSMakeRange(0, [digitsOnly length]) withTemplate:aNewStr]];
    }
}

@end
