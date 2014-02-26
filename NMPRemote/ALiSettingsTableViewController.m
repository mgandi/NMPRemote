//
//  ALiSettingsTableViewController.m
//  NMPRemote
//
//  Created by Abilis Systems on 25/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiSettingsTableViewController.h"

@interface ALiSettingsTableViewController ()

@end

@implementation ALiSettingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dongle.delegate = self;
    [self.dongle start];
    [self.dongle getDeviceInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ALi Dongle delegate

- (void)appInformationReceived:(ALiDongle *)dongle dict:(NSDictionary *)dict
{
    NSLog(@"Received app information");
}

- (void)deviceInformationReceived:(ALiDongle *)dongle dict:(NSDictionary *)dict
{
    NSLog(@"Received device information");
    
    /* Device Configuration */
    self.deviceConfigurationLabel1.text = [NSString stringWithFormat:@"Device Name : %@", [dict valueForKey:@"ssid"]];
    self.deviceConfigurationLabel2.text = [NSString stringWithFormat:@"Password : %@", [dict valueForKey:@"password"]];
    
    /* Device Information */
    self.deviceInformationLabel1.text = [NSString stringWithFormat:@"Model Name : %@", [dict valueForKey:@"name"]];
    self.deviceInformationLabel2.text = [NSString stringWithFormat:@"MAC : %@", [dict valueForKey:@"mac"]];
    
    /* Software Information */
    self.softwareInformationDetail.text = [NSString stringWithFormat:@"Software Version : %@.%@.%@", [dict valueForKey:@"majorver"], [dict valueForKey:@"minorver"], [dict valueForKey:@"minorver2"]];
}

@end
