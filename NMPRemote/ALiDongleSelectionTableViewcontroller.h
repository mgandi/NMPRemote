//
//  ALiDongleSelectionTableViewcontroller.h
//  NMPRemote
//
//  Created by Abilis Systems on 21/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALiDongle.h"

@interface ALiDongleSelectionTableViewcontroller : UITableViewController <ALiDongleDelegate>

@property (nonatomic, strong) NSMutableArray *dongles;

- (IBAction)cancel:(id)sender;

@end
