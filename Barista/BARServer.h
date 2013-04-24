//
//  BARServer.h
//  Barista
//
//  Created by Steve Streza on 4/23/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BARServer : NSObject

+(instancetype)serverWithBoundHost:(NSString *)host port:(uint16_t)port;
+(instancetype)serverWithPort:(uint16_t)port;

@property (nonatomic, readonly, assign) NSString *boundHost;
@property (nonatomic, readonly, assign) uint16_t port;
@property (nonatomic, assign, getter=isListening) BOOL listening;

@end
