//
//  BARAppDelegate.m
//  BaristaDemo
//
//  Created by Steve Streza on 4/29/13.
//  Copyright (c) 2013: Steve Streza
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "BARDemoAppDelegate.h"

@implementation BARDemoAppDelegate {
	BARServer *server;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	server = [BARServer serverWithPort:3333];
	
	NSURL *webAppURL = [[NSBundle mainBundle] URLForResource:@"WebApp" withExtension:@""];
	
	[server addGlobalMiddleware:[BARCookieParser cookieParser]];
	[server addGlobalMiddleware:[BARSessionStore sessionStoreWithCookieBaseName:@"_streamers"]];
	[server addGlobalMiddleware:[BARCompressor compressor]];
	[server addGlobalMiddleware:[BARStaticFileServer fileServerWithDirectoryURL:[webAppURL  URLByAppendingPathComponent:@"public"]
															   forURLBasePath:@"/public/"]];
	[server addGlobalMiddleware:[[BARBodyParser alloc] init]];
	[server addGlobalMiddleware:[BARMustacheTemplateRenderer rendererWithViewsDirectoryURL:[webAppURL URLByAppendingPathComponent:@"views"]]];
	[server addGlobalMiddleware:[[BARBasicAuthentication alloc] initWithRealm:@"unicorn / rainbows" authorizationBlock:^BOOL(NSURLCredential *credential) {
		BOOL authorized = YES;
		authorized &= [credential.user isEqualToString:@"unicorn"];
		authorized &= [credential.password isEqualToString:@"rainbows"];
		return authorized;
	}]];
	
	BARRouter *router = [[BARRouter alloc] init];
	[server addGlobalMiddleware:router];
		
	[router addRoute:@"/foo/:bar" forHTTPMethod:@"GET" handler:^BOOL(BARConnection *connection, BARRequest *request, NSDictionary *parameters) {
		NSLog(@"/foo/:bar parameters: %@", parameters);
		request.session[@"bar"] = parameters[@"bar"];
		BARResponse *response = [[BARResponse alloc] init];
		response.statusCode = 200;
		response.responseData = [[NSString stringWithFormat:@"Sup. I'm foo. Here's your thing - %@", parameters[@"bar"]] dataUsingEncoding:NSUTF8StringEncoding];
		[connection sendResponse:response];
		return YES;
	}];
	
	[router addRoute:@"/testViews" forHTTPMethod:@"GET" handler:^BOOL(BARConnection *connection, BARRequest *request, NSDictionary *parameters) {
		
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
	
	[router addRoute:@"/" forHTTPMethod:@"GET" handler:^BOOL(BARConnection *connection, BARRequest *request, NSDictionary *parameters) {
		NSLog(@"/ parameters: %@", parameters);
		NSLog(@"Session: %@", request.session[@"bar"]);
		BARResponse *response = [[BARResponse alloc] init];
		response.statusCode = 200;
		response.responseData = [[NSString stringWithFormat:@"<html><body><div>OK - %@</div><div>%@</div></body></html>", request.URL.absoluteString, request.session[@"bar"]] dataUsingEncoding:NSUTF8StringEncoding];
		[response setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
		[connection sendResponse:response];
		return YES;
	}];
	
	[router addRoute:@"/" forHTTPMethod:@"POST" handler:^BOOL(BARConnection *connection, BARRequest *request, NSDictionary *parameters) {
		NSLog(@"Body data: %@", request.body);
		BARResponse *response = [[BARResponse alloc] init];
		response.statusCode = 200;
		response.body = @{@"omg": @"wtf"};
		[connection sendResponse:response];
		return YES;
	}];
	
	server.listening = YES;
}

@end
