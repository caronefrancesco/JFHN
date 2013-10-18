//
//  JRFStoriesFeedViewController.m
//  JFHN
//
//  Created by Jack Flintermann on 10/11/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFStoriesFeedViewController.h"
#import "JRFHNBrowserController.h"
#import "JRFStoryStore.h"
#import "JRFStory.h"
#import "NSDate+Utility.h"

static NSString *cellReuseIdentifier = @"JRFStoryCell";
static NSString *cellSizingReuseIdentifier = @"JRFStorySizingCell";

@interface JRFStoriesFeedViewController() {
    JRFStoryCell *sizingCell;
}
@end

@implementation JRFStoriesFeedViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeDidUpdate:) name:JRFStoryStoreDidRefreshNotification object:nil];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UINib *nib = [UINib nibWithNibName:cellReuseIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:cellReuseIdentifier];
    [self.tableView registerNib:nib forCellReuseIdentifier:cellSizingReuseIdentifier];
    sizingCell = [self.tableView dequeueReusableCellWithIdentifier:cellSizingReuseIdentifier];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [self refreshControlString];
    CGFloat h, s, b;
    [[UIColor appTintColor] getHue:&h saturation:&s brightness:&b alpha:nil];
    refreshControl.tintColor = [UIColor colorWithHue:h saturation:s/2 brightness:b alpha:1.0];;
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    self.navigationItem.backBarButtonItem.title = @"";
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Hacker News";
    // hack to fix a uirefreshcontrol layout bug
    [self.refreshControl beginRefreshing];
    [self.refreshControl endRefreshing];
}

- (void) viewDidAppear:(BOOL)animated {
    if ([self.tableView numberOfRowsInSection:0] == 0) {
        [self refresh:nil];
        CGPoint newOffset = CGPointMake(0, -[self.tableView contentInset].top);
        [self.tableView setContentOffset:newOffset animated:YES];
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.tableView.tableFooterView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    });
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";
}

- (void) storeDidUpdate:(NSNotification *)notification {
    [self updateTableAndRefreshControl];
}

- (void) refresh:(id)sender {
    [self.refreshControl beginRefreshing];
    [[JRFStoryStore sharedInstance] fetchStoriesWithCompletion:^(NSArray *stories, NSError *error) {
        if (error) {
            [self.refreshControl endRefreshing];
        }
        else {
            [self updateTableAndRefreshControl];
        }
    }];
}

- (NSAttributedString *) refreshControlString {
    NSDate *lastUpdated = [[JRFStoryStore sharedInstance] lastFetchDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *lastUpdatedString = @"Never";
    if (lastUpdated) {
        dateFormatter.dateStyle = [lastUpdated isToday] ? NSDateFormatterNoStyle : NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        lastUpdatedString = [dateFormatter stringFromDate:lastUpdated];
    }
    lastUpdatedString = [@"Last Updated: " stringByAppendingString:lastUpdatedString];
    return [[NSAttributedString alloc] initWithString:lastUpdatedString
                                           attributes:@{NSFontAttributeName: [UIFont secondaryAppFontWithSize:12],
                                                        NSForegroundColorAttributeName: [UIColor appTintColor]}];
}

- (void) updateTableAndRefreshControl {
    self.refreshControl.attributedTitle = [self refreshControlString];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}


- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    CGRect sizingFrame = sizingCell.frame;
    sizingFrame.size.width = self.tableView.frame.size.height;
    sizingCell.frame = sizingFrame;
    [sizingCell layoutSubviews];
    [self.tableView reloadData];
}

#pragma mark - Table View

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    JRFStory *story = [[[JRFStoryStore sharedInstance] allStories] objectAtIndex:indexPath.row];
    return [sizingCell heightForStory:story];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[JRFStoryStore sharedInstance] allStories] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JRFStoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier
                                                            forIndexPath:indexPath];
    cell.delegate = self;
    JRFStory *story = [[[JRFStoryStore sharedInstance] allStories] objectAtIndex:indexPath.row];
    [cell configureWithStory:story];
    return cell;
}

#pragma mark - Story cell delegate

- (void)presentStoryAtIndexPath:(NSIndexPath *)indexPath withComments:(BOOL)comments {
    JRFStory *story = [[[JRFStoryStore sharedInstance] allStories] objectAtIndex:indexPath.row];
    JRFHNBrowserController *browser = [[JRFHNBrowserController alloc] initWithUrl:story.url];
    browser.toolbarMode = JRFToolbarModeInteractive;
    browser.navigationItem.title = story.title;
    if (!story.isRead) {
        story.read = YES;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    if (comments) {
        browser.entryId = story.storyId;
        [browser showCommentsAnimated:NO];
    }
    [self.navigationController pushViewController:browser animated:YES];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self presentStoryAtIndexPath:indexPath withComments:NO];
}

- (void) storyCellDidSelectComments:(JRFStoryCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self presentStoryAtIndexPath:indexPath withComments:YES];
}

@end
