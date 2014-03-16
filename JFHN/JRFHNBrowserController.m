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
#import "JRFEntry.h"

@implementation JRFHNBrowserController

- (void) showCommentsAnimated:(BOOL)animated {
    JRFCommentViewController *commentController = [JRFCommentViewController new];
    commentController.scrollViewDelegate = self;
    commentController.urlDelegate = self;
    commentController.story = self.story;
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
    
    UIBarButtonItem *commentItem = [self barButtonItemForImageName:@"842-chat-bubbles" target:self selector:@selector(toggleComments:)];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *readabilityItem = [self barButtonItemForImageName:@"860-glasses" target:self selector:@selector(toggleInstapaper:)];
    
    UIBarButtonItem *shareItem = [self barButtonItemForImageName:@"702-share" target:self selector:@selector(share:)];
    
    self.toolbarItems = @[commentItem, flex, readabilityItem, flex, shareItem];
    self.navController.delegate = self;
}

- (UIBarButtonItem *) barButtonItemForImageName:(NSString *)imageName target:(id)target selector:(SEL)selector {
    UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *highlightedImage = [[UIImage imageNamed:[imageName stringByAppendingString:@"-selected"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateHighlighted];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    button.tintColor = [UIColor appTintColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    return item;
}

- (void) navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super navigationController:navigationController willShowViewController:viewController animated:animated];
    viewController.toolbarItems = self.toolbarItems;
}

- (void) toggleComments:(id)sender {
    if (_commentsShown) {
        [self hideCommentsAnimated:YES];
    }
    else {
        [self showCommentsAnimated:YES];
    }
}

- (void) toggleInstapaper:(id)sender {
    [[self visibleWebViewController] toggleInstapaper];
}

- (void) share:(id)sender {
    [OSKPresentationManager sharedInstance].styleDelegate = self;
    OSKShareableContent *content = [OSKShareableContent contentFromURL:self.story.url];
    content.title = self.story.title;
    NSArray *excludedActivityTypes = @[OSKActivityType_API_AppDotNet, OSKActivityType_API_500Pixels, OSKActivityType_URLScheme_Instagram, OSKActivityType_URLScheme_1Password_Search, OSKActivityType_URLScheme_1Password_Browser, OSKActivityType_iOS_Facebook];
    [[OSKPresentationManager sharedInstance] presentActivitySheetForContent:content presentingViewController:self options:@{OSKActivityOption_ExcludedTypes: excludedActivityTypes}];
}

- (BOOL) osk_toolbarsUseUnjustifiablyBorderlessButtons {
    return YES;
}

#pragma mark - UINavigationControllerDelegate
//- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
//    return self;
//}

#pragma mark - UIViewControllerAnimatedTransitioning
//
//- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
//    return 0.3f;
//}
//
//- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
//    // Grab the from and to view controllers from the context
//    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    fromViewController.view.alpha = 1.0f;
//    toViewController.view.alpha = 0.0f;
//    toViewController.view.frame = fromViewController.view.frame;
//
//    fromViewController.view.userInteractionEnabled = NO;
//    
//    [transitionContext.containerView addSubview:fromViewController.view];
//    [transitionContext.containerView addSubview:toViewController.view];
//    
//    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
//        toViewController.view.alpha = 1.0f;
//        fromViewController.view.alpha = 0.0f;
//    } completion:^(BOOL finished) {
//        [transitionContext completeTransition:YES];
//    }];
//}

@end

