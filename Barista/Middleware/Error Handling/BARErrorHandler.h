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

/// Whether or not a stack trace is sent back to the browser. Defaults to NO.
/// If a custom exception handler is set, this property does nothing.
@property (nonatomic) BOOL showsStackTrace;

/// Allows for custom handling on an exception. If this is nil, the exception that has been caught will be re-raised.
@property (nonatomic, copy) void(^exceptionHandler)(BARRequest *request, BARConnection *connection, NSException *exception);

@end
