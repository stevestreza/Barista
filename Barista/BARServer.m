//
//  BARServer.m
//  Barista
//
//  Created by Steve Streza on 4/23/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import "BARServer.h"

#import "BARConnection.h"
#import "GCDAsyncSocket.h"

@interface BARConnection (BARServer)

+(instancetype)connectionWithIncomingSocket:(GCDAsyncSocket *)socket server:(BARServer *)server;

@end

@implementation BARServer {
	GCDAsyncSocket *_socket;
	NSMutableArray *_connections;
}

+(instancetype)serverWithBoundHost:(NSString *)host port:(uint16_t)port{
	return [[self alloc] initWithBoundHost:host port:port];
}

+(instancetype)serverWithPort:(uint16_t)port{
	return [self serverWithBoundHost:nil port:port];
}

-(instancetype)initWithBoundHost:(NSString *)boundHost port:(uint16_t)port{
	if(self = [super init]){
		_boundHost = boundHost;
		_port = port;
	}
	return self;
}

-(BOOL)isListening{
	return NO;
}

-(void)setListening:(BOOL)listening{
	if(listening == [self isListening]) return;
	
	if(listening) {
		if(!_socket){
			_socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
		}
		NSError *error = nil;
		_socket.delegate = self;
		if(![_socket acceptOnInterface:self.boundHost port:self.port error:&error]){
			NSLog(@"Couldn't start socket: %@", error);
		}else{
			NSLog(@"Listening on %i", self.port);
		}
	}
}

#pragma mark Sockets

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
	NSLog(@"Socket");
	if(!_connections){
		_connections = [NSMutableArray array];
	}
	
	BARConnection *connection = [BARConnection connectionWithIncomingSocket:newSocket server:self];
	[_connections addObject:connection];
	
//	NSString *response = @"HTTP/1.0 200\nContent-Length: 2\n\nOK\n\n";
//	[newSocket writeData:[response dataUsingEncoding:NSUTF8StringEncoding] withTimeout:30 tag:0];
}

@end
