//
//  ALiViewController.m
//  NMPRemote
//
//  Created by Abilis Systems on 21/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "ALiDongleSelectionTableViewcontroller.h"
#import "ALiDongle.h"
#import "ALiSettingsTableViewController.h"
#import "ALiLiveTableViewController.h"
#import "ALiApplicationViewController.h"
#import "ALiControlViewController.h"
#import "ALiSSDPClient.h"


@interface ALiViewController ()

@end

@implementation ALiViewController
{
    GCDAsyncUdpSocket *udpSocket;
    NSMutableArray *dongles;
    ALiDongle *selectedDongle;
    bool doSearchForDongle;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dongles = [NSMutableArray arrayWithCapacity:0];
    selectedDongle = nil;
    doSearchForDongle = true;
    ALiSSDPClient *ssdpClient = [[ALiSSDPClient alloc] init];
    [ssdpClient searchForDevices:@"urn:ses-com:device:SatIPServer:1"];
}

-(void)viewDidAppear:(BOOL)animated
{
    /*
    if ((selectedDongle == nil) && (doSearchForDongle)) {
        [self searchForDongles];
    } else if (selectedDongle != nil) {
        // Make sure the dongle is compatible with current version of the app
        if ([selectedDongle checkAppVersionMatch]) {
            // Present dongle navigation controller as a segue
            [self performSegueWithIdentifier:@"DongleDashboard" sender:self];
        } else {
            // TODO: display error message
        }
    }
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DongleSelectionSegue"]) {
        UINavigationController *dongleSelectionNavigationController = segue.destinationViewController;
        ALiDongleSelectionTableViewcontroller *dongleSelectionTableViewController = [dongleSelectionNavigationController viewControllers][0];
        dongleSelectionTableViewController.dongles = dongles;
        dongleSelectionTableViewController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"DongleDashboard"]) {
        // Retrieve instance of Dashboard Navigation Controller
        UITabBarController *dongleDashboardTabBarController = (UITabBarController *)segue.destinationViewController;
        
        // Retrieve instance of Settings Table View and setup its reference to selected dongle
        UINavigationController *settingsNavigationController = (UINavigationController *)[dongleDashboardTabBarController viewControllers][0];
        ALiSettingsTableViewController *settings = (ALiSettingsTableViewController *)[settingsNavigationController viewControllers][0];
        settings.dongle = selectedDongle;
        
        // Retrieve instance of Live Navigation Controller and setup its reference to selected dongle
        UINavigationController *liveNavigationController = (UINavigationController *)[dongleDashboardTabBarController viewControllers][1];
        ALiLiveTableViewController *live = (ALiLiveTableViewController *)[liveNavigationController viewControllers][0];
        live.dongle = selectedDongle;
        
        // Retrieve instance of Application Navigation Controller and setup its reference to selected dongle
        UINavigationController *controlNavigationController = (UINavigationController *)[dongleDashboardTabBarController viewControllers][3];
        ALiControlViewController *control = (ALiControlViewController *)[controlNavigationController viewControllers][0];
        control.dongle = selectedDongle;
        
        // Retrieve instance of Application Navigation Controller and setup its reference to selected dongle
        UINavigationController *applicationNavigationController = (UINavigationController *)[dongleDashboardTabBarController viewControllers][4];
        ALiApplicationViewController *application = (ALiApplicationViewController *)[applicationNavigationController viewControllers][0];
        application.dongle = selectedDongle;
    }
}

- (void)searchForDongles
{
    [_indicator startAnimating];
    [dongles removeAllObjects];
    
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [udpSocket enableBroadcast:YES error:nil];
    [udpSocket bindToPort:13914 error:nil];
    /*BOOL res =*/ [udpSocket beginReceiving:nil];
    
    NSString *str = @"NMPALIVE_C";
    NSData* data = [str dataUsingEncoding:NSASCIIStringEncoding];
    [udpSocket sendData:data toHost:@"255.255.255.255" port:13913 withTimeout:-1 tag:1];
    
    /* Start timer */
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(searchForDonglesTimeout) userInfo:nil repeats:FALSE];
}

- (void)searchForDonglesTimeout
{
    [udpSocket close];
    [_indicator stopAnimating];
    selectedDongle = nil;
    doSearchForDongle = true;
    
    if ([dongles count]) {
        [self performSegueWithIdentifier:@"DongleSelectionSegue" sender:self];
    } else {
        [self performSegueWithIdentifier:@"NoDongleSegue" sender:self];
    }
}

#pragma mark - ALiDongleSelectionTableViewcontroller delegate

- (void)dongleSelected:(ALiDongleSelectionTableViewcontroller *)tableViewController dongle:(ALiDongle *)dongle
{
    selectedDongle = dongle;
}

- (void)setSearchForDongle:(ALiDongleSelectionTableViewcontroller *)tableViewController doSearch:(Boolean)doSearch
{
    doSearchForDongle = doSearch;
}

#pragma mark - GCDAsyncUdpSocket delegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    NSLog(@"didConnectToAddress");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error
{
    NSLog(@"didNotConnect");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"didSendDataWithTag %ld", tag);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"didNotSendDataWithTag %ld", tag);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    ALiDongle *dongle = [[ALiDongle alloc] init];
    dongle.name = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    dongle.address = [[GCDAsyncUdpSocket class] hostFromAddress:address];
    NSLog(@"didReceiveData %@ from address %@", dongle.name, dongle.address);
    [dongles addObject:dongle];
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"udpSocketDidClose %@", [error helpAnchor]);
}

@end
