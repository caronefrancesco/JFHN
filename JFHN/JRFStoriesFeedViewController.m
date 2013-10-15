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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:UIApplicationDidBecomeActiveNotification object:nil];
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
    self.navigationItem.title = @"Hacker News";
    UINib *nib = [UINib nibWithNibName:cellReuseIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:cellReuseIdentifier];
    [self.tableView registerNib:nib forCellReuseIdentifier:cellSizingReuseIdentifier];
    sizingCell = [self.tableView dequeueReusableCellWithIdentifier:cellSizingReuseIdentifier];
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor appTintColor];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refresh:(id)sender {
    [self.refreshControl beginRefreshing];
    [[JRFStoryStore sharedInstance] fetchStoriesWithCompletion:^(NSArray *stories, NSError *error) {
        if (!error) {
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }
    }];
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
    browser.navigationItem.title = story.title;
    browser.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissBrowser:)];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:browser];
    if (!story.isRead) {
        story.read = YES;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    if (comments) {
        [browser showCommentsAnimated:NO];
    }
    [self presentViewController:navController animated:YES completion:nil];
}

- (void) dismissBrowser:(id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self presentStoryAtIndexPath:indexPath withComments:NO];
}

- (void) storyCellDidSelectComments:(JRFStoryCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self presentStoryAtIndexPath:indexPath withComments:YES];
}

@end
