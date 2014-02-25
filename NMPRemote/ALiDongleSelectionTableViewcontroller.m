//
//  ALiDongleSelectionTableViewcontroller.m
//  NMPRemote
//
//  Created by Abilis Systems on 21/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiDongleSelectionTableViewcontroller.h"
#import "ALiDongleDashboardTabBarController.h"
#import "ALiDongle.h"
#import "ALiSettingsTableViewController.h"

@interface ALiDongleSelectionTableViewcontroller ()

@end

@implementation ALiDongleSelectionTableViewcontroller

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dongles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DongleCell"];
    
    ALiDongle *dongle = (self.dongles)[indexPath.row];
    cell.textLabel.text = dongle.name;
    cell.detailTextLabel.text = dongle.address;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* Initialize corresponding dongle */
    ALiDongle *dongle = self.dongles[indexPath.row];
    dongle.delegate = self;
    [dongle start];
    [dongle checkAppMatchDongleVersion];
}

#pragma mark - ALi Dongle delegate

- (void)appInformationReceived:(ALiDongle *)dongle dict:(NSDictionary *)dict
{
    unsigned int major = [[dict valueForKey:@"major"] unsignedIntValue];
    unsigned int minor = [[dict valueForKey:@"minor"] unsignedIntValue];
    
    if ((major == APP_VERSION_MAJOR) && (minor == APP_VERSION_MINOR)) {
        NSLog(@"Yeeha! Version match!");
        
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ALiDongleDashboardTabBarController *dongleDashboardTabBarController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"DongleDashboard"];
        //    NSLog(@"Selected dongle: %@", cell.textLabel.text);
        //    NSLog(@"Class of UIViewController %@", NSStringFromClass([dongleDashboardTabBarController class]));
        
        dongleDashboardTabBarController.dongle = dongle;
        //    NSLog(@"Dongle dashboard has %d controllers.", [[dongleDashboardTabBarController viewControllers] count]);
        
        ALiSettingsTableViewController *settings = (ALiSettingsTableViewController *)[dongleDashboardTabBarController viewControllers][0];
        //    NSLog(@"Class of UIViewController %@", NSStringFromClass([settings class]));
        settings.dongle = dongle;
        
        // TODO: must stop dongle before starting again
        
        [self presentViewController:dongleDashboardTabBarController animated:YES completion:nil];
    } else {
        // Display error message
    }
}

- (void)deviceInformationReceived:(ALiDongle *)dongle dict:(NSDictionary *)dict
{
}

- (IBAction)cancel:(id)sender
{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *dongleSelectionNavigationController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"DongleSearchViewController"];
    [self presentViewController:dongleSelectionNavigationController animated:YES completion:nil];
}

@end
