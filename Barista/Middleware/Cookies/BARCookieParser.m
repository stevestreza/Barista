//
//  BARCookieParser.m
//  Barista
//
//  Created by Steve Streza on 4/28/13.
//  Copyright (c) 2013: Steve Streza
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
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

#import "BARCookieParser.h"

#import "BARRequest.h"
#import "BARResponse.h"
#import "BARConnection.h"

@implementation BARRequest (BARCookies)

-(void)setCookies:(NSArray *)cookies{
	[self setCustomValue:cookies forKey:@"BARCookies"];
}

-(NSArray *)cookies{
	return [self customValueForKey:@"BARCookies"];
}

-(NSHTTPCookie *)cookieNamed:(NSString *)name{
	__block NSHTTPCookie *foundCookie = nil;
	[self.cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {
		if([cookie.name isEqualToString:name]){
			foundCookie = cookie;
			*stop = YES;
		}
	}];
	return foundCookie;
	
}

-(NSArray *)cookiesMatchingBaseName:(NSString *)name{
	NSMutableArray *matchingCookies = [NSMutableArray array];
	[self.cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {
		if([cookie.name rangeOfString:name].location == 0){
			[matchingCookies addObject:cookie];
		}
	}];
	return [matchingCookies copy];
}

@end

@implementation BARCookieParser

+(instancetype)cookieParser{
	BARCookieParser *parser = [[self alloc] init];
	return parser;
}

-(void)didReceiveRequest:(BARRequest *)request
		   forConnection:(BARConnection *)connection
		 continueHandler:(void (^)(void))handler{
	NSMutableDictionary *headers = [request.headerFields mutableCopy];
	if(headers[@"Cookie"]){
		headers[@"Set-Cookie"] = headers[@"Cookie"];
	}
	
	NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:headers forURL:request.URL];
	request.cookies = cookies;

	handler();
}

-(void)willSendResponse:(BARResponse *)response
			 forRequest:(BARRequest *)request
		  forConnection:(BARConnection *)connection
		continueHandler:(void (^)(void))handler{
	NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[response cookies]];
	[headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if([key isEqualToString:@"Cookie"]){
			key = @"Set-Cookie";
		}
		[response setValue:obj forHTTPHeaderField:key];
	}];
	
	handler();
}

@end


@implementation BARResponse (BARCookies)

-(NSArray *)cookies{
	return [self customValueForKey:@"BARCookies"];
}

-(void)addCookie:(NSHTTPCookie *)cookie{
	if(!cookie) return;
	
	NSMutableArray *cookies = [self customValueForKey:@"BARCookies"];
	if(!cookies){
		cookies = [NSMutableArray array];
		[self setCustomValue:cookies forKey:@"BARCookies"];
	}

	[cookies addObject:cookie];
}

-(void)addCookiesFromRequest:(BARRequest *)request{
	[request.cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {
		[self addCookie:cookie];
	}];
}

@end
