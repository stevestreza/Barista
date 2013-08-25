//
//  BARCompressor.m
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
