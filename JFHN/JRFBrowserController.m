//
//  JRFBrowserController.m
//  JFHN
//
//  Created by Jack Flintermann on 10/13/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFBrowserController.h"
#import "JRFURLRouter.h"
#import "JRFWebViewController.h"

@implementation JRFBrowserController

- (id) initWithUrl:(NSURL *)url {
    if (self = [super init]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        JRFWebViewController *webViewController = [[JRFWebViewController alloc] initWithUrlRequest:request];
        webViewController.delegate = self;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:webViewController];
        navController.delegate = self;
        [self addChildViewController:navController];
        _navController = navController;
        _toolbarMode = JRFToolbarModeHidden;
        navController.toolbarHidden = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.navController.view];
    self.navController.view.tintColor = self.view.tintColor;
    UIScreenEdgePanGestureRecognizer *emptyBackGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedFromLeft:)];
    emptyBackGestureRecognizer.edges = UIRectEdgeLeft;
    UIScreenEdgePanGestureRecognizer *screenEdgeGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedFromRight:)];
    screenEdgeGestureRecognizer.edges = UIRectEdgeRight;
    [self.navController.view addGestureRecognizer:screenEdgeGestureRecognizer];
    [self.navController.view addGestureRecognizer:emptyBackGestureRecognizer];
    UILabel *label = [[UILabel alloc] initWithFrame:self.navigationController.navigationBar.frame];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 2;
    label.attributedText = [[NSAttributedString alloc] initWithString:self.navigationItem.title attributes:[[UINavigationBar appearance] titleTextAttributes]];
    label.textAlignment = NSTextAlignmentCenter;
    [label setAdjustsFontSizeToFitWidth:YES];
    label.minimumScaleFactor = 0.5;
    self.navigationItem.titleView = label;
}

- (void) pannedFromLeft:(UIScreenEdgePanGestureRecognizer *)sender {
    if (self.navController.viewControllers.count == 1) {
        [sender requireGestureRecognizerToFail:self.navController.interactivePopGestureRecognizer];
        CGPoint translationInView = [sender translationInView:self.navController.view];
        switch (sender.state) {
            case UIGestureRecognizerStateBegan:
            break;
            case UIGestureRecognizerStateChanged: {
                self.navController.view.transform = CGAffineTransformMakeTranslation(log(translationInView.x+1) * 5, 0);
                break;
            }
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateFailed: {
                [UIView animateWithDuration:0.2 animations:^{
                    self.navController.view.transform = CGAffineTransformIdentity;
                }];
                break;
            }
            default:
                break;
        }
    }
}

- (void) webViewController:(JRFWebViewController *)controller didBlockLoadingRequest:(NSURLRequest *)request {
    JRFWebViewController *webViewController = [[JRFWebViewController alloc] initWithUrlRequest:request];
    webViewController.delegate = self;
    [self.navController pushViewController:webViewController animated:NO];
}

//
//- (id<UIViewControllerAnimatedTransitioning>) animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
//    return self;
//}
//
//- (id<UIViewControllerAnimatedTransitioning>) animationControllerForDismissedController:(UIViewController *)dismissed {
//    return self;
//}
//
//- (NSTimeInterval) transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
//    return 1.0;
//}
//
//- (void) animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
//    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//
//}


- (void) pannedFromRight:(UIScreenEdgePanGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            UIViewController *testController = [UIViewController new];
            testController.transitioningDelegate = self;
            break;
        }
        case UIGestureRecognizerStateChanged:
            break;
        case UIGestureRecognizerStateEnded:
            break;
        case UIGestureRecognizerStateCancelled:
            
        default:
            break;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.toolbarMode == JRFToolbarModeInteractive) {
        [self hideToolbarAnimated:YES];
    }
}

- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView
                      withVelocity:(CGPoint)velocity
               targetContentOffset:(inout CGPoint *)targetContentOffset {
    // we're rubberbanding from the top
    if (scrollView.contentOffset.y < (-1*scrollView.contentInset.top)) {
        return;
    }
    // we are going up
    if (velocity.y < -1 && self.toolbarMode & JRFToolbarModeVisible) {
        [self showToolbarAnimated:YES];
    }
}

- (void) setToolbarMode:(JRFToolbarMode)toolbarMode {
    _toolbarMode = toolbarMode;
    if (toolbarMode & JRFToolbarModeVisible) {
        [self showToolbarAnimated:NO];
    }
    else {
        [self hideToolbarAnimated:NO];
    }
}

- (UIToolbar *) toolbar {
    return self.navController.toolbar;
}

- (void) hideToolbarAnimated:(BOOL)animated {
    [self.navController setToolbarHidden:YES animated:animated];
}

- (void) showToolbarAnimated:(BOOL)animated {
    [self.navController setToolbarHidden:NO animated:animated];
}

- (void) navigationController:(JRFWebViewController *)fromController
       willShowViewController:(JRFWebViewController *)toController animated:(BOOL)animated {
    self.navigationController.interactivePopGestureRecognizer.enabled = self.navController.viewControllers.count < 2;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
#warning TODO: drop the stack
    // Dispose of any resources that can be recreated.
}

@end
