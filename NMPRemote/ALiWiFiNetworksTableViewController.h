//
//  ALiWiFiNetworksTableViewController.h
//  NMPRemote
//
//  Created by Abilis Systems on 04/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALiDongle.h"

@interface ALiWiFiNetworksTableViewController : UITableViewController <ALiDongleDelegate>

@property (nonatomic, strong) ALiDongle *dongle;

- (IBAction)refresh:(id)sender;

@end
