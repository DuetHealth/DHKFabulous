//
//  DHKFABItem.h
//  DHKFabulous
//
//  Created by Tyler Hugenberg on 1/14/15.
//  Copyright (c) 2015 Duet Health. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DHKFABItem : NSObject

- (instancetype)initWithTitle:(NSString*)title
                         icon:(UIImage*)icon
                    andAction:(void (^)())action;



@end
