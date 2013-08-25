//
//  BARSessionStore.m
//  Barista
//
//  Created by Steve Streza on 4/28/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
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
