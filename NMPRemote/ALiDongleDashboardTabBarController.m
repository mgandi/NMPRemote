//
//  ALiDongleDashboardTabBarController.m
//  NMPRemote
//
//  Created by Abilis Systems on 21/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiDongleDashboardTabBarController.h"

@interface ALiDongleDashboardTabBarController ()

@end

@implementation ALiDongleDashboardTabBarController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"Selected view");
}

@end
