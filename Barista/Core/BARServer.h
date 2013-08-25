//
//  BARServer.h
//  Barista
//
//  Created by Steve Streza on 4/23/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BARConnection.h"
#import "BaristaTypes.h"
#import "JLRoutes.h"

@interface BARServer : NSObject

+(instancetype)serverWithBoundHost:(NSString *)host port:(uint16_t)port;
+(instancetype)serverWithPort:(uint16_t)port;

@property (nonatomic, readonly, assign) NSString *boundHost;
@property (nonatomic, readonly, assign) uint16_t port;
@property (nonatomic, assign, getter=isListening) BOOL listening;

-(BOOL)startListening;
-(BOOL)stopListening;

#pragma mark Routes

-(void)setupRoutes;

-(void)addRoute:(NSString *)route forHTTPMethod:(NSString *)method handler:(BOOL (^)(BARConnection *connection, BARRequest *request, NSDictionary *parameters))handler;

#pragma mark Middleware

-(void)addGlobalMiddleware:(id<BaristaMiddleware>)middleware;
-(NSArray *)globalMiddleware;

-(void)connection:(BARConnection *)connection didReceiveRequest:(BARRequest *)request;
-(void)connection:(BARConnection *)connection willSendResponse:(BARResponse *)response forRequest:(BARRequest *)request handler:(void (^)(void))handler;

@end
