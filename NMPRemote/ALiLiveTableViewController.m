 //
//  ALiLiveTableViewController.m
//  NMPRemote
//
//  Created by Abilis Systems on 28/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiLiveTableViewController.h"
#import "ALiM3uParser.h"
#import "ALiM3uItem.h"

@interface ALiLiveTableViewController ()

@end

@implementation ALiLiveTableViewController
{
    NSMutableArray *m3uItems;
    ALiDvbtScanProcedure *procedure;
    MBProgressHUD *HUD;
    NSMutableArray *programs;
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
    
    //Check if there is my file
    NSString *path = [[NSBundle mainBundle]  pathForResource:@"Abilis" ofType:@"m3u"];
    if (path != nil) {
        NSLog(@"Yes.We see the file at %@", path);
    }
    else {
        NSLog(@"Nope there is no file");
    }
    
    // Parse file and get list of M3U items
    m3uItems = [ALiM3uParser parse:path];
    
    // Init procedure
    procedure = nil;
    
    // Init scanning indicator
    _scanning = NO;
    
    // Init programs array
    programs = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.dongle.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.dongle.delegate = nil;
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
    return [m3uItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"M3uItemCell"];
    
    ALiM3uItem *item = (m3uItems)[indexPath.row];
    cell.textLabel.text = item.name;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Test if liver server is selected
    if (_dongle.liveServer == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No live stream server selected"
                                                        message:@"Please select a live stream server in settings tab to watch live content"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // Extract selected item
    ALiM3uItem *item = (m3uItems)[indexPath.row];
    
    // Replace ip address with live stream server address
    NSString *ipaddress = [NSString stringWithFormat:@"http://%@", _dongle.liveServer.device.address];
    NSMutableString *url = [NSMutableString stringWithString:item.url];
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"http://\\d+\\.\\d+\\.\\d+\\.\\d+"
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:nil];
    [regex replaceMatchesInString:url options:0 range:NSMakeRange(0, [url length]) withTemplate:ipaddress];
    
    // Display message that url playback is about to start
    NSLog(@"Playback %@: connect to %@", item.name, url);
    
    // Playback url and enable stop button
    [self.dongle playback:url];
    [self.stopBarButtonItem setEnabled:true];
}


- (IBAction)stop:(id)sender
{
    if (_scanning) {
        // Stop and delete scan procedure if any already existing
        if (procedure != nil) {
            [procedure stop];
            procedure = nil;
        }
    } else {
        [self.dongle stopPlayback];
    }
    
    // Set stop bar buttonitem to disabled state and refresh control to enabled state
    [self.refreshBarButtonItem setEnabled:true];
    [self.stopBarButtonItem setEnabled:false];
}

- (IBAction)refresh:(id)sender
{
    // Stop and delete scan procedure if any already existing
    if (procedure != nil) {
        [procedure stop];
        procedure = nil;
    }
    
    // We are now in scanning mode
    _scanning = YES;
    
    // Create instance of HUD and add it as a sub view
	HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	
	// Set determinate mode
	HUD.mode = MBProgressHUDModeDeterminate;
	
	HUD.delegate = self;
	HUD.labelText = @"Scanning";
	
	// myProgressTask uses the HUD instance to update progress
	[HUD showWhileExecuting:@selector(progressTask) onTarget:self withObject:nil animated:YES];
    
    // Remove all rows
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:0];
    for (ALiM3uItem *item in m3uItems) {
        NSUInteger index = [m3uItems indexOfObject:item];
        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }
    [m3uItems removeAllObjects];
    [[self tableView] deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    // Create scan procedure and launch it
    procedure = [[ALiDvbtScanProcedure alloc] initWithServer:_dongle.liveServer startFrequency:474.0 stepFrequency:8.0 stopFrequency:826.0];
    procedure.delegate = self;
    
    // Set stop bar button item to enabled state refresh control to disabled
    [self.refreshBarButtonItem setEnabled:false];
    [self.stopBarButtonItem setEnabled:true];
    
    // Start the scan procedure
    [procedure start];
}

#pragma mark - DVB-T Scan procedure delegate

- (void)done:(ALiDvbtScanProcedure *)proc
{
}

- (void)stopped:(ALiDvbtScanProcedure *)proc
{
    if (proc == procedure ) {
        // Delete scan procedure
        if (procedure != nil) {
            procedure = nil;
        }
    }
    
    // Set stop bar button item to enabled state refresh control to disabled
    [self.refreshBarButtonItem setEnabled:true];
    [self.stopBarButtonItem setEnabled:false];
    
    // We are no longer in scanning mode
    _scanning = NO;
}

- (void)foundProgram:(ALiDvbtScanProcedure *)proc program:(ALiProgram *)program
{
    ALiM3uItem *item = [[ALiM3uItem alloc] init];
    item.name = program.serviceName;
    item.url = [program urlWithScheme:@"http" host:_dongle.liveServer.device.address];
    
    // Add M3U item to array of items and to table view
    [m3uItems addObject:item];
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:0];
    [indexPaths addObject:[NSIndexPath indexPathForRow:[m3uItems indexOfObject:item] inSection:0]];
    [[self tableView] insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    // Add to programs array (for progress dialog)
    [programs addObject:item];
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
}

#pragma mark - MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}

- (void)progressTask
{
    static NSUInteger counter = 0;
    
    while (_scanning) {
        HUD.progress = procedure.progress;
        
        if ([programs count]) {
            if (counter == 0) {
                ALiM3uItem *item = [programs firstObject];
                [programs removeObject:item];
                HUD.detailsLabelText = item.name;
                counter = 20;
            } else {
                --counter;
            }
        } else {
            if (counter == 0)
                HUD.detailsLabelText = @"";
            else
                --counter;
        }
        
        usleep(50000);
    }
}

@end
