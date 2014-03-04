//
//  ALiControlViewController.h
//  NMPRemote
//
//  Created by Abilis Systems on 03/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALiDongle.h"

@interface ALiControlViewController : UIViewController

@property (nonatomic, strong) ALiDongle *dongle;

- (IBAction)exit:(id)sender;
- (IBAction)up:(id)sender;
- (IBAction)info:(id)sender;
- (IBAction)left:(id)sender;
- (IBAction)ok:(id)sender;
- (IBAction)right:(id)sender;
- (IBAction)pagedown:(id)sender;
- (IBAction)down:(id)sender;
- (IBAction)pageup:(id)sender;
- (IBAction)one:(id)sender;
- (IBAction)two:(id)sender;
- (IBAction)three:(id)sender;
- (IBAction)four:(id)sender;
- (IBAction)five:(id)sender;
- (IBAction)six:(id)sender;
- (IBAction)seven:(id)sender;
- (IBAction)eight:(id)sender;
- (IBAction)nine:(id)sender;
- (IBAction)zero:(id)sender;

@end
