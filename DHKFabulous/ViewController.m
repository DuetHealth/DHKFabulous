//
//  ViewController.m
//  DHKFabulous
//
//  Created by Tyler Hugenberg on 1/14/15.
//  Copyright (c) 2015 Duet Health. All rights reserved.
//

#import "ViewController.h"
#import "DHKFabulous.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ViewController ()

@property (strong, nonatomic) DHKFABView* fab;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    @weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        [self doFAB];
    });
}

- (void)doFAB {
    DHKFABButton.appearance.backgroundColor = [UIColor redColor];
    [DHKFABLabel.appearance fab_setBackgroundColor:[UIColor purpleColor]];
    [DHKFABLabel.appearance fab_setTextcolor:[UIColor yellowColor]];
    
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
    
    _fab = [DHKFABView dhk_FABWithViewController:self andItems:@[item1, item2, item3, item4]];
    _fab.bottomPadding = 64.0;
}

@end
