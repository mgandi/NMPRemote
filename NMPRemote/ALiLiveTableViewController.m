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
    
    /* Parse file and get list of M3U items */
    m3uItems = [ALiM3uParser parse:path];
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
    ALiM3uItem *item = (m3uItems)[indexPath.row];
    
    NSLog(@"Playback %@: connect to %@", item.name, item.url);
    
    [self.dongle playback:item.url];
    [self.stopBarButtonItem setEnabled:true];
}


- (IBAction)stop:(id)sender
{
    [self.dongle stopPlayback];
    [self.stopBarButtonItem setEnabled:false];
}

@end
