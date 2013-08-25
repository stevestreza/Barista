//
//  BARCookieParser.m
//  Barista
//
//  Created by Steve Streza on 4/28/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
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
