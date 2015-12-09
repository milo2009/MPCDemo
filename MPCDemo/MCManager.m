//
//  MCManager.m
//  MPCDemo
//
//  Created by Fred on 30/11/2015.
//  Copyright (c) 2015 Fred. All rights reserved.
//

#import "MCManager.h"
#define ServiceType @"MPC-message"

@implementation MCManager

+ (instancetype)sharedMCManager
{
    static MCManager *sharedMCManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMCManager = [[MCManager alloc] init];
    });
    return sharedMCManager;
}

-(id)init{
    self = [super init];
    
    if (self) {
        [self initManager];
    }
    
    return self;
}

#pragma mark - private method implementation
-(void) initManager{
    _myPeerID = nil;
    _session = nil;
    _browser = nil;
    _advertiser = nil;
    
    [self setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
    [self advertiseSelf:YES];
}

#pragma mark - Public method implementation

-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName{
    _myPeerID = [[MCPeerID alloc] initWithDisplayName:displayName];
    
    _session = [[MCSession alloc] initWithPeer:_myPeerID];
    _session.delegate = self;
}

-(void)advertiseSelf:(BOOL)shouldAdvertise{
    if (shouldAdvertise) {
        _advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:ServiceType
                                                           discoveryInfo:nil
                                                                 session:_session];
        [_advertiser start];
    }
    else{
        [_advertiser stop];
        _advertiser = nil;
    }
}

- (void)findNearlyPeers:(id)vc{
    _browser = [[MCBrowserViewController alloc] initWithServiceType:ServiceType
                                                            session:_session];
    _browser.minimumNumberOfPeers = 2;
    _browser.maximumNumberOfPeers = 2;
    _browser.delegate = vc;
    
    [vc presentViewController:_browser
                     animated:YES
                   completion:nil];
}

- (MCPeerID*)findPeerFromTitle:(NSString*)name{
    for (MCPeerID *peer in _session.connectedPeers) {
        if([peer.displayName isEqualToString:name])
            return peer;
    }
    
    return nil;
}

#pragma mark - MCSession Delegate method implementation


-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    if (state != MCSessionStateConnecting) {
        NSLog(@"Connecting");
        
        if (state == MCSessionStateConnected) {
            _isConnected = YES;
            NSLog(@"Connected");
        }
        else if (state == MCSessionStateNotConnected){
            _isConnected = NO;
            NSLog(@"disConnected");
        }
    }
}


-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    NSDictionary *dict = @{@"data": data,
                           @"peerID": peerID
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveDataNotification"
                                                        object:nil
                                                      userInfo:dict];
}


-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
    NSDictionary *dict = @{@"resourceName"  :   resourceName,
                           @"peerID"        :   peerID,
                           @"progress"      :   progress
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidStartReceivingResourceNotification"
                                                        object:nil
                                                      userInfo:dict];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [progress addObserver:self
                   forKeyPath:@"fractionCompleted"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    });
}


-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
    NSDictionary *dict = @{@"resourceName"  :   resourceName,
                           @"peerID"        :   peerID,
                           @"localURL"      :   localURL
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishReceivingResourceNotification"
                                                        object:nil
                                                      userInfo:dict];
    
}


-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCReceivingProgressNotification"
                                                        object:nil
                                                      userInfo:@{@"progress": (NSProgress *)object}];
}

@end
