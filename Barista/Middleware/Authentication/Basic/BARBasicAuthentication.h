//
//  BARBasicAuthentication.h
//  Barista
//
//  Created by Teapot on 8/25/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaristaTypes.h"
#import "BARRequest.h"
#import "BARResponse.h"
#import "NSData+BaristaExtensions.h"

/**
 A block that checks an NSURLCredential's validity.
 @param credential The credential to check.
 @return A boolean value indicating whether the presented credential should be authorized.
 */
typedef BOOL (^BARBasicAuthenticationBlock)(NSURLCredential *credential);


/**
 `BARBasicAuthentication` is a Barista middleware class for requiring HTTP Basic authentication on the requests it processes.
 */
@interface BARBasicAuthentication : NSObject <BaristaMiddleware>
/** The realm to show to the user when an authentication challenge is presented. */
@property (copy, nonatomic) NSString *realm;

/** The block used to check validity of a presented credential. */
@property (copy, nonatomic) BARBasicAuthenticationBlock authorizationBlock;

/**
 Initializes the receiver with a realm and authorization block.
 @param realm The realm to show to the user when an authentication challenge is presented.
 @param authorizationBlock The block used to check validity of a presented credential.
 @return The initialized middleware.
 */
- (instancetype)initWithRealm:(NSString *)realm authorizationBlock:(BARBasicAuthenticationBlock)authorizationBlock;
@end
