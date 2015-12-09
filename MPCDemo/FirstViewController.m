//
//  FirstViewController.m
//  MPCDemo
//
//  Created by Fred on 30/11/2015.
//  Copyright (c) 2015 Fred. All rights reserved.
//

#import "FirstViewController.h"
#import "MCManager.h"

@interface FirstViewController ()

@property (nonatomic, strong) MCManager *manager;

-(void)sendMyMessage;
-(void)didReceiveDataWithNotification:(NSNotification *)notification;

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tabBarController.tabBar.barTintColor = [UIColor colorWithRed:165.0/255 green:184.0/255 blue:19.0/255 alpha:1.0];
    self.tabBarController.tabBar.translucent = false;
    self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
    
    _manager = [MCManager sharedMCManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - UITextField Delegate method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(_manager.isConnected){
        [self sendMyMessage];
    }
    else{
        [_manager findNearlyPeers:self];
    }
    
    return YES;
}


#pragma mark - IBAction method implementation
- (IBAction)cancel:(id)sender {
    _tbMessage.text = nil;
    [_tbMessage resignFirstResponder];
}

- (IBAction)send:(id)sender {
    if(_manager.isConnected){
        [self sendMyMessage];
    }
    else{
        [_manager findNearlyPeers:self];
    }
}

- (IBAction)changePeer:(id)sender {
    [_manager.session disconnect];
    [_manager findNearlyPeers:self];
}


#pragma mark - Private method implementation

-(void)sendMyMessage{
    NSData *dataToSend = [_tbMessage.text dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *allPeers = _manager.session.connectedPeers;
    NSError *error;
    
    [_manager.session sendData:dataToSend
                       toPeers:allPeers
                      withMode:MCSessionSendDataReliable
                         error:&error];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    [_tvTalk setText:[_tvTalk.text stringByAppendingString:[NSString stringWithFormat:@"%@:\n%@\n\n",
                                                            _manager.myPeerID.displayName, _tbMessage.text]]];
    [_tbMessage setText:@""];
    [_tbMessage resignFirstResponder];
}

#pragma mark - MCBrowserViewControllerDelegate method implementation

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [_manager.browser dismissViewControllerAnimated:YES completion:nil];
}


-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [_manager.browser dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Notification

-(void)didReceiveDataWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSString *receivedText = [[NSString alloc] initWithData:receivedData
                                                   encoding:NSUTF8StringEncoding];
    NSString *messageToDisplay = [_tvTalk.text stringByAppendingString:[NSString stringWithFormat:@"%@:\n%@\n\n", peerID.displayName, receivedText]];
    
    [_tvTalk performSelectorOnMainThread:@selector(setText:)
                              withObject:messageToDisplay
                           waitUntilDone:NO];
}
@end
