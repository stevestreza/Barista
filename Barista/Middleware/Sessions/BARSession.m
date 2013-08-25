//
//  BARSession.m
//  Barista
//
//  Created by Steve Streza on 4/28/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import "BARSession.h"

@implementation BARSession {
	NSMutableDictionary *_customData;
}

+(instancetype)sessionFromHTTPCookie:(NSHTTPCookie *)cookie{
	if(cookie.value.length){
		BARSession *session = [self session];
		session.identifier = cookie.value;
		return session;
	}else{
		return nil;
	}
}

+(instancetype)session{
	BARSession *session = [[BARSession alloc] init];
	return session;
}

-(NSHTTPCookie *)cookieWithName:(NSString *)name forRequest:(BARRequest *)request{
	NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:@{
												   NSHTTPCookieName: name,
												  NSHTTPCookieValue: self.identifier,
												 NSHTTPCookieDomain: request.headerFields[@"Host"],
												   NSHTTPCookiePath: request.URL.path
							}];
	return cookie;
}

-(id)init{
	self = [super init];
	if(self){
		CFUUIDRef uuidRef = CFUUIDCreate(NULL);
		NSString *uuid = (__bridge NSString *)CFUUIDCreateString(NULL, uuidRef);
		_identifier = uuid;
	}
	return self;
}

-(void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key{
	if(!_customData){
		_customData = [NSMutableDictionary dictionary];
	}
	
	_customData[key] = object;
}

-(id)objectForKeyedSubscript:(id)key{
	return _customData[key];
}

@end

@implementation BARRequest (BARSessionSupport)

-(BARSession *)session{
	return [self customValueForKey:@"BARSession"];
}

-(void)_setSession:(BARSession *)session{
	[self setCustomValue:session forKey:@"BARSession"];
}

@end