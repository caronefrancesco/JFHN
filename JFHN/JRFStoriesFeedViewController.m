//
//  JRFStoriesFeedViewController.m
//  JFHN
//
//  Created by Jack Flintermann on 10/11/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFStoriesFeedViewController.h"
#import "JRFHNBrowserController.h"
#import "JRFEntryStore.h"
#import "JRFEntry.h"
#import "NSDate+Utility.h"
#import <MagicalRecord/NSManagedObjectContext+MagicalRecord.h>
#import <CoreData/CoreData.h>

static NSString *cellReuseIdentifier = @"JRFEntryCell";
static NSString *cellSizingReuseIdentifier = @"JRFStorySizingCell";

@interface JRFStoriesFeedViewController() {
    JRFEntryCell *sizingCell;
    __weak UIView *statusBarBackground;
}
@end

@implementation JRFStoriesFeedViewController

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
    refreshControl.tintColor = [[UIColor appTintColor] adjustedColorForRefreshControl];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    self.title = @"Hacker News";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [[self fetchedResultsController] performFetch:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // hack to fix a uirefreshcontrol layout bug
    [self.refreshControl beginRefreshing];
    [self.refreshControl endRefreshing];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    statusBarBackground = view;
    statusBarBackground.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    [self.navigationController.view addSubview:statusBarBackground];
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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [statusBarBackground removeFromSuperview];
    statusBarBackground = nil;
}

- (void) refresh:(id)sender {
    [self.refreshControl beginRefreshing];
    [[JRFEntryStore sharedInstance] fetchStoriesWithCompletion:^(NSArray *stories, NSError *error) {
        if (error) {
            [self.refreshControl endRefreshing];
        }
        else {
            [self updateTableAndRefreshControl];
        }
    }];
}

- (NSAttributedString *) refreshControlString {
    NSDate *lastUpdated = [[JRFEntryStore sharedInstance] lastFetchDate];
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
    [self.refreshControl endRefreshing];
}

#pragma mark - Table View

- (JRFEntry *) entryAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [[[self fetchedResultsController] fetchedObjects] objectAtIndex:indexPath.row];
    return [MTLManagedObjectAdapter modelOfClass:[JRFEntry class] fromManagedObject:object error:nil];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    JRFEntry *entry = [self entryAtIndexPath:indexPath];
    sizingCell.frame = ({
        CGRect rect = sizingCell.frame;
        rect.size.width = self.view.frame.size.width;
        rect;
    });
    return [sizingCell heightForEntry:entry];
}

#pragma mark - Story cell delegate

- (void)presentStoryAtIndexPath:(NSIndexPath *)indexPath withComments:(BOOL)comments {
    JRFEntry *entry = [self entryAtIndexPath:indexPath];
    JRFHNBrowserController *browser = [[JRFHNBrowserController alloc] initWithUrl:entry.url];
    browser.toolbarMode = JRFToolbarModeInteractive;
    browser.navigationItem.title = entry.title;
    browser.story = entry;
    if (!entry.readAt) {
        [[JRFEntryStore sharedInstance] markEntryAsRead:entry];
    }
    if (comments) {
        [browser showCommentsAnimated:NO];
    }
    [self.navigationController pushViewController:browser animated:YES];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self presentStoryAtIndexPath:indexPath withComments:NO];
}

- (void)entryCellDidSelectComments:(JRFEntryCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self presentStoryAtIndexPath:indexPath withComments:YES];
}

- (void)entryCellDidPerformHideGesture:(JRFEntryCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    JRFEntry *entry = [self entryAtIndexPath:indexPath];
    [[JRFEntryStore sharedInstance] markEntryAsUninteresting:entry];
}

- (NSFetchedResultsController *)newFetchedResultsController {
    NSFetchRequest *fetchRequest = [[JRFEntryStore sharedInstance] frontpageStoryFetchRequest];
    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_rootSavingContext];
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:ctx sectionNameKeyPath:nil cacheName:nil];
    frc.delegate = self;
    return frc;
}

- (NSString *)cellIdentifier {
    return cellReuseIdentifier;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    JRFEntry *entry = [self entryAtIndexPath:indexPath];
    JRFEntryCell *entryCell = (JRFEntryCell *)cell;
    entryCell.delegate = self;
    [entryCell configureWithEntry:entry];
}

@end
