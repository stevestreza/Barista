//
//  BARDemoServer.m
//  Barista
//
//  Created by Steve Streza on 4/29/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import "BARDemoServer.h"

@implementation BARDemoServer

-(void)setupRoutes{
	[super setupRoutes];
	
	NSURL *webAppURL = [[NSBundle mainBundle] URLForResource:@"WebApp" withExtension:@""];
	
	[self addGlobalMiddleware:[BARCookieParser cookieParser]];
	[self addGlobalMiddleware:[BARSessionStore sessionStoreWithCookieBaseName:@"_streamers"]];
	[self addGlobalMiddleware:[BARCompressor compressor]];
	[self addGlobalMiddleware:[BARStaticFileServer fileServerWithDirectoryURL:[webAppURL  URLByAppendingPathComponent:@"public"]
															   forURLBasePath:@"/public/"]];
	[self addGlobalMiddleware:[[BARBodyParser alloc] init]];
	[self addGlobalMiddleware:[BARMustacheTemplateRenderer rendererWithViewsDirectoryURL:[webAppURL URLByAppendingPathComponent:@"views"]]];
	
	[self addRoute:@"/foo/:bar" forHTTPMethod:@"GET" handler:^BOOL(BARConnection *connection, BARRequest *request, NSDictionary *parameters) {
		NSLog(@"/foo/:bar parameters: %@", parameters);
		request.session[@"bar"] = parameters[@"bar"];
		BARResponse *response = [[BARResponse alloc] init];
		response.statusCode = 200;
		response.responseData = [[NSString stringWithFormat:@"Sup. I'm foo. Here's your thing - %@", parameters[@"bar"]] dataUsingEncoding:NSUTF8StringEncoding];
		[connection sendResponse:response];
		return YES;
	}];
	
	[self addRoute:@"/testViews" forHTTPMethod:@"GET" handler:^BOOL(BARConnection *connection, BARRequest *request, NSDictionary *parameters) {
		
		id bar = request.session[@"bar"];
		if(!bar){
			bar = @"";
		}

		BARResponse *response = [[BARResponse alloc] init];
		response.statusCode = 200;
		[response setViewToRender:@"test" withObject:@{@"foo": @"abc", @"bar": bar}];
		[connection sendResponse:response];
		
		return YES;
	}];
	
	[self addRoute:@"/" forHTTPMethod:@"GET" handler:^BOOL(BARConnection *connection, BARRequest *request, NSDictionary *parameters) {
		NSLog(@"/ parameters: %@", parameters);
		NSLog(@"Session: %@", request.session[@"bar"]);
		BARResponse *response = [[BARResponse alloc] init];
		response.statusCode = 200;
		response.responseData = [[NSString stringWithFormat:@"<html><body><div>OK - %@</div><div>%@</div></body></html>", request.URL.absoluteString, request.session[@"bar"]] dataUsingEncoding:NSUTF8StringEncoding];
		[response setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
		[connection sendResponse:response];
		return YES;
	}];
	
	[self addRoute:@"/" forHTTPMethod:@"POST" handler:^BOOL(BARConnection *connection, BARRequest *request, NSDictionary *parameters) {
		NSLog(@"Body data: %@", request.body);
		BARResponse *response = [[BARResponse alloc] init];
		response.statusCode = 200;
		response.body = @{@"omg": @"wtf"};
		[connection sendResponse:response];
		return YES;
	}];
}

@end
