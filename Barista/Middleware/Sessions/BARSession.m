//
//  BARSession.m
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