//
//  BARRequest.m
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

#import "BARRequest.h"

@implementation BARRequest {
	CFHTTPMessageRef message;
	NSMutableDictionary *_customValues;
}

+(NSData *)CRLFData{
	static NSData *sCRLFData = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sCRLFData = [@"\r\n" dataUsingEncoding:NSASCIIStringEncoding];
	});
	return sCRLFData;
}

+(NSData *)CRLFCRLFData{
	static NSData *sCRLFData = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sCRLFData = [@"\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding];
	});
	return sCRLFData;
}

+(instancetype)requestFromData:(NSData *)data{
	return [[self alloc] initFromData:data];
}

-(instancetype)initFromData:(NSData *)data{
	NSString *textData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"Received request\n-\n%@\n-", textData);
	
	if(self = [super init]){
		message = CFHTTPMessageCreateEmpty(NULL, YES);
		CFHTTPMessageAppendBytes(message, [data bytes], [data length]);
	}
	return self;
}

- (void)appendRequestData:(NSData *)data {
	CFHTTPMessageAppendBytes(message, [data bytes], [data length]);
}

#pragma mark Accessors

-(NSString *)HTTPMethod{
	CFStringRef HTTPMethodRef = CFHTTPMessageCopyRequestMethod(message);
	NSString *HTTPMethod = (__bridge NSString *)HTTPMethodRef;
	CFRelease(HTTPMethodRef);
	return HTTPMethod;
}

-(NSURL *)URL{
	CFURLRef URLRef = CFHTTPMessageCopyRequestURL(message);
	NSURL *URL = (__bridge NSURL *)URLRef;
	CFRelease(URLRef);
	return URL;
}

-(NSDictionary *)headerFields{
	CFDictionaryRef headerFieldsRef = CFHTTPMessageCopyAllHeaderFields(message);
	NSDictionary *headerFields = (__bridge NSDictionary *)headerFieldsRef;
	CFRelease(headerFieldsRef);
	return headerFields;
}

-(NSData *)bodyData{
	CFDataRef bodyDataRef = CFHTTPMessageCopyBody(message);
	NSData *bodyData = (__bridge NSData *)bodyDataRef;
	CFRelease(bodyDataRef);
	return bodyData;
}

-(NSString *)valueForHeaderField:(NSString *)headerField{
	CFStringRef headerValueRef = CFHTTPMessageCopyHeaderFieldValue(message, (__bridge CFStringRef)headerField);
	NSString *headerValue = (__bridge NSString *)headerValueRef;
	CFRelease(headerValueRef);
	return headerValue;
}

#pragma mark Convenience Accessors

-(NSString *)userAgent{
	return [self valueForHeaderField:@"User-Agent"];
}

@end

@implementation BARRequest (BARExtensionSupport)

-(id)customValueForKey:(NSString *)key{
	return _customValues[key];
}

-(void)setCustomValue:(id)value forKey:(NSString *)key{
	if(!_customValues){
		_customValues = [NSMutableDictionary dictionary];
	}
	
	if(value){
		_customValues[key] = value;
	}else{
		[_customValues removeObjectForKey:key];
	}
}

@end
