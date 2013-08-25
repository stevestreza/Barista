//
//  BARMustacheTemplate.m
//  Barista
//
//  Created by Steve Streza on 4/29/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import "BARMustacheTemplateRenderer.h"
#import <GRMustache/GRMustache.h>

@interface BARMustacheTemplateRenderer ()

@property (nonatomic, readwrite, copy) NSURL *viewsDirectoryURL;

@end

@implementation BARMustacheTemplateRenderer

+(instancetype)rendererWithViewsDirectoryURL:(NSURL *)url{
	BARMustacheTemplateRenderer *renderer = [[self alloc] init];
	renderer.viewsDirectoryURL = url;
	return renderer;
}

+(NSString *)templateFileExtension{
	return @"mustache";
}

-(void)willSendResponse:(BARResponse *)response forRequest:(BARRequest *)request forConnection:(BARConnection *)connection continueHandler:(void (^)(void))handler{
	NSString *viewName = [response customValueForKey:@"BARTemplateView"];
	id object = [response customValueForKey:@"BARTemplateViewObject"];
	if(viewName){
		NSURL *viewURL = [[self.viewsDirectoryURL URLByAppendingPathComponent:viewName] URLByAppendingPathExtension:[[self class] templateFileExtension]];

		GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfURL:viewURL error:nil];

		NSString *content = [template renderObject:object error:nil];
		NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
		response.responseData = contentData;
	}
	handler();
}

@end
