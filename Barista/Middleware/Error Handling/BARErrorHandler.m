//
//  BARErrorHandler.m
//  Barista
//
//  Created by Grant Butler on 8/29/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import "BARErrorHandler.h"

@implementation BARErrorHandler

+ (NSString *)environment{
	return [[[NSProcessInfo processInfo] environment] objectForKey:@"BARISTA_ENV"];
}

+ (instancetype)errorHandler{
	return [[self alloc] init];
}

- (void)didReceiveRequest:(BARRequest *)request forConnection:(BARConnection *)connection continueHandler:(void (^)(void))handler{
	@try{
		handler();
	}
	@catch(NSException *exception){
		BARResponse *response = [[BARResponse alloc] init];
		response.statusCode = 500;
		
		if([[[self class] environment] isEqualToString:@"production"]){
			response.responseData = [@"The server encountered an error while handling your request." dataUsingEncoding:NSUTF8StringEncoding];
		}else{
			NSMutableString *responseString = [NSMutableString string];
			[responseString appendFormat:@"Unexpected %@ encountered.\r\n", [exception name]];
			[responseString appendFormat:@"%@\r\n\r\n", [exception reason]];
			[responseString appendString:@"Stack Trace:\r\n"];
			[responseString appendFormat:@"%@", [[exception callStackSymbols] componentsJoinedByString:@"\r\n"]];
			
			response.responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
		}
		
		[connection sendResponse:response];
	}
}

@end
