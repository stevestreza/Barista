//
//  BARTemplateRenderer.m
//  Barista
//
//  Created by Steve Streza on 4/29/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import "BARTemplateRenderer.h"

@implementation BARTemplateRenderer

@end

@implementation BARResponse (BARTemplateSupport)

-(void)setViewToRender:(NSString *)view withObject:(id)object{
	[self setCustomValue:view forKey:@"BARTemplateView"];
	[self setCustomValue:object forKey:@"BARTemplateViewObject"];
}

@end
