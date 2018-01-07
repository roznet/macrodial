//  MIT Licence
//
//  Created on 19/02/2009.
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

#import "MacroDialTestViewController.h"
#import "PhoneNumberTests.h"
#import "MacroXMLParser.h"
#import "MacroTests.h"
#import "WebMacrosTests.h"
#import "MacroHandlerTests.h"
#import "DatabaseTests.h"
#import "InfoTests.h"
#import "ConfigTests.h"
#import "FieldValuePreviewCell.h"
#import "WebURLroznet.h"


@implementation MacroDialTestViewController

-(NSArray*)allTestClassNames{
    return @[
             NSStringFromClass([MacroTests class]),
             NSStringFromClass([PhoneNumberTests class]),
             NSStringFromClass([MacroHandlerTests class]),
             NSStringFromClass([DatabaseTests class]),
             NSStringFromClass([ConfigTests class]),
             NSStringFromClass([InfoTests class]),
             ];
}



@end
