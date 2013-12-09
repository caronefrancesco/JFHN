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
    BOOL refreshing;
}
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
    UINib *nib = [UINib nibWithNibName:kCommentCellReuseIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:kCommentCellReuseIdentifier];
    self.tableView.tableFooterView = [UIView new];
    sizingCell = [nib instantiateWithOwner:nil options:nil][0];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [[UIColor appTintColor] adjustedColorForRefreshControl];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self fetchComments];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (refreshing) {
        if (self.tableView.contentOffset.y == 0){
            self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
            [self.refreshControl beginRefreshing];
        }
    }
}

- (void) refresh:(UIRefreshControl *)sender {
    [self fetchComments];
}

- (void) fetchComments {
    if (self.story && !refreshing) {
        refreshing = YES;
        [[JRFStoryStore sharedInstance] fetchCommentsForStory:self.story withCompletion:^(NSArray *comments, NSError *error) {
            if (error) {
                refreshing = NO;
                [self.refreshControl endRefreshing];
#warning todo: error
            }
            else {
                refreshing = NO;
                self.story.comments = comments;
                self.story.commentCount = comments.count;
                [self.tableView reloadData];
                [self.refreshControl endRefreshing];
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
    return self.story.comments.count;
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
