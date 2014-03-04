//
//  ALiDongleSelectionTableViewcontroller.m
//  NMPRemote
//
//  Created by Abilis Systems on 21/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiDongleSelectionTableViewcontroller.h"
#import "ALiDongle.h"
#import "ALiSettingsTableViewController.h"
#import "ALiLiveTableViewController.h"

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


- (IBAction)cancel:(id)sender
{
    /* Force the parent controller not to search fro dongle */
    [self.delegate dongleSelected:self dongle:nil];
    [self.delegate setSearchForDongle:self doSearch:false];
    
    /* Dismiss segue */
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)refresh:(id)sender
{
    /* Make sure we set the selected dongle to nil so the parent controller refresh the list */
    [self.delegate dongleSelected:self dongle:nil];
    [self.delegate setSearchForDongle:self doSearch:true];
    
    /* Dismiss segue */
    [self dismissViewControllerAnimated:YES completion:nil];
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
    /* Set selected dongle */
    [self.delegate dongleSelected:self dongle:self.dongles[indexPath.row]];
    
    /* Dismiss segue */
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
