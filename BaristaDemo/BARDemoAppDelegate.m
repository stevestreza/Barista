//
//  BARAppDelegate.m
//  BaristaDemo
//
//  Created by Steve Streza on 4/29/13.
//  Copyright (c) 2013 Mustacheware. All rights reserved.
//

#import "BARDemoAppDelegate.h"
#import "BARDemoServer.h"

@implementation BARDemoAppDelegate {
	BARDemoServer *server;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	server = [BARDemoServer serverWithPort:3333];
	server.listening = YES;
}

@end
