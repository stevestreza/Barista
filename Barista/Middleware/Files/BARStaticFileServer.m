//
//  BARStaticFileServer.m
//  Barista
//
//  Created by Steve Streza on 4/29/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import "BARStaticFileServer.h"

#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h>
#else
#import <CoreServices/CoreServices.h>
#endif

@interface BARStaticFileServer ()

@property (nonatomic, readwrite, strong) NSURL *fileDirectoryURL;
@property (nonatomic, readwrite, strong) NSString *URLBasePath;

@end

@implementation BARStaticFileServer

+(NSString *)mimeTypeForPathExtension:(NSString *)extension{
	CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
	CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
	CFRelease(UTI);
	NSString *MIMETypeString = (__bridge_transfer NSString *)MIMEType;
	return MIMETypeString;
}

+(instancetype)fileServerWithDirectoryURL:(NSURL *)url forURLBasePath:(NSString *)path{
	BARStaticFileServer *server = [[self alloc] init];
	server.fileDirectoryURL = url;
	server.URLBasePath = path;
	return server;
}

-(void)didReceiveRequest:(BARRequest *)request forConnection:(BARConnection *)connection continueHandler:(void (^)(void))handler{
	if([request.URL.path rangeOfString:self.URLBasePath].location == 0){
		NSString *relativePath = [request.URL.path stringByReplacingOccurrencesOfString:self.URLBasePath withString:@"" options:0 range:NSMakeRange(0, self.URLBasePath.length)];
		NSURL *fileURL = [self.fileDirectoryURL URLByAppendingPathComponent:relativePath];
		
		NSString *etag = [[self class] eTagForFileAtURL:fileURL];
		BARResponse *response = [[BARResponse alloc] init];

		if([[request valueForHeaderField:@"If-None-Match"] isEqualToString:etag]){
			response.statusCode = 304;
		}else{
			response.statusCode = 200;
			[response setValue:[[self class] mimeTypeForPathExtension:[fileURL pathExtension]] forHTTPHeaderField:@"Content-Type"];
			[response setValue:etag forHTTPHeaderField:@"ETag"];
			response.responseData = [[[NSFileManager alloc] init] contentsAtPath:fileURL.path];
		}
		[connection sendResponse:response];
	}else{
		handler();
	}
}

+(NSString *)eTagForFileAtURL:(NSURL *)fileURL{
	NSFileManager *fm = [[NSFileManager alloc] init];
	NSDictionary *attributes = [fm attributesOfItemAtPath:fileURL.path error:nil];
	NSTimeInterval time = [attributes[NSFileModificationDate] timeIntervalSince1970];
	NSString *timeString = [NSString stringWithFormat:@"%li", (NSUInteger)(time)];
	return timeString;
}

@end
