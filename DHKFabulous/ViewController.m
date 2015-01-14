//
//  ViewController.m
//  DHKFabulous
//
//  Created by Tyler Hugenberg on 1/14/15.
//  Copyright (c) 2015 Duet Health. All rights reserved.
//

#import "ViewController.h"
#import "DHKFABView.h"

@interface ViewController ()

@property (strong, nonatomic) DHKFABView* fab;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _fab = [DHKFABView dhk_FABWithSuperview:self.view andItems:@[]];
}


@end
