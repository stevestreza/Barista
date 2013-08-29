//
//  BARErrorHandler.m
//  Barista
//
//  Created by Grant Butler on 8/29/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import "BARErrorHandler.h"

@implementation BARErrorHandler

+ (instancetype)errorHandler{
	return [[self alloc] init];
}

- (instancetype)init{
	if(self = [super init]){
		__weak BARErrorHandler *weakSelf = self;
		_exceptionHandler = [^(BARRequest *request, BARConnection *connection, NSException *exception){
			BARErrorHandler *self = weakSelf;
			
			BARResponse *response = [[BARResponse alloc] init];
			response.statusCode = 500;
			
			if(self.showsStackTrace){
				NSMutableString *responseString = [NSMutableString string];
				[responseString appendFormat:@"Unexpected %@ encountered.\r\n", [exception name]];
				[responseString appendFormat:@"%@\r\n\r\n", [exception reason]];
				[responseString appendString:@"Stack Trace:\r\n"];
				[responseString appendFormat:@"%@", [[exception callStackSymbols] componentsJoinedByString:@"\r\n"]];
				
				response.responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
			}else{
				response.responseData = [@"The server encountered an error while handling your request." dataUsingEncoding:NSUTF8StringEncoding];
			}
			
			[connection sendResponse:response];
		} copy];
	}
	return self;
}

- (void)didReceiveRequest:(BARRequest *)request forConnection:(BARConnection *)connection continueHandler:(void (^)(void))handler{
	@try{
		handler();
	}
	@catch(NSException *exception){
		if(self.exceptionHandler){
			self.exceptionHandler(request, connection, exception);
		}
		else{
			[exception raise];
		}
	}
}

@end
