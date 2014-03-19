//
//  ALiPlaybackTableViewController.h
//  NMPRemote
//
//  Created by Abilis Systems on 19/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALiDongle.h"

@interface ALiPlaybackTableViewController : UITableViewController

@property (nonatomic, strong) ALiDongle *dongle;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;

- (IBAction)play:(id)sender;
- (IBAction)stop:(id)sender;

@end
