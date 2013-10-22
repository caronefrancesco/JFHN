//
//  JRFHNBrowserController.m
//  JFHN
//
//  Created by Jack Flintermann on 10/14/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFHNBrowserController.h"
#import "JRFCommentViewController.h"

@implementation JRFHNBrowserController

- (void) showCommentsAnimated:(BOOL)animated {
    JRFCommentViewController *commentController = [JRFCommentViewController new];
    commentController.scrollViewDelegate = self;
    commentController.entryId = self.entryId;
    [self.navController pushViewController:commentController animated:animated];
}

- (void) hideCommentsAnimated:(BOOL)animated {
    [self.navController popViewControllerAnimated:animated];
}

- (void) viewDidLoad {
    self.view.tintColor = [UIColor appTintColor];
    [super viewDidLoad];
    UIImage *image = [UIImage imageNamed:@"842-chat-bubbles"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIBarButtonItem *commentItem = [[UIBarButtonItem alloc] initWithImage:image landscapeImagePhone:image style:UIBarButtonItemStylePlain target:self action:@selector(toggleComments:)];
    commentItem.tintColor = [UIColor appTintColor];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
    self.toolbar.items = @[commentItem, flex, shareItem];
}

- (void) toggleComments:(id)sender {
    
}

- (void) share:(id)sender {
    
}

@end
