//
//  BARRouter.h
//  Barista
//
//  Created by Grant Butler on 8/25/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Barista.h"

@interface BARRouter : NSObject <BaristaMiddleware>

-(void)addRoute:(NSString *)route forHTTPMethod:(NSString *)method handler:(BOOL (^)(BARConnection *connection, BARRequest *request, NSDictionary *parameters))handler;

@end
