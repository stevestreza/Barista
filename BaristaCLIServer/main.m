//
//  main.m
//  BaristaCLIServer
//
//  Created by Steve Streza on 8/25/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Barista.h"
#import "BARRouter.h"

int main(int argc, const char * argv[])
{

	@autoreleasepool {
	    
		BARServer *server = [BARServer serverWithPort:4242];
		BARRouter *router = [[BARRouter alloc] init];
		[router addRoute:@"/" forHTTPMethod:@"GET" handler:^BOOL(BARConnection *connection, BARRequest *request, NSDictionary *parameters) {
			BARResponse *response = [[BARResponse alloc] init];
			response.responseData = [@"Hello world" dataUsingEncoding:NSUTF8StringEncoding];
			response.statusCode = 200;
			[connection sendResponse:response];
			return YES;
		}];
	    [server addGlobalMiddleware:router];
		[server startListening];
		[server runForever];
	}
    return 0;
}

