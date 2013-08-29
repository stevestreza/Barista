//
//  BARErrorHandler.h
//  Barista
//
//  Created by Grant Butler on 8/29/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import "Barista.h"

@interface BARErrorHandler : NSObject <BaristaMiddleware>

+ (instancetype)errorHandler;

@end
