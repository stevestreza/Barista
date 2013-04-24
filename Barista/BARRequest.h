//
//  BARRequest.h
//  Barista
//
//  Created by Steve Streza on 4/24/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BARRequest : NSObject

+(instancetype)requestFromData:(NSData *)data;

@property (nonatomic, readonly, copy) NSString *HTTPMethod;
@property (nonatomic, readonly, copy) NSURL *URL;
@property (nonatomic, readonly, copy) NSDictionary *headerFields;
@property (nonatomic, readonly, copy) NSData *body;

-(NSString *)valueForHeaderField:(NSString *)headerField;

-(NSString *)userAgent;

@end
