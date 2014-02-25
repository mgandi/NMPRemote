//
//  ALiNoDongleViewController.m
//  NMPRemote
//
//  Created by Abilis Systems on 21/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiNoDongleViewController.h"

@interface ALiNoDongleViewController ()

@end

@implementation ALiNoDongleViewController

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

-(IBAction)retry:(id)sender
{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *dongleSelectionNavigationController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"DongleSearchViewController"];
    [self presentViewController:dongleSelectionNavigationController animated:YES completion:nil];
}

@end
