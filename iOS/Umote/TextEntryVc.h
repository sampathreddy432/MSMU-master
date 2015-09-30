//
//  TextEntryVc.h
//  Umote
//
//  Created by Tony Chang Yi Cheng on 2014-04-15.
//  Copyright (c) 2014 MSMU. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextEntryDelegate <NSObject>

- (void)didEnterText:(NSString *)text;

@end

@interface TextEntryCell : UITableViewCell

@end

@interface TextEntryVc : UIViewController

@property (nonatomic, assign) id<TextEntryDelegate> delegate;

@end
