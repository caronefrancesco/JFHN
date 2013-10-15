//
//  JRFHNBrowserController.m
//  JFHN
//
//  Created by Jack Flintermann on 10/14/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFHNBrowserController.h"

@interface JRFHNBrowserController ()
@property(nonatomic, readwrite)UIView *commentView;
@end

@implementation JRFHNBrowserController

- (void) showCommentsAnimated:(BOOL)animated {
    [UIView animateWithDuration:0.3*animated animations:^{
        
    } completion:^(BOOL finished) {
        _commentsShown = YES;
    }];
}

- (void) hideCommentsAnimated:(BOOL)animated {
    [UIView animateWithDuration:0.3*animated animations:^{
        
    } completion:^(BOOL finished) {
        _commentsShown = NO;
    }];
}

- (void) viewDidLoad {
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
