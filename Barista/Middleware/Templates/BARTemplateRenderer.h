//
//  BARTemplateRenderer.h
//  Barista
//
//  Created by Steve Streza on 4/29/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BaristaTypes.h"

#import "BARRequest.h"
#import "BARResponse.h"
#import "BARConnection.h"

@interface BARTemplateRenderer : NSObject <BaristaMiddleware>

@end

@interface BARResponse (BARTemplateSupport)

-(void)setViewToRender:(NSString *)view withObject:(id)object;

@end
