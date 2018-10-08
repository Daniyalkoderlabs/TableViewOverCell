//
//  MentionTableViewCell.h
//  TableViewOverCell
//
//  Created by Daniyal Yousuf on 7/16/18.
//  Copyright © 2018 Daniyal Yousuf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKWTextView.h"
#import "HKWMentionsPlugin.h"
@interface MentionTableViewCell : UITableViewCell <HKWAbstractionLayerDelegate,HKWTextViewDelegate>
@property (weak, nonatomic) IBOutlet HKWTextView *mentionTextView;
@property (nonatomic, strong) HKWMentionsPlugin *plugin;
@property (nonatomic, strong) NSArray *fakeData;
@end
