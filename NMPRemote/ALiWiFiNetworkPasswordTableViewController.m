//
//  ALiWiFiNetworkPasswordTableViewController.m
//  NMPRemote
//
//  Created by Abilis Systems on 04/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiWiFiNetworkPasswordTableViewController.h"

@interface ALiWiFiNetworkPasswordTableViewController ()

@end

@implementation ALiWiFiNetworkPasswordTableViewController

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
    [_password setDelegate:self];
    [_password becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_password resignFirstResponder];
    [_dongle connectToWifi:_wifiNetwork.ssid protection:_wifiNetwork.protection password:[textField text] hidden:false];
    return YES;
}

@end
