//
//  ALiLiveStreamserversTableViewController.h
//  NMPRemote
//
//  Created by Abilis Systems on 18/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALiSSDPClient.h"
#import "ALiSatipServer.h"

@class ALiLiveStreamserversTableViewController;

@protocol ALiLiveStreamserversDelegate <NSObject>
- (void)serverSelected:(ALiSatipServer *)liveServer;
@end

@interface ALiLiveStreamserversTableViewController : UITableViewController <ALiSSDPClientDelegate>

@property (nonatomic, weak) id <ALiLiveStreamserversDelegate> delegate;

- (IBAction)refresh:(id)sender;

@end
