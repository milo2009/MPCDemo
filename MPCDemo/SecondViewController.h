//
//  SecondViewController.h
//  MPCDemo
//
//  Created by Fred on 30/11/2015.
//  Copyright (c) 2015 Fred. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tbFiles;

@end

