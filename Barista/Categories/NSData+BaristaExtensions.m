//
//  NSData+BaristaExtensions.m
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

#import "NSData+BaristaExtensions.h"
#import <CommonCrypto/CommonCrypto.h>
#include <zlib.h>

@implementation NSData (BaristaExtensions)

- (NSData *)barista_zlibInflate
{
 	if ([self length] == 0) return self;
	
 	unsigned full_length = (uInt)[self length];
 	unsigned half_length = (uInt)[self length] / 2;
	
 	NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
 	BOOL done = NO;
 	int status;
	
 	z_stream strm;
 	strm.next_in = (Bytef *)[self bytes];
 	strm.avail_in = (uInt)[self length];
 	strm.total_out = 0;
 	strm.zalloc = Z_NULL;
 	strm.zfree = Z_NULL;
	
 	if (inflateInit (&strm) != Z_OK) return nil;
	
 	while (!done)
 	{
 		// Make sure we have enough room and reset the lengths.
 		if (strm.total_out >= [decompressed length])
 			[decompressed increaseLengthBy: half_length];
 		strm.next_out = [decompressed mutableBytes] + strm.total_out;
 		strm.avail_out = [decompressed length] - strm.total_out;
		
 		// Inflate another chunk.
 		status = inflate (&strm, Z_SYNC_FLUSH);
 		if (status == Z_STREAM_END) done = YES;
 		else if (status != Z_OK) break;
 	}
 	if (inflateEnd (&strm) != Z_OK) return nil;
	
 	// Set real length.
 	if (done)
 	{
 		[decompressed setLength: strm.total_out];
 		return [NSData dataWithData: decompressed];
 	}
 	else return nil;
}

- (NSData *)barista_zlibDeflate
{
 	if ([self length] == 0) return self;
 	
 	z_stream strm;
	
 	strm.zalloc = Z_NULL;
 	strm.zfree = Z_NULL;
 	strm.opaque = Z_NULL;
 	strm.total_out = 0;
 	strm.next_in=(Bytef *)[self bytes];
 	strm.avail_in = [self length];
	
 	// Compresssion Levels:
 	//   Z_NO_COMPRESSION
 	//   Z_BEST_SPEED
 	//   Z_BEST_COMPRESSION
 	//   Z_DEFAULT_COMPRESSION
	
 	if (deflateInit(&strm, Z_DEFAULT_COMPRESSION) != Z_OK) return nil;
	
 	NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chuncks for expansion
	
 	do {
		
 		if (strm.total_out >= [compressed length])
 			[compressed increaseLengthBy: 16384];
 		
 		strm.next_out = [compressed mutableBytes] + strm.total_out;
 		strm.avail_out = [compressed length] - strm.total_out;
 		
 		deflate(&strm, Z_FINISH);
 		
 	} while (strm.avail_out == 0);
 	
 	deflateEnd(&strm);
 	
 	[compressed setLength: strm.total_out];
 	return [NSData dataWithData: compressed];
}

- (NSData *)barista_gzipInflate
{
 	if ([self length] == 0) return self;
 	
 	unsigned full_length = [self length];
 	unsigned half_length = [self length] / 2;
 	
 	NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
 	BOOL done = NO;
 	int status;
 	
 	z_stream strm;
 	strm.next_in = (Bytef *)[self bytes];
 	strm.avail_in = [self length];
 	strm.total_out = 0;
 	strm.zalloc = Z_NULL;
 	strm.zfree = Z_NULL;
 	
 	if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
 	while (!done)
 	{
 		// Make sure we have enough room and reset the lengths.
 		if (strm.total_out >= [decompressed length])
 			[decompressed increaseLengthBy: half_length];
 		strm.next_out = [decompressed mutableBytes] + strm.total_out;
 		strm.avail_out = [decompressed length] - strm.total_out;
 		
 		// Inflate another chunk.
 		status = inflate (&strm, Z_SYNC_FLUSH);
 		if (status == Z_STREAM_END) done = YES;
 		else if (status != Z_OK) break;
 	}
 	if (inflateEnd (&strm) != Z_OK) return nil;
 	
 	// Set real length.
 	if (done)
 	{
 		[decompressed setLength: strm.total_out];
 		return [NSData dataWithData: decompressed];
 	}
 	else return nil;
}

- (NSData *)barista_gzipDeflate
{
 	if ([self length] == 0) return self;
 	
 	z_stream strm;
 	
 	strm.zalloc = Z_NULL;
 	strm.zfree = Z_NULL;
 	strm.opaque = Z_NULL;
 	strm.total_out = 0;
 	strm.next_in=(Bytef *)[self bytes];
 	strm.avail_in = (unsigned int)[self length];
 	
 	// Compresssion Levels:
 	//   Z_NO_COMPRESSION
 	//   Z_BEST_SPEED
 	//   Z_BEST_COMPRESSION
 	//   Z_DEFAULT_COMPRESSION
 	
 	if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
 	
 	NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
 	
 	do {
 		
 		if (strm.total_out >= [compressed length])
 			[compressed increaseLengthBy: 16384];
 		
 		strm.next_out = [compressed mutableBytes] + strm.total_out;
 		strm.avail_out = (unsigned int)([compressed length] - strm.total_out);
 		
 		deflate(&strm, Z_FINISH);
 		
 	} while (strm.avail_out == 0);
 	
 	deflateEnd(&strm);
 	
 	[compressed setLength: strm.total_out];
 	return [NSData dataWithData:compressed];
}

- (NSData*)barista_md5Digest
{
	return nil;
}

- (NSString*)barista_md5DigestString
{
	return nil;
}

- (NSData*)barista_sha1Digest
{
	return nil;
}

- (NSString*)barista_sha1DigestString
{
	return nil;
}

@end
