//
//  BARAuthenticator.h
//  Barista
//
//  Created by Steve Streza on 8/25/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaristaTypes.h"

typedef void (^BARAuthenticatorCompletionHandler)(BOOL isAuthorized);
typedef void (^BARAuthenticatorAuthorizationHandler)(id credential, BARAuthenticatorCompletionHandler completionHandler);

@interface BARAuthenticator : NSObject <BaristaMiddleware>

@property (nonatomic, copy) BARAuthenticatorAuthorizationHandler authorizationHandler;

#pragma mark For Subclasses

/**
 Returns a credential object to be passed to the authorization handler.
 @param request The request to obtain the credential from.
 @return The credential object.
 */
- (id)credentialForRequest:(BARRequest *)request;

/**
 Returns a response object that will be returned to the client if the authorization fails.
 You can call through to super to obtain a stock 401 response, and modify as needed.
 @param request The request that failed authorization.
 @param credential The credential from the request that failed authorization.
 @return A completed response to be sent back to the client.
 */
- (BARResponse *)failureResponseForRequest:(BARRequest *)request withCredential:(id)credential;

@end
