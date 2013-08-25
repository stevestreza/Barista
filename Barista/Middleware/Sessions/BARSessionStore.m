//
//  BARSessionStore.m
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

#import "BARSessionStore.h"
#import "BARSession.h"
#import "BARCookieParser.h"
#import "BARResponse.h"

@interface BARRequest (BARSessionSetter)

-(void)_setSession:(BARSession *)session;

@end

@implementation BARSessionStore {
	NSMutableDictionary *_sessions;
}

+(instancetype)sessionStoreWithCookieBaseName:(NSString *)cookieBaseName{
	BARSessionStore *sessionStore = [[BARSessionStore alloc] init];
	sessionStore.cookieBaseName = cookieBaseName;
	return sessionStore;
}

-(BARSession *)sessionForSessionIdentifier:(NSString *)sessionIdentifier withCookie:(NSHTTPCookie *)cookie{
	if(!_sessions){
		_sessions = [NSMutableDictionary dictionary];
	}
	
	BARSession *session = _sessions[sessionIdentifier];
	if(!session){
		session = [BARSession sessionFromHTTPCookie:cookie];
		_sessions[sessionIdentifier] = session;
	}

	return session;
}

-(NSString *)sessionIdentifierForRequest:(BARRequest *)request{
	return [[self sessionCookieForRequest:request] value];
}

-(NSString *)cookieName{
	return [NSString stringWithFormat:@"%@_id", self.cookieBaseName];
}

-(NSHTTPCookie *)sessionCookieForRequest:(BARRequest *)request{
	return [request cookieNamed:[self cookieName]];
}

-(void)didReceiveRequest:(BARRequest *)request
		   forConnection:(BARConnection *)connection
		 continueHandler:(void (^)(void))handler{

	NSString *sessionIdentifier = [self sessionIdentifierForRequest:request];
	if(sessionIdentifier.length){
		BARSession *session = [self sessionForSessionIdentifier:sessionIdentifier withCookie:[self sessionCookieForRequest:request]];
		[request _setSession:session];
	}else{
		[request _setSession:[BARSession session]];
	}
	
	handler();
}

-(void)willSendResponse:(BARResponse *)response
			 forRequest:(BARRequest *)request
		  forConnection:(BARConnection *)connection
		continueHandler:(void (^)(void))handler{
	if(request.session){
		[response addCookie:[request.session cookieWithName:[self cookieName] forRequest:request]];
	}
	handler();
}

@end
