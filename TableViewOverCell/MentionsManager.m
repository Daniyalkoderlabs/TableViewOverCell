//
//  MentionsManager.m
//  HakawaiDemo
//
// @File Updated By Daniyal yousuf (daniyal.yousuf@koderlabs.com)

#import "MentionsManager.h"

#import "MentionEntity.h"

#import "HKWMentionsPlugin.h"
#import "NSString+Matcher.h"
// This #define determines whether or not custom trimming behavior should be enabled
//#define USE_CUSTOM_TRIMMING_BEHAVIOR

@interface MentionsManager () {
    NSMutableArray *contentArray;
    NSMutableArray *mentionList;
    NSString *temp;
    NSMutableArray *resultArray;
    NSAttributedString *finalAttributedString;
    NSString *specialIdentifier;
}
@property (nonatomic, strong) NSArray *fakeData;
@end

@implementation MentionsManager

// The mentions delegate is implemented as a singleton here for convenience.
+ (instancetype)sharedInstance {
    static MentionsManager *staticInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticInstance = [[self class] new];
        //[staticInstance setupFakeData];
    });
    return staticInstance;
}

- (void)setupData:(NSArray *)mentionsArray {
    self.fakeData = mentionsArray;
    contentArray = [NSMutableArray new];
    mentionList = [NSMutableArray new];
    temp = [NSString new];
    resultArray = [NSMutableArray new];
    specialIdentifier = @"▶︎";
}


#pragma mark - Protocol

// In this method, the plug-in gives us a mentions entity (one we previously returned in response to a query), and asks
//  us to provide a table view cell corresponding to that entity to be presented to the user.
- (UITableViewCell *)cellForMentionsEntity:(id<HKWMentionsEntityProtocol>)entity
                           withMatchString:(NSString *)matchString
                                 tableView:(UITableView *)tableView {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mentionsCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"mentionsCell"];
        cell.backgroundColor = LIGHT_GRAY_COLOR;
    }
    cell.textLabel.text = [entity entityName];
    cell.detailTextLabel.text = [entity entityId];
    return cell;
}

- (CGFloat)heightForCellForMentionsEntity:(id<HKWMentionsEntityProtocol>)entity tableView:(UITableView *)tableView {
    return 44;
}

// In this method, the plug-in gives us a search string and some metadata, as well as a block. Our responsibility is to
//  perform whatever work is necessary to get the entities for that search string (network call, database query, etc),
//  and then to call the completion block with an array of entity objects corresponding to the search string. See the
//  documentation for the method for more details.
- (void)asyncRetrieveEntitiesForKeyString:(NSString *)keyString
                               searchType:(HKWMentionsSearchType)type
                         controlCharacter:(unichar)character
                               completion:(void (^)(NSArray *, BOOL, BOOL))completionBlock {
    if (!completionBlock) {
        return;
    }
    NSArray *data = self.fakeData;

    // This #define determines whether or not the first response should be returned in a synchronous or asynchronous
    //  manner. This is useful for testing purposes.
#define SHOULD_BE_SYNCHRONOUS

#ifdef SHOULD_BE_SYNCHRONOUS
    NSMutableArray *buffer = [NSMutableArray array];
    if ([keyString length] == 0) {
        buffer = [data copy];
    }
    else {
        for (id<HKWMentionsEntityProtocol> entity in data) {
            NSString *name = [entity entityName];
            if ([[self class] string:keyString isPrefixOfString:name]) {
                [buffer addObject:entity];
            }
        }
    }
    completionBlock([buffer copy], YES, YES);
#else
    // Pretend to do a network request.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *buffer = [NSMutableArray array];
        if ([keyString length] == 0) {
            buffer = [data copy];
        }
        else {
            for (id<HKWMentionsEntityProtocol> entity in data) {
                NSString *name = [entity entityName];
                if ([[self class] string:keyString isPrefixOfString:name]) {
                    [buffer addObject:entity];
                }
            }
        }
        // Simulate multi-loading
        if ([buffer count] > 10) {
            // This simulates a three-part response.
            // The first part is returned to the mentions plug-in immediately. The next segment is returned after 2
            //  seconds, and the third part is returned after 6 seconds.
            NSArray *firstBuffer = [buffer objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
            NSArray *secondBuffer = [buffer objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 3)]];
            NSArray *finalBuffer = [buffer objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(6, [buffer count] - 6)]];
            completionBlock(firstBuffer, YES, NO);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                completionBlock(secondBuffer, YES, NO);
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                completionBlock(finalBuffer, YES, YES);
            });
        }
        else {
            // Normal, load all at once
            completionBlock([buffer copy], YES, YES);
        }
    });
