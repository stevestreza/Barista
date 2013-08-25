//
//  BARSession.h
//  Barista
//
//  Created by Steve Streza on 4/28/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaristaTypes.h"
#import "BARRequest.h"

@interface BARSession : NSObject <BaristaKeyedSubscripting>

+(instancetype)sessionFromHTTPCookie:(NSHTTPCookie *)cookie;
+(instancetype)session;

-(NSHTTPCookie *)cookieWithName:(NSString *)name forRequest:(BARRequest *)request;

@property (nonatomic, strong) NSString *identifier;

@end

@interface BARRequest (BARSessionSupport)

-(BARSession *)session;

@end