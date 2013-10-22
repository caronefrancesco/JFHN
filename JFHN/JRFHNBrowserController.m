//
//  JRFHNBrowserController.m
//  JFHN
//
//  Created by Jack Flintermann on 10/14/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFHNBrowserController.h"
#import "JRFCommentViewController.h"
#import "JRFWebViewController+Instapaper.h"

@implementation JRFHNBrowserController

- (void) showCommentsAnimated:(BOOL)animated {
    JRFCommentViewController *commentController = [JRFCommentViewController new];
    commentController.scrollViewDelegate = self;
    commentController.entryId = self.entryId;
    _commentsShown = YES;
    [self.navController pushViewController:commentController animated:animated];
}

- (void) hideCommentsAnimated:(BOOL)animated {
    _commentsShown = NO;
    [self.navController popViewControllerAnimated:animated];
}

- (void) viewDidLoad {
    self.view.tintColor = [UIColor appTintColor];
    [super viewDidLoad];
    UIImage *image = [[UIImage imageNamed:@"842-chat-bubbles"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *highlightedImage = [[UIImage imageNamed:@"842-chat-bubbles-selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(toggleComments:) forControlEvents:UIControlEventTouchUpInside];
    button.tintColor = [UIColor appTintColor];
    UIBarButtonItem *commentItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
    self.toolbarItems = @[commentItem, flex, shareItem];
    NSLog(@"");
}

- (void) navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super navigationController:navigationController willShowViewController:viewController animated:animated];
    viewController.toolbarItems = self.toolbarItems;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"");
}

- (void) toggleComments:(id)sender {
    if (_commentsShown) {
        [self hideCommentsAnimated:YES];
    }
    else {
        [self showCommentsAnimated:YES];
    }
}

- (void) share:(id)sender {
    [[self visibleWebViewController] toggleInstapaper];
}

@end
