//
//  BaristaTypes.h
//  Barista
//
//  Created by Steve Streza on 4/28/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BARServer;
@class BARRequest;
@class BARResponse;
@class BARConnection;

@protocol BaristaMiddleware <NSObject>
@optional

// Intercept an inflight request before it is handled normally.
// You can use this to add metadata to requests before they are handed
// off, or filter requests. To continue processing, call the
// continueHandler. To abort processing, don't call the handler.
// If you don't call the handler, you are responsible for closing the
// connection and returning some data.

-(void)didReceiveRequest:(BARRequest *)request
		   forConnection:(BARConnection *)connection
		 continueHandler:(void (^)(void))handler;

-(void)willSendResponse:(BARResponse *)response
			 forRequest:(BARRequest *)request
		  forConnection:(BARConnection *)connection
		continueHandler:(void (^)(void))handler;

@end


@protocol BaristaKeyedSubscripting <NSObject>

@required

-(id)objectForKeyedSubscript:(id)key;
-(void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key;

@end

@protocol BaristaIndexedSubscripting <NSObject>

@required

@end