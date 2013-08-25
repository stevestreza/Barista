//
//  BARBasicAuthentication.m
//  Barista
//
//  Created by Bill Williams on 8/25/13.
//  Copyright (c) 2013 Steve Streza. All rights reserved.
//

#import "BARBasicAuthentication.h"

@interface BARBasicAuthentication ()
/**
 Generates and returns an NSURLCredential for basic authentication from the value of an HTTP Authorization field.
 @param fieldValue The value of an HTTP Authorization field.
 @return An NSURLCredential with username and password, if the field contained a valid credential. If no credential was found, nil.
 */
- (NSURLCredential *)credentialFromAuthorizationField:(NSString *)fieldValue;

/**
 Generates and returns an NSURLCredential for basic authentication from the user and value segments of an NSURL.
 @param URL The URL from which to use the username and password.
 @return An NSURLCredential with the username and password from the URL.
 @discussion This method uses NSURL’s -user and -password methods to parse the username and password values.
 */
- (NSURLCredential *)credentialFromURL:(NSURL *)URL;
@end


@implementation BARBasicAuthentication

- (instancetype)initWithRealm:(NSString *)realm authorizationBlock:(BARBasicAuthenticationBlock)authorizationBlock {
	self = [super init];
	if (self) {
		self.realm = realm;
		self.authorizationBlock = authorizationBlock;
	}
	return self;
}


#pragma mark - Barista Middleware
- (void)willSendResponse:(BARResponse *)response forRequest:(BARRequest *)request forConnection:(BARConnection *)connection continueHandler:(void (^)(void))handler {

	// Presume that we're unauthorized by default
	BOOL authorized = NO;
	NSURLCredential *credential = nil;

	// Attempt to parse a credential from the Authorization header
	credential = [self credentialFromAuthorizationField:request.headerFields[@"Authorization"]];

	// Attempt to parse a credential from the URL
	if (!credential) {
		credential = [self credentialFromURL:request.URL];
	}

	// Ask the authorization block if the credential is valid
	if (credential && self.authorizationBlock) {
		authorized = self.authorizationBlock(credential);
	}

	// If we're still not authorized, challenge the client for credentials
	if (!authorized) {
		// Send the authentication challenge
		NSString *authenticateHeader = [NSString stringWithFormat:@"Basic realm=\"%@\"", self.realm];
		[response setValue:authenticateHeader forHTTPHeaderField:@"WWW-Authenticate"];
		response.statusCode = 401;
	}

	// Continue processing the request
	handler();
}


#pragma mark - Private methods
- (NSURLCredential *)credentialFromAuthorizationField:(NSString *)fieldValue {
	NSArray *headerComponents = [fieldValue componentsSeparatedByString:@" "];

	// Make sure this is an HTTP Basic authorization header
	if (![[headerComponents[0] lowercaseString] isEqualToString:@"basic"]) {
		return nil;
	}

	// Base64 decode the authorization value
	NSString *foo = headerComponents[1];
	NSData *data = [foo dataUsingEncoding:NSASCIIStringEncoding];
	NSString *baz = [data barista_base64DecodedString];

	NSArray *authComponents = [baz componentsSeparatedByString:@":"];
	NSString *username = authComponents[0];
	NSString *password = authComponents[1];

	// Create and return the credential
	NSURLCredential *credential = [[NSURLCredential alloc] initWithUser:username password:password persistence:NSURLCredentialPersistenceNone];
	return credential;
}


- (NSURLCredential *)credentialFromURL:(NSURL *)URL {
	// Create and return a credential from the URL value
	NSURLCredential *credential = [[NSURLCredential alloc] initWithUser:[URL user] password:[URL password] persistence:NSURLCredentialPersistenceNone];
	return credential;
}

@end
