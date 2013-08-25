//
//  BARCompressor.m
//  Barista
//
//  Created by Steve Streza on 4/28/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import "BARCompressor.h"

#import "BARRequest.h"
#import "BARResponse.h"
#import "BARConnection.h"

#import "NSData+BaristaExtensions.h"

@implementation BARCompressor

+(instancetype)compressor{
	return [[BARCompressor alloc] init];
}

-(void)willSendResponse:(BARResponse *)response
			 forRequest:(BARRequest *)request
		  forConnection:(BARConnection *)connection
		continueHandler:(void (^)(void))handler{
	NSData *data = response.responseData;
	if(data && [self shouldGZipRequest:request]){
		NSData *compressedData = [data barista_gzipDeflate];
		if(compressedData && ![compressedData isEqualToData:data]){
			response.responseData = compressedData;
			[response setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
		}
	}
	
	handler();
}

-(BOOL)shouldGZipRequest:(BARRequest *)request{
	// TODO make this more like the spec
	NSString *acceptEncodingHeader = request.headerFields[@"Accept-Encoding"];
	NSString *acceptHeader = request.headerFields[@"Accept"];
	
	return (acceptEncodingHeader && [acceptEncodingHeader rangeOfString:@"gzip"].location != NSNotFound) || (acceptHeader && [acceptHeader rangeOfString:@"gzip"].location != NSNotFound);
}

@end
