//
//  ALiLiveStreamserversTableViewController.m
//  NMPRemote
//
//  Created by Abilis Systems on 18/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiLiveStreamserversTableViewController.h"
#import "ALiSatipServer.h"

@interface ALiLiveStreamserversTableViewController ()

@end

@implementation ALiLiveStreamserversTableViewController
{
    ALiSSDPClient *ssdpClient;
    NSMutableDictionary *serversDictionnary;
    NSMutableArray *servers;
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
    
    // Allocate SSDP Client
    ssdpClient = [[ALiSSDPClient alloc] init];
    [ssdpClient setDelegate:self];
    
    // Allocate servers dictionnary & array
    serversDictionnary = [NSMutableDictionary dictionaryWithCapacity:0];
    servers = [NSMutableArray arrayWithCapacity:0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [ssdpClient searchForDevices:@"urn:ses-com:device:SatIPServer:1"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refresh:(id)sender
{
    // Build index path listing all servers
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:0];
    for (ALiSatipServer *server in servers) {
        NSUInteger index = [servers indexOfObject:server];
        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }
    
    // Remove all servers from dictionnary and array
    [serversDictionnary removeAllObjects];
    [servers removeAllObjects];
    
    // Clesr table view
    [[self tableView] deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    // Launch new device search
    [ssdpClient searchForDevices:@"urn:ses-com:device:SatIPServer:1"];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"CHOOSE A LIVE SERVER...";
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [servers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveStreamServerCell"];
    
    ALiSatipServer *server = servers[indexPath.row];
    cell.textLabel.text = server.getFriendlyName;
    cell.detailTextLabel.text = server.device.address;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ALiSatipServer *server = (servers)[indexPath.row];
    [_delegate serverSelected:server];
    
    // Get back to settings view
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - SSDP client delegate

- (void)SSDPDeviceJoin:(ALiSSDPClient *)ssdpClient device:(ALiSSDPDevice *)device
{
    if (![device.urn isEqualToString:@"urn:ses-com:device:SatIPServer:1"])
        return;
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:0];
    
    if ([serversDictionnary objectForKey:device.address] == nil) {
        ALiSatipServer *server = [[ALiSatipServer alloc] initWithSSDPDevice:device];
        [serversDictionnary setObject:server forKey:device.address];
        [servers addObject:server];
        
        [indexPaths addObject:[NSIndexPath indexPathForRow:[servers indexOfObject:server] inSection:0]];
    } else {
        // Do nothing
    }
    
    // Add objects to table view
    [[self tableView] insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)SSDPDeviceLeft:(ALiSSDPClient *)ssdpClient device:(ALiSSDPDevice *)device
{
    if (![device.urn isEqualToString:@"urn:ses-com:device:SatIPServer:1"])
        return;
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:0];
    
    if ([serversDictionnary objectForKey:device.address] != nil) {
        ALiSatipServer *server = [serversDictionnary objectForKey:device.address];
        [serversDictionnary removeObjectForKey:device.address];
        NSUInteger index = [servers indexOfObject:server];
        [servers removeObject:server];
        
        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    } else {
        // Do nothing
    }
    
    // Delete objects from table view
    [[self tableView] deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)foundSSDPDevice:(ALiSSDPClient *)ssdpClient device:(ALiSSDPDevice *)device
{
    if (![device.urn isEqualToString:@"urn:ses-com:device:SatIPServer:1"])
        return;
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:0];
    
    if ([serversDictionnary objectForKey:device.address] == nil) {
        ALiSatipServer *server = [[ALiSatipServer alloc] initWithSSDPDevice:device];
        [serversDictionnary setObject:server forKey:device.address];
        [servers addObject:server];
        
        [indexPaths addObject:[NSIndexPath indexPathForRow:[servers indexOfObject:server] inSection:0]];
    } else {
        // Do nothing
    }
    
    // Add objects to table view
    [[self tableView] insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
