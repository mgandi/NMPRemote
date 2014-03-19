//
//  ALiSettingsTableViewController.h
//  NMPRemote
//
//  Created by Abilis Systems on 25/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALiDongle.h"
#import "ALiLiveStreamserversTableViewController.h"

@interface ALiSettingsTableViewController : UITableViewController <ALiDongleDelegate, ALiLiveStreamserversDelegate>

@property (nonatomic, strong) ALiDongle *dongle;
@property (weak, nonatomic) IBOutlet UILabel *wifiNetworkDetail;
@property (weak, nonatomic) IBOutlet UILabel *deviceConfigurationLabel1;
@property (weak, nonatomic) IBOutlet UILabel *deviceConfigurationLabel2;
@property (weak, nonatomic) IBOutlet UILabel *deviceHotspotChannelDetail;
@property (weak, nonatomic) IBOutlet UILabel *liveServerInformationDetail;
@property (weak, nonatomic) IBOutlet UILabel *deviceInformationLabel1;
@property (weak, nonatomic) IBOutlet UILabel *deviceInformationLabel2;
@property (weak, nonatomic) IBOutlet UILabel *softwareInformationDetail;

@end
