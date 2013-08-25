//
//  BARStaticFileServer.m
//  Barista
//
//  Created by Steve Streza on 4/29/13.
//  Copyright (c) 2013: Steve Streza
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
			NSString *mimeType = [[self class] mimeTypeForPathExtension:[fileURL pathExtension]];
			if(mimeType){
				[response setValue:mimeType forHTTPHeaderField:@"Content-Type"];
			}
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
