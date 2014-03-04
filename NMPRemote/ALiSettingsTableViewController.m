//
//  ALiSettingsTableViewController.m
//  NMPRemote
//
//  Created by Abilis Systems on 25/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiSettingsTableViewController.h"
#import "ALiWiFiNetworksTableViewController.h"

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    self.dongle.delegate = self;
    [self.dongle getDeviceInfo];
    [self.dongle getDeviceWifiInfo];
    [self.dongle getDeviceWifiChannelInfo];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.dongle.delegate = nil;
}

#pragma mark - Table View delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(15, 10, 300, 20);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithHue:171.0/360.0 saturation:1.0 brightness:0.52 alpha:1.0];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0, 0.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
    
    // Create header view and add label as a subview
    // you could also just return the label (instead of making a new view and adding the label as subview. With the view you have more flexibility to make a background color or different paddings
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20)];
    [view addSubview:label];
    return view;
}

#pragma mark - Table View Controller

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"WiFiNetworksSegue"]) {
        ALiWiFiNetworksTableViewController *wiFiNetworksTableViewController = segue.destinationViewController;
        wiFiNetworksTableViewController.dongle = self.dongle;
    }
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

- (void)deviceWifiInformationReceived:(ALiDongle *)dongle dict:(NSDictionary *)dict
{
    NSLog(@"Received device wifi information");
    
    /* Wi-Fi Network */
    if ([[dict valueForKey:@"isconnected"] boolValue]) {
        self.wifiNetworkDetail.text = [dict valueForKey:@"ssid"];
    } else {
        self.wifiNetworkDetail.text = @"Not connected";
    }
}

- (void)deviceWifiChannelInformationReceived:(ALiDongle *)dongle dict:(NSDictionary *)dict
{
    NSLog(@"Received device wifi channel information");
    
    /* Device Hotspot Channel */
    self.deviceHotspotChannelDetail.text = [NSString stringWithFormat:@"Channel: %ld", (long)[[dict valueForKey:@"channel"] integerValue]];
}

- (void)deviceWifiListInformationReceived:(ALiDongle *)dongle dict:(NSDictionary *)dict
{
}

@end
