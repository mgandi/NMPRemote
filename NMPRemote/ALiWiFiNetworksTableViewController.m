//
//  ALiWiFiNetworksTableViewController.m
//  NMPRemote
//
//  Created by Abilis Systems on 04/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiWiFiNetworksTableViewController.h"
#import "ALiWiFiNetwork.h"
#import "ALiWiFiNetworkPasswordTableViewController.h"

@interface ALiWiFiNetworksTableViewController ()

@end

@implementation ALiWiFiNetworksTableViewController
{
    NSMutableArray *wifiNetworks;
    UIActivityIndicatorView *activityIndicatorView;
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
    activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.hidesWhenStopped = YES;
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

- (void)searchForWiFiNetworksTimeout
{
    [self.dongle getDeviceWifiListInfo];
}

- (void)searchForWiFiNetworks
{
    /* Start thread to search for Wi-Fi Networks */
    [self.dongle getDeviceWifiIsScanningInfo];
    
    /* Start timer */
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(searchForWiFiNetworksTimeout) userInfo:nil repeats:FALSE];
}

- (IBAction)refresh:(id)sender
{
    [self searchForWiFiNetworks];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"CHOOSE A NETWORK...";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    /*
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(15, 10, 300, 20);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithHue:171.0/360.0 saturation:1.0 brightness:0.52 alpha:1.0];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0, 0.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
    */
    
    [activityIndicatorView startAnimating];
    
    // Create header view and add label as a subview
    // you could also just return the label (instead of making a new view and adding the label as subview. With the view you have more flexibility to make a background color or different paddings
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20)];
    [view addSubview:activityIndicatorView];
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [wifiNetworks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WiFiNetworkCell"];
    
    ALiWiFiNetwork *wifiNetwork = wifiNetworks[indexPath.row];
    cell.textLabel.text = wifiNetwork.ssid;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"WiFiNetworkPasswordSegue"]) {
        UINavigationController *nav = segue.destinationViewController;
        ALiWiFiNetworkPasswordTableViewController *password = (ALiWiFiNetworkPasswordTableViewController *)[nav viewControllers][0];
        password.dongle = _dongle;
        NSIndexPath *indexPath = [[self tableView] indexPathForCell:sender];
        NSUInteger index = [indexPath row];
        password.wifiNetwork = wifiNetworks[index];
    }
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
    
    [activityIndicatorView stopAnimating];
    [wifiNetworks removeAllObjects];
    [[self tableView] reloadData];
    NSArray *wifiList = [dict valueForKey:@"list"];
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:0];
    for (id wifi in wifiList) {
        ALiWiFiNetwork *wifiNetwork = [[ALiWiFiNetwork alloc] init];
        wifiNetwork.ssid = [wifi valueForKey:@"ssid"];
        wifiNetwork.protection = [wifi valueForKey:@"protect"];
        wifiNetwork.strength = [[wifi valueForKey:@"strength"] longValue];
        wifiNetwork.status = [[wifi valueForKey:@"status"] intValue];
        [wifiNetworks addObject:wifiNetwork];
        
        [indexPaths addObject:[NSIndexPath indexPathForRow:[wifiNetworks indexOfObject:wifiNetwork] inSection:0]];
    }
    
    [[self tableView] insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
