//
//  BARCookieParser.h
//  Barista
//
//  Created by Steve Streza on 4/28/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BaristaTypes.h"
#import "BARRequest.h"
#import "BARResponse.h"

@interface BARCookieParser : NSObject <BaristaMiddleware>

+(instancetype)cookieParser;

@end

@interface BARRequest (BARCookies)

@property (nonatomic, strong) NSArray *cookies;

-(NSHTTPCookie *)cookieNamed:(NSString *)name;
-(NSArray *)cookiesMatchingBaseName:(NSString *)baseName;

@end

@interface BARResponse (BARCookies)

-(NSArray *)cookies;
-(void)addCookie:(NSHTTPCookie *)cookie;
-(void)addCookiesFromRequest:(BARRequest *)request;

@end
