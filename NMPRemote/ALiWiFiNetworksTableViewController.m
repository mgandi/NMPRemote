//
//  ALiWiFiNetworksTableViewController.m
//  NMPRemote
//
//  Created by Abilis Systems on 04/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiWiFiNetworksTableViewController.h"
#import "ALiWiFiNetwork.h"
#import "ALiWiFiNetworkTableViewCell.h"

@interface ALiWiFiNetworksTableViewController ()

@end

@implementation ALiWiFiNetworksTableViewController
{
    NSMutableArray *wifiNetworks;
}

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
    wifiNetworks = [NSMutableArray arrayWithCapacity:0];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.dongle.delegate = self;
    [self searchForWiFiNetworks];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.dongle.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchForWiFiNetworks
{
    /* Start thread to search for Wi-Fi Networks */
    [self.dongle getDeviceWifiIsScanningInfo];
    
    /* Start timer */
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(searchForWiFiNetworksTimeout) userInfo:nil repeats:FALSE];
}

- (void)searchForWiFiNetworksTimeout
{
    [self.dongle getDeviceWifiListInfo];
}

- (IBAction)refresh:(id)sender
{
    [self searchForWiFiNetworks];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [wifiNetworks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALiWiFiNetworkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WiFiNetworkCell"];
    
    ALiWiFiNetwork *wifiNetwork = wifiNetworks[indexPath.row];
    cell.ssid.text = wifiNetwork.ssid;
    cell.protect.text = [NSString stringWithFormat:@"Protect: %@", wifiNetwork.protection];
    cell.strength.text = [NSString stringWithFormat:@"Strength: %ld", wifiNetwork.strength];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALiWiFiNetwork *wifiNetwork = wifiNetworks[indexPath.row];
    [self.dongle connectToWifi:wifiNetwork.ssid protection:wifiNetwork.protection password:@"satipnet" hidden:false];
}

#pragma mark - ALi Dongle delegate

- (void)appInformationReceived:(ALiDongle *)dongle dict:(NSDictionary *)dict
{
}

- (void)deviceInformationReceived:(ALiDongle *)dongle dict:(NSDictionary *)dict
{
}

- (void)deviceWifiInformationReceived:(ALiDongle *)dongle dict:(NSDictionary *)dict
{
}

- (void)deviceWifiChannelInformationReceived:(ALiDongle *)dongle dict:(NSDictionary *)dict
{
}

- (void)deviceWifiListInformationReceived:(ALiDongle *)dongle dict:(NSDictionary *)dict
{
    NSLog(@"Received Wi-Fi Networks List");
    
    [wifiNetworks removeAllObjects];
    NSArray *wifiList = [dict valueForKey:@"list"];
    for (id wifi in wifiList) {
        ALiWiFiNetwork *wifiNetwork = [[ALiWiFiNetwork alloc] init];
        wifiNetwork.ssid = [wifi valueForKey:@"ssid"];
        wifiNetwork.protection = [wifi valueForKey:@"protect"];
        wifiNetwork.strength = [[wifi valueForKey:@"strength"] longValue];
        wifiNetwork.status = [[wifi valueForKey:@"status"] intValue];
        [wifiNetworks addObject:wifiNetwork];
    }
    [[self tableView] reloadData];
}

@end
