//
//  FirstViewController.h
//  MPCDemo
//
//  Created by Fred on 30/11/2015.
//  Copyright (c) 2015 Fred. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface FirstViewController : UIViewController<MCBrowserViewControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tbMessage;
@property (weak, nonatomic) IBOutlet UITextView *tvTalk;


- (IBAction)cancel:(id)sender;
- (IBAction)send:(id)sender;
- (IBAction)changePeer:(id)sender;


@end

