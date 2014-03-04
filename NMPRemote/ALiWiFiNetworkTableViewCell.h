//
//  ALiWiFiNetworkTableViewCell.h
//  NMPRemote
//
//  Created by Abilis Systems on 04/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALiWiFiNetworkTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *ssid;
@property (weak, nonatomic) IBOutlet UILabel *protect;
@property (weak, nonatomic) IBOutlet UILabel *strength;

@end