#endif
}

// An optional method which allows us to specify whether or not a given entity can be 'trimmed'; for example, a mention
//  'John Doe' might be trimmed down to just 'John' by pressing the backspace key
- (BOOL)entityCanBeTrimmed:(id<HKWMentionsEntityProtocol>)entity {
    return NO;
}

#ifdef USE_CUSTOM_TRIMMING_BEHAVIOR
- (NSString *)trimmedNameForEntity:(id<LIREMentionsEntityProtocol>)entity {
    NSString *name = [entity entityName];
    if ([name length] < 8) {
        return name;
    }
    return [name substringToIndex:8];
}
#endif

- (UITableViewCell *)loadingCellForTableView:(UITableView *)tableView {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"loadingCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"loadingCell"];
        cell.backgroundColor = LIGHT_GRAY_COLOR;
    }
    cell.textLabel.text = @"... LOADING ...";
    return cell;
}

- (CGFloat)heightForLoadingCellInTableView:(UITableView *)tableView {
    return 44;
}


#pragma mark - State change delegate

// The state-change delegate allows your app to optionally listen in on certain important events that might happen to
//  the mentions plug-in. For example, implementing the optional method below allows your app to be notified whenever a
//  new mention is successfully created.
- (void)mentionsPlugin:(HKWMentionsPlugin *)plugin
        createdMention:(id<HKWMentionsEntityProtocol>)entity
            atLocation:(NSUInteger)location {
    NSLog(@"Mentions plug-in created mention named \"%@\" at location %ld", [entity entityName], (long) location);
}

- (void)selected:(id<HKWMentionsEntityProtocol>)entity atIndexPath:(NSIndexPath *)indexPath {
  //  NSString *tempString = [[[@"@" stringByAppendingString:@"["] stringByAppendingString:[entity entityName]] stringByAppendingString:@"]"];
    NSDictionary *data = @{@"name":[entity entityName],@"id":[entity entityId]};
    [mentionList addObject:data];
    NSLog(@"Mentions plug-in selected entity named \"%@\" at index %ld", [entity entityName], (long) [indexPath row]);
}

-(void)mentionsPlugin:(HKWMentionsPlugin *)plugin deletedMention:(id<HKWMentionsEntityProtocol>)entity atLocation:(NSUInteger)location {
    [self deleteFromList:entity];
}

#pragma mark - Utility

+ (BOOL)string:(NSString *)testString isPrefixOfString:(NSString *)compareString {
    if ([compareString length] == 0
        || [testString length] == 0
        || [compareString length] < [testString length]) {
        return NO;
    }
    NSString *prefix = ([testString length] == [compareString length]
                        ? compareString
                        : [compareString substringToIndex:[testString length]]);
    return [testString compare:prefix
                       options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)] == NSOrderedSame;
}

#pragma mark - HKTEXTVIEW DELEGATES
-(void)textView:(HKWTextView *)textView willBeginEditing:(BOOL)editing {}
-(void)textView:(HKWTextView *)textView willEndEditing:(BOOL)editing {}
-(void)textViewDidChange:(UITextView *)textView {}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        temp = textView.text;
        [self updateString];
        return NO;
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}


-(void)textViewDidEndEditing:(UITextView *)textView {
    temp = textView.text;
}


-(void)textViewDidBeginEditing:(UITextView *)textView {
    temp = @"";
    [resultArray removeAllObjects];
}


-(void)textViewDidEnterSingleLineViewportMode:(HKWTextView *)textView {
    
}
#pragma mark - Helper Methods
-(NSString *)formattedString:(NSString *)name andWithID:(NSString *)mentionid {
    return [[[[[specialIdentifier stringByAppendingString:@"{"] stringByAppendingString:name] stringByAppendingString:@":"] stringByAppendingString:mentionid] stringByAppendingString:@"}"];
}

