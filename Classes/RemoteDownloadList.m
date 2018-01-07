//  MIT Licence
//
//  Created on 01/04/2009.
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

#import "RemoteDownloadList.h"

@implementation RemoteDownloadList
@synthesize downloadedList,currentTag,currentData;

-(RemoteDownloadList*)initWithURL:(NSString*)aUrl andDelegate:(NSObject<RZRemoteDownloadDelegate>*)aDelegate{
	if (!(self = [super initWithURL:aUrl andDelegate:aDelegate])) return nil;
	if( self ){
		downloadedList	= nil;
		currentData		= nil;
		currentTag		= nil;
	}
	return( self );
}


#pragma mark NSURLConnection delegate methods

-(void)dataTaskDidFinishLoading:(NSData*)data response:(NSURLResponse*)response{

	NSXMLParser * parser = [[NSXMLParser alloc] initWithData:data];
	[self setCurrentData:nil];
	[self setCurrentTag:nil];
	[self setDownloadedList:[NSMutableArray arrayWithCapacity:10]];
	[parser setDelegate:self];
	[parser parse];
	[self.downloadDelegate downloadArraySuccessful:self array:downloadedList];
}

#pragma mark XML parsing

-(BOOL)validTag:(NSString*)elementName{
	return( [elementName isEqualToString:@"package"] || [elementName isEqualToString:@"macro"] );
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if( [self validTag:elementName] ){
		[self setCurrentData:[NSMutableDictionary dictionaryWithCapacity:4]];
	}else if( [self currentData] ) {
		[self setCurrentTag:elementName];
	}else{
		[self setCurrentTag:nil];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if( [self validTag:elementName] && [self currentData] ){
		[[self downloadedList] addObject:currentData];
		[self setCurrentData:nil];
		[self setCurrentTag:nil];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if( [self currentTag] && [self currentData] ) {
		NSMutableString * val = nil;
		if( ( val = [[self currentData] objectForKey:[self currentTag]] ) ){
			[val appendString:string];
		}else{
			val = [NSMutableString stringWithString:string];
		}
		[[self currentData] setObject:val forKey:currentTag];
	}
}

@end
