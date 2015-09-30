//
//  UINavigationController+umote.m
//  Umote
//
//  Created by Tony Chang Yi Cheng on 2014-04-15.
//  Copyright (c) 2014 MSMU. All rights reserved.
//

#import "UINavigationController+umote.h"

@implementation UINavigationController (umote)

- (BOOL) shouldAutorotate
{
    return [[self topViewController] shouldAutorotate];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return [[self topViewController] supportedInterfaceOrientations];
}

@end
