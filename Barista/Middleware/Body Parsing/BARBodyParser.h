//
//  BARBodyParser.h
//  Barista
//
//  Created by Steve Streza on 4/28/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BaristaTypes.h"

#import "BARRequest.h"
#import "BARResponse.h"
#import "BARConnection.h"

@interface BARBodyParser : NSObject <BaristaMiddleware>

@end

@interface BARRequest (BARBodyParsing)

@property (nonatomic, strong) id body;

@end

@interface BARResponse (BARBodyParsing)

@property (nonatomic, strong) id body;

@end
