//
//  ViewController.m
//  DHKFabulous
//
//  Created by Tyler Hugenberg on 1/14/15.
//  Copyright (c) 2015 Duet Health. All rights reserved.
//

#import "ViewController.h"
#import "DHKFabulous.h"

@interface ViewController ()

@property (strong, nonatomic) DHKFABView* fab;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DHKFABItem* item1 = [[DHKFABItem alloc] initWithTitle:@"Title 1 asdkljfsdf akdf asdkfjhf hiuiufh iuhiawefhu wiuf haifuh  huf test kjhsdf test df fhjsdf hjdhf jhjdf lasdfl huiasdfh k" icon:nil andAction:^{
        NSLog(@"item 1 pressed");
    }];
    DHKFABItem* item2 = [[DHKFABItem alloc] initWithTitle:@"Title 2" icon:nil andAction:^{
        NSLog(@"item 2 pressed");
    }];
    DHKFABItem* item3 = [[DHKFABItem alloc] initWithTitle:@"Title 3" icon:nil andAction:^{
        NSLog(@"item 3 pressed");
    }];
    DHKFABItem* item4 = [[DHKFABItem alloc] initWithTitle:@"Title 4" icon:nil andAction:^{
        NSLog(@"item 4 pressed");
    }];
    _fab = [DHKFABView dhk_FABWithSuperview:self.view andItems:@[item1, item2, item3, item4]];
    
    
    self.view.backgroundColor = [UIColor blackColor];
}


@end
