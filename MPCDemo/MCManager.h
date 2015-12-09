//
//  MCManager.h
//  MPCDemo
//
//  Created by Fred on 30/03/2015.
//  Copyright (c) 2015 Fred. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MCManager : NSObject <MCSessionDelegate>

@property (nonatomic, strong) MCPeerID *myPeerID;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCBrowserViewController *browser;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;
@property (nonatomic) BOOL isConnected;

+ (instancetype)sharedMCManager;

-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName;
-(void)advertiseSelf:(BOOL)shouldAdvertise;
-(void)findNearlyPeers:(id)vc;
-(MCPeerID*)findPeerFromTitle:(NSString*)name;

@end
