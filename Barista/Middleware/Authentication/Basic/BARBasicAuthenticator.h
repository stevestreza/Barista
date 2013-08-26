//
//  BARBasicAuthentication.h
//  Barista
//
//  Created by Teapot on 8/25/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaristaTypes.h"
#import "BARAuthenticator.h"
#import "BARRequest.h"
#import "BARResponse.h"
#import "NSData+BaristaExtensions.h"

/**
 `BARBasicAuthentication` is a Barista middleware authenticator for requiring HTTP Basic authentication on the requests it processes.
 */
@interface BARBasicAuthenticator : BARAuthenticator

/** The realm to show to the user when an authentication challenge is presented. */
@property (copy, nonatomic) NSString *realm;

/**
 Initializes the receiver with a realm and authorization block.
 @param realm The realm to show to the user when an authentication challenge is presented.
 @param authorizationBlock The block used to check validity of a presented credential.
 @return The initialized middleware.
 */
- (instancetype)initWithRealm:(NSString *)realm authorizationHandler:(BARAuthenticatorAuthorizationHandler)authorizationHandler;
@end
