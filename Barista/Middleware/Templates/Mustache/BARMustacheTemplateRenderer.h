//
//  BARMustacheTemplate.h
//  Barista
//
//  Created by Steve Streza on 4/29/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import "BARTemplateRenderer.h"

@interface BARMustacheTemplateRenderer : BARTemplateRenderer

+(instancetype)rendererWithViewsDirectoryURL:(NSURL *)url;

@property (nonatomic, readonly, copy) NSURL *viewsDirectoryURL;

@end
