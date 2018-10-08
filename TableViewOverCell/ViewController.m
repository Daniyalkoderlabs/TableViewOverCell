//
//  ViewController.m
//  TableViewOverCell
//
//  Created by Daniyal Yousuf on 7/16/18.
//  Copyright © 2018 Daniyal Yousuf. All rights reserved.
//

#import "ViewController.h"
#import "HKWTextView.h"
#import "MentionTableViewCell.h"
@interface ViewController () <UITableViewDelegate,UITableViewDataSource> {
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MentionTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"mentiontextview"];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200.0;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MentionTableViewCell *ccell = [tableView dequeueReusableCellWithIdentifier:@"mentiontextview"];
    return ccell;
}
@end
