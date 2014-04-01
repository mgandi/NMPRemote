//
//  ALiLiveTableViewController.h
//  NMPRemote
//
//  Created by Abilis Systems on 28/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALiDongle.h"
#import "ALiDvbtScanProcedure.h"
#import "MBProgressHUD.h"

@interface ALiLiveTableViewController : UITableViewController <ALiDongleDelegate, ALiDvbtScanProcedureDelegate, MBProgressHUDDelegate>

@property (nonatomic, strong) ALiDongle *dongle;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stopBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBarButtonItem;
@property (atomic, assign, readonly) BOOL scanning;

- (IBAction)stop:(id)sender;
- (IBAction)refresh:(id)sender;

@end
