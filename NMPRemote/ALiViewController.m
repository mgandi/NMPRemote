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

@interface ALiViewController ()

@end

@implementation ALiViewController
{
    GCDAsyncUdpSocket *udpSocket;
    NSMutableArray *dongles;
    ALiDongle *selectedDongle;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dongles = [NSMutableArray arrayWithCapacity:0];
    selectedDongle = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    if (selectedDongle == nil) {
        [self searchForDongles];
    } else {
        
    }
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
    }
}

- (void)searchForDonglesTimeout
{
    [udpSocket close];
    
    [_indicator stopAnimating];
    
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if ([dongles count]) {
        [self performSegueWithIdentifier:@"DongleSelectionSegue" sender:self];
    } else {
        UIViewController *noDongleViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"NoDongleViewController"];
        [self presentViewController:noDongleViewController animated:NO completion:nil];
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
