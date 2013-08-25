//
//  BaristaTypes.h
//  Barista
//
//  Created by Steve Streza on 4/28/13.
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

#import <Foundation/Foundation.h>

@class BARServer;
@class BARRequest;
@class BARResponse;
@class BARConnection;

@protocol BaristaMiddleware <NSObject>
@optional

// Intercept an inflight request before it is handled normally.
// You can use this to add metadata to requests before they are handed
// off, or filter requests. To continue processing, call the
// continueHandler. To abort processing, don't call the handler.
// If you don't call the handler, you are responsible for closing the
// connection and returning some data.

-(void)didReceiveRequest:(BARRequest *)request
		   forConnection:(BARConnection *)connection
		 continueHandler:(void (^)(void))handler;

-(void)willSendResponse:(BARResponse *)response
			 forRequest:(BARRequest *)request
		  forConnection:(BARConnection *)connection
		continueHandler:(void (^)(void))handler;

@end


@protocol BaristaKeyedSubscripting <NSObject>

@required

-(id)objectForKeyedSubscript:(id)key;
-(void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key;

@end

@protocol BaristaIndexedSubscripting <NSObject>

@required

@end