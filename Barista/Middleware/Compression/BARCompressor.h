//
//  BARCompressor.h
//  Barista
//
//  Created by Steve Streza on 4/28/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BaristaTypes.h"

@interface BARCompressor : NSObject <BaristaMiddleware>

+(instancetype)compressor;

@end
