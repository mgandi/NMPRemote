//
//  ALiApplicationViewController.m
//  NMPRemote
//
//  Created by Abilis Systems on 03/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiApplicationViewController.h"

#define SEG_HOME    0
#define SEG_IPLA    1
#define SEG_YOUTUBE 2

@interface ALiApplicationViewController ()

@end

@implementation ALiApplicationViewController

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
    
    [self.applicationSegmentedController addTarget:self
                                            action:@selector(applicationChanged:)
                                  forControlEvents:UIControlEventValueChanged];
    self.webpageUrl.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)applicationChanged:(id)sender
{
    switch (self.applicationSegmentedController.selectedSegmentIndex) {
        case SEG_HOME:
            [self.dongle switchToMainpage];
            break;
        case SEG_IPLA:
            [self.dongle switchToIpla];
            break;
        case SEG_YOUTUBE:
            [self.dongle switchToYoutube];
            break;
        default:
            break;
    }
}

# pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.dongle switchToWebpage:textField.text];
    [self.view endEditing:YES];
    self.applicationSegmentedController.selectedSegmentIndex = -1;
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

@end
