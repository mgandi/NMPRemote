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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dongles = [NSMutableArray arrayWithCapacity:0];
    [self searchForDongles];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchForDonglesTimeout
{
    [udpSocket close];
    
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if ([dongles count]) {
        UINavigationController *dongleSelectionNavigationController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"DongleSelectionNavigationController"];
        ALiDongleSelectionTableViewcontroller *dongleSelectionTableViewController = [dongleSelectionNavigationController viewControllers][0];
        dongleSelectionTableViewController.dongles = dongles;
        [self presentViewController:dongleSelectionNavigationController animated:YES completion:nil];
    } else {
        UIViewController *noDongleViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"NoDongleViewController"];
        [self presentViewController:noDongleViewController animated:YES completion:nil];
    }
}

- (void)searchForDongles
{
    [_indicator startAnimating];
    
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
    
    /*
    NSString *addressString = [[GCDAsyncUdpSocket class] hostFromAddress:address];
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"didReceiveData %@ from address %@", dataString, addressString);
    [dongles addObject:dataString];
    */
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"udpSocketDidClose %@", [error helpAnchor]);
}

@end
