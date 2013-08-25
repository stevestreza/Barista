//
//  BARResponse.h
//  Barista
//
//  Created by Steve Streza on 4/24/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BARRequest;
@class BARConnection;

@interface BARResponse : NSObject

@property (nonatomic, readonly) CFHTTPMessageRef message;

@property (nonatomic, assign) NSUInteger statusCode;
@property (nonatomic, strong) NSData *responseData;
@property (nonatomic, strong) NSDictionary *headers;

@property (nonatomic, weak, readonly) BARRequest *request;
@property (nonatomic, weak, readonly) BARConnection *connection;

-(void)setValue:(id)value forHTTPHeaderField:(NSString *)field;
-(void)send;

@end


#pragma mark Extensions

@interface BARResponse (BARExtensionSupport)

-(id)customValueForKey:(NSString *)key;
-(void)setCustomValue:(id)value forKey:(NSString *)key;

@end
