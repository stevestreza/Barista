//
//  BARRequest.m
//  Barista
//
//  Created by Steve Streza on 4/24/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import "BARRequest.h"

@implementation BARRequest {
	CFHTTPMessageRef message;
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
	NSData *crlf = [[self class] CRLFData];
	NSData *crlfcrlf = [[self class] CRLFCRLFData];
	NSInteger locationOfFirstNewline = [data rangeOfData:crlf     options:0 range:NSMakeRange(0, data.length)].location;
	NSInteger locationOfHeaderEnd    = [data rangeOfData:crlfcrlf options:0 range:NSMakeRange(0, data.length)].location;
	
	// parse the first line, e.g. "GET /foo HTTP/1.1"
	NSData *requestTypeData = [data subdataWithRange:NSMakeRange(0, locationOfFirstNewline)];
	NSString *requestType = [[NSString alloc] initWithData:requestTypeData encoding:NSUTF8StringEncoding];
	NSArray *requestTypePieces = [requestType componentsSeparatedByString:@" "];
	NSString *messageType = requestTypePieces[0];
	NSString *messagePath = requestTypePieces[1];
	NSString *HTTPVersion = requestTypePieces[2];
	
	// parse headers
	NSData *headersData = [data subdataWithRange:NSMakeRange(locationOfFirstNewline + crlf.length, locationOfHeaderEnd - locationOfFirstNewline - crlf.length)];
	NSString *headersString = [[NSString alloc] initWithData:headersData encoding:NSASCIIStringEncoding];
	NSArray *headersList = [headersString componentsSeparatedByString:@"\r\n"];
	
	NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionaryWithCapacity:headersList.count];
	[headersList enumerateObjectsUsingBlock:^(NSString *header, NSUInteger idx, BOOL *stop) {
		NSArray *headerFields = [header componentsSeparatedByString:@": "];
		mutableHeaders[headerFields[0]] = headerFields[1];
	}];
	NSDictionary *headers = [mutableHeaders copy];
	NSString *hostHeader = headers[@"Host"];
	
	NSURL *url = [NSURL URLWithString:messagePath];
	if(!url){
		url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@", hostHeader, messagePath]];
	}
	
	if(self = [super init]){
		message = CFHTTPMessageCreateRequest(NULL, (__bridge CFStringRef)messageType, (__bridge CFURLRef)url, (__bridge CFStringRef)HTTPVersion);
		
		[headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
			CFHTTPMessageSetHeaderFieldValue(message, (__bridge CFStringRef)key, (__bridge CFStringRef)value);
		}];
		
		NSData *bodyData = [data subdataWithRange:NSMakeRange(locationOfHeaderEnd + crlfcrlf.length, data.length - locationOfHeaderEnd - crlfcrlf.length)];
		CFHTTPMessageSetBody(message, (__bridge CFDataRef)bodyData);
	}
	return self;
	
fail:
	return nil;
}

#pragma mark Accessors

-(NSString *)HTTPMethod{
	return (__bridge NSString *)CFHTTPMessageCopyRequestMethod(message);
}

-(NSURL *)URL{
	return (__bridge NSURL *)CFHTTPMessageCopyRequestURL(message);
}

-(NSDictionary *)headerFields{
	return (__bridge NSDictionary *)CFHTTPMessageCopyAllHeaderFields(message);
}

-(NSData *)body{
	return (__bridge NSData *)CFHTTPMessageCopyBody(message);
}

-(NSString *)valueForHeaderField:(NSString *)headerField{
	return (__bridge NSString *)CFHTTPMessageCopyHeaderFieldValue(message, (__bridge CFStringRef)headerField);
}

#pragma mark Convenience Accessors

-(NSString *)userAgent{
	return [self valueForHeaderField:@"User-Agent"];
}

@end
