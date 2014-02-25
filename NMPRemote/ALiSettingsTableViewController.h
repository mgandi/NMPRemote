//
//  ALiSettingsTableViewController.h
//  NMPRemote
//
//  Created by Abilis Systems on 25/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALiDongle.h"

@interface ALiSettingsTableViewController : UITableViewController <ALiDongleDelegate>

@property (nonatomic, strong) ALiDongle *dongle;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end
