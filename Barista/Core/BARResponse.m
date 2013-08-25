//
//  BARResponse.m
//  Barista
//
//  Created by Steve Streza on 4/24/13.
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

#import "BARResponse.h"

@implementation BARResponse {
	NSMutableDictionary *_customValues;
}

+(instancetype)responseWithRequest:(BARRequest *)request connection:(BARConnection *)connection{
	return [[self alloc] initWithRequest:request connection:connection];
}

-(instancetype)initWithRequest:(BARRequest *)request connection:(BARConnection *)connection{
	if(self = [super init]){
		_request = request;
		_connection = connection;
	}
	return self;
}

-(void)setValue:(id)value forHTTPHeaderField:(NSString *)field{
	if(!_headers){
		_headers = [NSMutableDictionary dictionary];
	}
	
	((NSMutableDictionary *)(_headers))[field] = value;
}

-(void)send{
	
}

-(CFHTTPMessageRef)message{
	CFHTTPMessageRef message = CFHTTPMessageCreateResponse(NULL, _statusCode, CFSTR(""), kCFHTTPVersion1_1);
	[self.headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
		CFHTTPMessageSetHeaderFieldValue(message, (__bridge CFStringRef)key, (__bridge CFStringRef)value);
	}];
	
	if(!self.headers[@"Connection"]){
		CFHTTPMessageSetHeaderFieldValue(message, (__bridge CFStringRef)@"Connection", (__bridge CFStringRef)@"close");
	}

	CFHTTPMessageSetHeaderFieldValue(message, (__bridge CFStringRef)@"Content-Length", (__bridge CFStringRef)[NSString stringWithFormat:@"%li", self.responseData.length]);
	CFHTTPMessageSetBody(message, (__bridge CFDataRef)self.responseData);
	
	return message;
}

//-(NSData *)responseData{
//	if(!_responseData){
//		if(self.response){
//			id responseData = nil;
//			if([self.response isKindOfClass:[NSData class]]){
//				responseData = self.response;
//			}else if([self.response isKindOfClass:[NSString class]]){
//				responseData = self.response;
//			}else{
//				responseData = [self.response description];
//			}
//			
//			if([responseData isKindOfClass:[NSString class]]){
//				NSStringEncoding encoding = [self desiredStringEncoding];
//				responseData = [(NSString *)responseData dataUsingEncoding:encoding];
//			}
//			_responseData = (NSData *)responseData;
//		}
//	}
//	
//	return _responseData;
//}



-(NSStringEncoding)desiredStringEncoding{
	NSStringEncoding encoding = NSUTF8StringEncoding;
	
	return encoding;
}

@end

@implementation BARResponse (BARExtensionSupport)

-(id)customValueForKey:(NSString *)key{
	return _customValues[key];
}

-(void)setCustomValue:(id)value forKey:(NSString *)key{
	if(!_customValues){
		_customValues = [NSMutableDictionary dictionary];
	}
	
	_customValues[key] = value;
}

@end
