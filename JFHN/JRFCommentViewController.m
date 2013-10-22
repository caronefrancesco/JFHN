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
#import "JRFCommentCell.h"

static NSString *kCommentCellReuseIdentifier = @"JRFCommentCell";

@interface JRFCommentViewController () {
    JRFCommentCell *sizingCell;
}
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
    UINib *nib = [UINib nibWithNibName:kCommentCellReuseIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:kCommentCellReuseIdentifier];
    self.tableView.tableFooterView = [UIView new];
    sizingCell = [nib instantiateWithOwner:nil options:nil][0];
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

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    CGRect sizingFrame = sizingCell.frame;
    sizingFrame.size.width = self.tableView.frame.size.height;
    sizingCell.frame = sizingFrame;
    [sizingCell layoutSubviews];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.tableView reloadData];
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
    JRFCommentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCommentCellReuseIdentifier forIndexPath:indexPath];
    [cell configureWithComment:comment];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    JRFComment *comment = [self.story commentAtIndex:indexPath.row];
    return comment.depth;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    JRFComment *comment = [self.story commentAtIndex:indexPath.row];
    NSInteger indentation = [self tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    sizingCell.indentationLevel = indentation;
    [sizingCell configureWithComment:comment];
    return [sizingCell intrinsicContentSize].height;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.scrollViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.scrollViewDelegate scrollViewDidScroll:scrollView];
    }
}

@end
