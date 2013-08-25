//
//  BARRouter.m
//  Barista
//
//  Created by Grant Butler on 8/25/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import "BARRouter.h"

@implementation BARRouter

-(void)addRoute:(NSString *)route forHTTPMethod:(NSString *)method handler:(BOOL (^)(BARConnection *connection, BARRequest *request, NSDictionary *parameters))handler {
	method = [method uppercaseString];
	
	JLRoutes *router = [JLRoutes routesForScheme:method];
	
	[router addRoute:route handler:^BOOL(NSDictionary *parameters){
		BARRequest *request = parameters[@"BARRequest"];
		BARConnection *connection = parameters[@"BARConnection"];
		parameters = [parameters dictionaryWithValuesForKeys:[[parameters allKeys] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self != %@ AND self != %@", @"BARRequest", @"BARConnection"]]];
		
		return handler(connection, request, parameters);
	}];
}

-(void)didReceiveRequest:(BARRequest *)request forConnection:(BARConnection *)connection continueHandler:(void (^)(void))handler {
	JLRoutes *router = [JLRoutes routesForScheme:request.HTTPMethod.uppercaseString];
	BOOL didRoute = [router routeURL:request.URL withParameters:@{@"BARRequest": request, @"BARConnection": connection}];
	if(!didRoute){
		// not handled
		NSLog(@"Could not handle %@ %@", request.HTTPMethod, request.URL);
		handler();
	}
}

@end
