//
//  ALiWiFiNetworkPasswordTableViewController.h
//  NMPRemote
//
//  Created by Abilis Systems on 04/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALiDongle.h"
#import "ALiWiFiNetwork.h"

@interface ALiWiFiNetworkPasswordTableViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) ALiDongle *dongle;
@property (nonatomic, strong) ALiWiFiNetwork *wifiNetwork;
@property (weak, nonatomic) IBOutlet UITextField *password;

- (IBAction)cancel:(id)sender;

@end
