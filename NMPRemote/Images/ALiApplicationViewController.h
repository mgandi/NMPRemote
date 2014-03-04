//
//  ALiApplicationViewController.h
//  NMPRemote
//
//  Created by Abilis Systems on 03/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALiDongle.h"

@interface ALiApplicationViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) ALiDongle *dongle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *applicationSegmentedController;
@property (weak, nonatomic) IBOutlet UITextField *webpageUrl;

- (IBAction)applicationChanged:(id)sender;

@end
