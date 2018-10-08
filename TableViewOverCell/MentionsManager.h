//
//  MentionsManager.h
//  HakawaiDemo
//
//  Copyright (c) 2014 LinkedIn Corp. All rights reserved.
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
//  the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//

#import <Foundation/Foundation.h>

#import "HKWMentionsPlugin.h"
#import "HKWTextView.h"

#define LIGHT_GRAY_COLOR [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1]

@interface MentionsManager : NSObject <HKWMentionsDelegate, HKWMentionsStateChangeDelegate,UITextViewDelegate,HKWTextViewDelegate>

+ (instancetype)sharedInstance;
- (void)setupData:(NSArray *)mentionsArray;
- (NSAttributedString *)finalString;
@end
