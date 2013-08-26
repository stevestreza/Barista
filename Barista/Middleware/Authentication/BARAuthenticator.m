//
//  BARAuthenticator.m
//  Barista
//
//  Created by Steve Streza on 8/25/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import "BARAuthenticator.h"
#import "BARResponse.h"
#import "BARConnection.h"

@implementation BARAuthenticator

- (void)didReceiveRequest:(BARRequest *)request forConnection:(BARConnection *)connection continueHandler:(void (^)(void))handler {
	id credential = [self credentialForRequest:request];
	
	// Ask the authorization block if the credential is valid
	BARAuthenticatorAuthorizationHandler authorizationHandler = self.authorizationHandler;
	if(!authorizationHandler){
		authorizationHandler = ^(id credential, BARAuthenticatorCompletionHandler handler){
			handler(NO);
		};
	}
	
	authorizationHandler(credential, ^(BOOL authorized){
		// If we're still not authorized, challenge the client for credentials
		if (!authorized) {
			BARResponse *response = [self failureResponseForRequest:request withCredential:credential];
			[connection sendResponse:response];
		} else {
			handler();
		}
	});
}

- (id)credentialForRequest:(BARRequest *)request {
	return nil;
}

- (BARResponse *)failureResponseForRequest:(BARRequest *)request withCredential:(id)credential {
	BARResponse *response = [[BARResponse alloc] init];
	response.statusCode = 401;
	return response;
}

@end
