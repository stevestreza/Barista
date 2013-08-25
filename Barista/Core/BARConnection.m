//
//  BARConnection.m
//  Barista
//
//  Created by Steve Streza on 4/23/13.
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

#import "BARConnection.h"
#import "BARServer.h"

@implementation BARConnection {
	GCDAsyncSocket *_socket;
	__weak BARServer *_server;
}

@synthesize server=_server;

+(instancetype)connectionWithIncomingSocket:(GCDAsyncSocket *)socket server:(BARServer *)server{
	return [[self alloc] initWithIncomingSocket:socket server:server];
}

-(instancetype)initWithIncomingSocket:(GCDAsyncSocket *)socket server:(BARServer *)server{
	if(self = [super init]){
		_server = server;
		_socket = socket;
		_socket.delegate = self;
		
		[self startConnection];
	}
	return self;
}

-(void)startConnection{
	[_socket readDataWithTimeout:10 tag:1];
}

#pragma mark Response

-(void)sendResponse:(BARResponse *)response{
	[self.server connection:self willSendResponse:response forRequest:self.request handler:^{
		CFHTTPMessageRef message = response.message;
		NSData *data = (__bridge NSData *)CFHTTPMessageCopySerializedMessage(message);
//		NSString *contents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//		NSLog(@"Sending response:\n%@",contents);
		[_socket writeData:data withTimeout:5 tag:0];
	}];
}

#pragma mark GCDAsyncSocketDelegate

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
	_request = [BARRequest requestFromData:data];
//	NSLog(@"Request: %@", _request);
//	NSLog(@"-- parts:\n%@\n%@\n%@\n%@\n%@", _request.HTTPMethod, _request.URL, [_request userAgent], _request.bodyData, _request.headerFields);
	[self.server connection:self didReceiveRequest:_request];
}

/**
 * Called when a socket has read in data, but has not yet completed the read.
 * This would occur if using readToData: or readToLength: methods.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
	NSLog(@"Some data %li", (unsigned long)partialLength);
}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
	NSLog(@"Wrote");
}

/**
 * Called when a socket has written some data, but has not yet completed the entire write.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
	NSLog(@"Wrote some %li", partialLength);
}

/**
 * Conditionally called if the read stream closes, but the write stream may still be writeable.
 *
 * This delegate method is only called if autoDisconnectOnClosedReadStream has been set to NO.
 * See the discussion on the autoDisconnectOnClosedReadStream method for more information.
 **/
- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock{
	NSLog(@"Closed read");
}

/**
 * Called when a socket disconnects with or without error.
 *
 * If you call the disconnect method, and the socket wasn't already disconnected,
 * this delegate method will be called before the disconnect method returns.
 **/
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
	NSLog(@"Disconnected");
}

@end
