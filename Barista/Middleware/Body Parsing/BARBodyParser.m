//
//  BARBodyParser.m
//  Barista
//
//  Created by Steve Streza on 4/28/13.
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
