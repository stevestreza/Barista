//
//  BARBodyParser.m
//  Barista
//
//  Created by Steve Streza on 4/28/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import "BARBodyParser.h"

@implementation BARBodyParser

-(void)didReceiveRequest:(BARRequest *)request
		   forConnection:(BARConnection *)connection
		 continueHandler:(void (^)(void))handler{

	NSString *contentTypeHeader = request.headerFields[@"Content-Type"];
	if([contentTypeHeader isEqualToString:@"application/json"]){
		NSData *data = request.bodyData;
		NSError *error = nil;
		id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		request.body = object;
	}
	
	handler();
}

-(void)willSendResponse:(BARResponse *)response
			 forRequest:(BARRequest *)request
		  forConnection:(BARConnection *)connection
		continueHandler:(void (^)(void))handler{
	NSString *acceptHeader = request.headerFields[@"Accept"];
	if([acceptHeader isEqualToString:@"application/json"]){
		NSData *data = [NSJSONSerialization dataWithJSONObject:response.body options:0 error:nil];
		if(data){
			[response setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
			response.responseData = data;
		}
	}
	
	handler();
}

@end


@implementation BARRequest (BARBodyParsing)

-(id)body{
	return [self customValueForKey:@"BARParsedBody"];
}

-(void)setBody:(id)body{
	[self setCustomValue:body forKey:@"BARParsedBody"];
}

@end

@implementation BARResponse (BARBodyParsing)

-(id)body{
	return [self customValueForKey:@"BARParsedBody"];
}

-(void)setBody:(id)body{
	[self setCustomValue:body forKey:@"BARParsedBody"];
}

@end
