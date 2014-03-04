//
//  ALiViewController.h
//  NMPRemote
//
//  Created by Abilis Systems on 21/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALiDongleSelectionTableViewcontroller.h"

@interface ALiViewController : UIViewController <NSStreamDelegate, ALiDongleSelectionTableViewcontrollerDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end