-(void)updateString{
    NSMutableArray *decoded = [NSMutableArray new];
    for (int i = 0 ; i < mentionList.count; i++ ) {
        NSDictionary *data = (NSDictionary *)mentionList[i];
        if ([temp containsString:[data valueForKey:@"name"]] && ![decoded containsObject:[data valueForKey:@"name"]]) {
            [decoded addObject:[data valueForKey:@"name"]];
            NSString *decodedMention =  [self formattedString:[data valueForKey:@"name"] andWithID:[data valueForKey:@"id"]];
            temp = [temp stringByReplacingOccurrencesOfString:[mentionList[i] valueForKey:@"name"] withString:decodedMention];
        }
    }
    [self convertString:temp];
    
}

-(void)deleteFromList:(MentionEntity *)entity{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (int index = 0 ; index < self->mentionList.count; index ++) {
            NSDictionary *mentionData = self->mentionList[index];
            if ([[mentionData valueForKey:@"name"] isEqualToString: [entity entityName]]) {
                [self->mentionList removeObjectAtIndex:index];
            }
        }
        [self updateString];
    });
}

-(void)convertString:(NSString *)string{
    NSMutableArray *componentString = [[string componentsSeparatedByString:specialIdentifier] mutableCopy];
    for (int index = 0 ; index < componentString.count; index++) {
        NSAttributedString *resultedString = [self didMatched:componentString[index]];
        if (resultedString) {
            [resultArray addObject:resultedString];
        } else {
            
        }
    }
    finalAttributedString = [self convertArraytoAttribuedString:resultArray];
}

-(NSAttributedString *)didMatched:(NSString *)string{
    NSArray *results = [string matchWithRegex:@"\\{(.*?)\\}"];
    //result[0] = orignal content = {Daniyal Khan : 1}
    //result[1] = updated content = Daniyal Khan : 1
    if (results.count > 0) {
        //mentionName[1] = Actual Mention Name
        NSMutableArray *mentionName = [[results[1] componentsSeparatedByString:@":"] mutableCopy];
      
        //Replace {Daniyal Khan : 1} by Daniyal Khan in string.
        NSString *resultedString = [string stringByReplacingOccurrencesOfString:results[0] withString:mentionName[0]];
        
        //Create Attributed String For The Mentions
        //mentionName[0] = [self getAtttributedString:mentionName[0]];
        NSAttributedString *mentionAttributedName = [self getAtttributedString:mentionName[0]]; //Mention Name in Blue color
        
        //Converting Actual String to AttributedString
        NSMutableAttributedString *resultedAttributedString = [[[NSAttributedString alloc]initWithString:resultedString] mutableCopy];
        
        //Calculating the range of the text whose text color is to be changed i.e. Daniyal Khan
        NSRange mentionRange = [resultedAttributedString.mutableString rangeOfString:mentionName[0]];
        
        if (mentionRange.location != NSNotFound) {
            //Changing the color that range i.e. Daniyal Khan (mention name) color in actual attributed string.
            [resultedAttributedString replaceCharactersInRange:mentionRange withAttributedString:mentionAttributedName];
        }
        return resultedAttributedString;
    }else {
        //if index content is other than mention name converting it to attributed string to mainting a final attribuited array.
        NSAttributedString *res = [[NSAttributedString alloc]initWithString:string];
        return res;
     }
}

-(NSAttributedString *)getAtttributedString:(NSString *)content {
    UIColor *color = [UIColor blueColor]; // select needed color
    NSString *string = content; // the string to colorize
    NSDictionary *attrs = @{ NSForegroundColorAttributeName : color };
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:string attributes:attrs];
    return attrStr;
}

-(NSAttributedString *)convertArraytoAttribuedString:(NSMutableArray *)array {
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
    //Here's the final attributed array now converting array to nsattributedstring to make it final string...
    for (int i = 0; i < [array count]; i ++)
    {
        [attrStr appendAttributedString:[array objectAtIndex:i]];
        if ([((NSMutableAttributedString *)[array objectAtIndex:i]).string isEqualToString:@"\\"]) {
            [attrStr appendAttributedString:[[NSAttributedString alloc]initWithString:@" "]];
        }
    }
    return attrStr;
}
-(NSAttributedString *)finalString {
    return finalAttributedString;
}

@end
