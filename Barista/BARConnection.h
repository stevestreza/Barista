//
//  BARConnection.h
//  Barista
//
//  Created by Steve Streza on 4/23/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "BARRequest.h"

@class BARServer;

@interface BARConnection : NSObject

@property (nonatomic, weak)   BARServer *server;
@property (nonatomic, strong) BARRequest *request;

@end
