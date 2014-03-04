//
//  ALiControlViewController.m
//  NMPRemote
//
//  Created by Abilis Systems on 03/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiControlViewController.h"

@interface ALiControlViewController ()

@end

@implementation ALiControlViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)exit:(id)sender
{
    [self.dongle emulateKey:1];
}

- (IBAction)up:(id)sender
{
    [self.dongle emulateKey:103];
}

- (IBAction)info:(id)sender
{
    [self.dongle emulateKey:113];
}

- (IBAction)left:(id)sender
{
    [self.dongle emulateKey:105];
}

- (IBAction)ok:(id)sender
{
    [self.dongle emulateKey:28];
}

- (IBAction)right:(id)sender
{
    [self.dongle emulateKey:106];
}

- (IBAction)pagedown:(id)sender
{
    [self.dongle emulateKey:104];
}

- (IBAction)down:(id)sender
{
    [self.dongle emulateKey:108];
}

- (IBAction)pageup:(id)sender
{
    [self.dongle emulateKey:109];
}

- (IBAction)one:(id)sender
{
    [self.dongle emulateKey:2];
}

- (IBAction)two:(id)sender
{
    [self.dongle emulateKey:3];
}

- (IBAction)three:(id)sender
{
    [self.dongle emulateKey:4];
}

- (IBAction)four:(id)sender
{
    [self.dongle emulateKey:5];
}

- (IBAction)five:(id)sender
{
    [self.dongle emulateKey:6];
}

- (IBAction)six:(id)sender
{
    [self.dongle emulateKey:7];
}

- (IBAction)seven:(id)sender
{
    [self.dongle emulateKey:8];
}

- (IBAction)eight:(id)sender
{
    [self.dongle emulateKey:9];
}

- (IBAction)nine:(id)sender
{
    [self.dongle emulateKey:10];
}

- (IBAction)zero:(id)sender
{
    [self.dongle emulateKey:11];
}

@end
