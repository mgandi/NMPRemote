//
//  ALiViewController.h
//  NMPRemote
//
//  Created by Abilis Systems on 21/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALiViewController : UIViewController <NSStreamDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end
