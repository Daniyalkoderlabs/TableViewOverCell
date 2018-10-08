
//
//  MentionTableViewCell.m
//  TableViewOverCell
//
//  Created by Daniyal Yousuf on 7/16/18.
//  Copyright © 2018 Daniyal Yousuf. All rights reserved.
//

#import "MentionTableViewCell.h"
#import "MentionsManager.h"
#import "MentionEntity.h"
#import "HKWTextView.h"
#import "HKWMentionsPlugin.h"
BOOL HKW_systemVersionIsAtLeast(NSString *version);

@implementation MentionTableViewCell {
    NSArray *mentionsData;
    __weak IBOutlet UILabel *resultedLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupMentionTextView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setupMentionTextView{
    [[MentionsManager sharedInstance] setupData:[self data]];  //Bind data that is needed to be shown.
    self.mentionTextView.layer.borderWidth = 0.5;
    self.mentionTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    HKWMentionsChooserPositionMode mode = HKWMentionsChooserPositionModeEnclosedTop;
    // In this demo, the user may explicitly begin a mention with either the '@' or '+' characters
    NSCharacterSet *controlCharacters = [NSCharacterSet characterSetWithCharactersInString:@"@+"];
    // The user may also begin a mention by typing three characters (set searchLength to 0 to disable)
    HKWMentionsPlugin *mentionsPlugin = [HKWMentionsPlugin mentionsPluginWithChooserMode:mode
                                                                       controlCharacters:controlCharacters
                                                                            searchLength:3];
    mentionsPlugin.resumeMentionsCreationEnabled = YES;
    // Add edge insets so chooser view doesn't overlap the text view's cosmetic grey border
    mentionsPlugin.chooserViewEdgeInsets = UIEdgeInsetsMake(2, 0.5, 0.5, 0.5);
    self.plugin = mentionsPlugin;
    self.plugin.chooserViewBackgroundColor = LIGHT_GRAY_COLOR;
    // The mentions plug-in requires a delegate, which provides it with mentions entities in response to a query string
    mentionsPlugin.delegate = [MentionsManager sharedInstance];
    mentionsPlugin.stateChangeDelegate = [MentionsManager sharedInstance];
    self.mentionTextView.controlFlowPlugin = mentionsPlugin;
    self.mentionTextView.externalDelegate = [MentionsManager sharedInstance];
    self.mentionTextView.simpleDelegate = [MentionsManager sharedInstance];
}

-(NSArray *)data {
    return @[[MentionEntity entityWithName:@"Alan Perlis" entityId:@"1"],
      [MentionEntity entityWithName:@"Maurice Wilkes" entityId:@"2"],
      [MentionEntity entityWithName:@"Richard Hamming" entityId:@"3"],
      [MentionEntity entityWithName:@"Marvin Minsky" entityId:@"4"],
      [MentionEntity entityWithName:@"James Wilkinson" entityId:@"5"],
      [MentionEntity entityWithName:@"John McCarthy" entityId:@"6"],  // DupeTesting: First instance
      [MentionEntity entityWithName:@"Edsger Dijkstra" entityId:@"7"],
      [MentionEntity entityWithName:@"Charles Bachman" entityId:@"8"],
      [MentionEntity entityWithName:@"Donald Knuth" entityId:@"9"],
      [MentionEntity entityWithName:@"Allen Newell" entityId:@"10"],
      [MentionEntity entityWithName:@"Herbert Simon" entityId:@"11"],
      [MentionEntity entityWithName:@"Michael Rabin" entityId:@"12"],
      [MentionEntity entityWithName:@"Dana Scott" entityId:@"13"],
      [MentionEntity entityWithName:@"John Backus" entityId:@"14"],
      [MentionEntity entityWithName:@"Robert Floyd" entityId:@"15"],
      [MentionEntity entityWithName:@"Kenneth Iverson" entityId:@"16"],
      [MentionEntity entityWithName:@"Antony Hoare" entityId:@"17"],
      [MentionEntity entityWithName:@"Edgar Codd" entityId:@"18"],
      [MentionEntity entityWithName:@"Stephen Cook" entityId:@"19"],
      [MentionEntity entityWithName:@"Dennis Ritchie" entityId:@"20"],
      [MentionEntity entityWithName:@"Kenneth Thompson" entityId:@"21"],
      [MentionEntity entityWithName:@"Niklaus Wirth" entityId:@"22"],
      [MentionEntity entityWithName:@"Richard Karp" entityId:@"23"],
      [MentionEntity entityWithName:@"John Hopcroft" entityId:@"24"],
      [MentionEntity entityWithName:@"Robert Tarjan" entityId:@"25"],
      [MentionEntity entityWithName:@"John McCarthy" entityId:@"6"],  // DupeTesting: Second instance. New Page.
      [MentionEntity entityWithName:@"John McCarthy" entityId:@"6"]]; // DupeTesting: Third instance. Same Page.
}


- (IBAction)didTappedPost:(UIButton *)sender {
    resultedLabel.attributedText = [[NSAttributedString alloc]initWithString:@""];
    NSAttributedString *finalAttr = [[MentionsManager sharedInstance]finalString];
    resultedLabel.attributedText = finalAttr;
}



@end
