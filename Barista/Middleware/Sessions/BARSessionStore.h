//
//  BARSessionStore.h
//  Barista
//
//  Created by Steve Streza on 4/28/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaristaTypes.h"

@interface BARSessionStore : NSObject <BaristaMiddleware>

+(instancetype)sessionStoreWithCookieBaseName:(NSString *)cookieBaseName;

@property (nonatomic, strong) NSString *cookieBaseName;

@end
