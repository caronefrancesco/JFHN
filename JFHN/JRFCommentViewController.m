//
//  JRFCommentViewController.m
//  JFHN
//
//  Created by Jack Flintermann on 10/15/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFCommentViewController.h"
#import "JRFEntryStore.h"
#import "JRFEntry.h"
#import "JRFComment.h"
#import "JRFCommentCell.h"

static NSString *kCommentCellReuseIdentifier = @"JRFCommentCell";

@interface JRFCommentViewController()<JRFCommentCellDelegate> {
    JRFCommentCell *sizingCell;
    BOOL refreshing;
    NSMutableDictionary *cachedSizes;
}
@end

@implementation JRFCommentViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        cachedSizes = [NSMutableDictionary dictionary];
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
    CGRect frame = sizingCell.frame;
    frame.size.width = self.tableView.frame.size.width;
    sizingCell.frame = frame;
    [sizingCell setNeedsLayout];
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
        [[JRFEntryStore sharedInstance] fetchCommentsForStory:self.story withCompletion:^(NSArray *comments, NSError *error) {
            if (error) {
                refreshing = NO;
                [self.refreshControl endRefreshing];
#warning todo: error
            }
            else {
                refreshing = NO;
                self.story.comments = comments;
                self.story.commentCount = comments.count;
                [cachedSizes removeAllObjects];
                [self.tableView reloadData];
                [self.refreshControl endRefreshing];
#warning testing
                CGFloat avgHeight = self.tableView.contentSize.height / [self.tableView numberOfRowsInSection:0];
                NSLog(@"average height is %f", avgHeight);
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.story.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JRFComment *comment = [self.story commentAtIndex:indexPath.row];
    JRFCommentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCommentCellReuseIdentifier forIndexPath:indexPath];
    [cell configureWithComment:comment];
    cell.delegate = self;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    JRFComment *comment = [self.story commentAtIndex:indexPath.row];
    return comment.depth;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *cache = [cachedSizes objectForKey:indexPath];
    if (cache) {
        return [cache floatValue];
    }
    JRFComment *comment = [self.story commentAtIndex:indexPath.row];
    NSInteger indentation = [self tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    sizingCell.indentationLevel = indentation;
    sizingCell.frame = ({
        CGRect rect = sizingCell.frame;
        rect.size.width = self.view.frame.size.width;
        rect;
    });
    [sizingCell configureWithComment:comment];
    CGFloat height = [sizingCell intrinsicContentSize].height;
    [cachedSizes setObject:@(height) forKey:indexPath];
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *cache = [cachedSizes objectForKey:indexPath];
    if (cache) {
        return [cache floatValue];
    }
    return 267.0f;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.scrollViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.scrollViewDelegate scrollViewDidScroll:scrollView];
    }
}

- (void) commentCellDidSelectURL:(NSURL *)url {
    [self.urlDelegate controllerDidBlockLoadingRequest:[NSURLRequest requestWithURL:url]];
}

@end
