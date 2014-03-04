//
//  ALiDongleSelectionTableViewcontroller.h
//  NMPRemote
//
//  Created by Abilis Systems on 21/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALiDongle.h"

@class ALiDongleSelectionTableViewcontroller;

@protocol ALiDongleSelectionTableViewcontrollerDelegate <NSObject>
- (void)dongleSelected:(ALiDongleSelectionTableViewcontroller *)tableViewController dongle:(ALiDongle *)dongle;
- (void)setSearchForDongle:(ALiDongleSelectionTableViewcontroller *)tableViewController doSearch:(Boolean)doSearch;
@end

@interface ALiDongleSelectionTableViewcontroller : UITableViewController

@property (nonatomic, strong) NSMutableArray *dongles;
@property (nonatomic, weak) id <ALiDongleSelectionTableViewcontrollerDelegate> delegate;

- (IBAction)cancel:(id)sender;
- (IBAction)refresh:(id)sender;

@end
