//
//  BARStaticFileServer.h
//  Barista
//
//  Created by Steve Streza on 4/29/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Barista.h"

@interface BARStaticFileServer : NSObject <BaristaMiddleware>

+(instancetype)fileServerWithDirectoryURL:(NSURL *)url forURLBasePath:(NSString *)path;

@property (nonatomic, strong, readonly) NSURL *fileDirectoryURL;
@property (nonatomic, strong, readonly) NSString *URLBasePath;

@end
