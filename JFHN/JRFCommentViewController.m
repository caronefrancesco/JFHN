//
//  JRFCommentViewController.m
//  JFHN
//
//  Created by Jack Flintermann on 10/15/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFCommentViewController.h"
#import "JRFStoryStore.h"
#import "JRFStory.h"
#import "JRFComment.h"

static NSString *commentCellReuseIdentifier = @"JRFCommentCell";

@interface JRFCommentViewController ()
@property(nonatomic) JRFStory *story;
@end

@implementation JRFCommentViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *commentView = [[UIToolbar alloc] init];
    self.tableView.backgroundView = commentView;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:commentCellReuseIdentifier];
    if (self.entryId) {
        [[JRFStoryStore sharedInstance] fetchDetailsForStoryId:self.entryId withCompletion:^(JRFStory *story, NSError *error) {
            if (error) {
#warning todo: error
            }
            else {
                self.story = story;
                [self.tableView reloadData];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.story commentCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JRFComment *comment = [self.story commentAtIndex:indexPath.row];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:commentCellReuseIdentifier forIndexPath:indexPath];
    cell.textLabel.text = comment.text;
    cell.detailTextLabel.text = comment.authorName;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    JRFComment *comment = [self.story commentAtIndex:indexPath.row];
    return comment.depth;
}

@end
