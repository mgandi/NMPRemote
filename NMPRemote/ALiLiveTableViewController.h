//
//  ALiLiveTableViewController.h
//  NMPRemote
//
//  Created by Abilis Systems on 28/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALiDongle.h"

@interface ALiLiveTableViewController : UITableViewController

@property (nonatomic, strong) ALiDongle *dongle;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stopBarButtonItem;

- (IBAction)stop:(id)sender;

@end
