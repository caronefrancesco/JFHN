//
//  JRFBrowserController.m
//  JFHN
//
//  Created by Jack Flintermann on 10/13/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFBrowserController.h"
#import "JRFWebViewController.h"

@interface JRFBrowserController()
@property(nonatomic, weak) UITapGestureRecognizer *scrollToTopGestureRecognizer;
@end

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
//    UIScreenEdgePanGestureRecognizer *screenEdgeGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedFromRight:)];
//    screenEdgeGestureRecognizer.edges = UIRectEdgeRight;
//    [self.navController.view addGestureRecognizer:screenEdgeGestureRecognizer];
    [self.navController.view addGestureRecognizer:emptyBackGestureRecognizer];
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spacerView];
    CGRect rect = self.navigationController.navigationBar.bounds;
    rect.size.width -= 100;
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont primaryAppFont];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor appTintColor];
    label.text = self.navigationItem.title;
    label.numberOfLines = 3;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.5;
    self.navigationItem.titleView = label;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleTapped:)];
    gestureRecognizer.delegate = self;
    self.scrollToTopGestureRecognizer = gestureRecognizer;
    [self.navigationController.navigationBar addGestureRecognizer:gestureRecognizer];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar removeGestureRecognizer:self.scrollToTopGestureRecognizer];
    self.scrollToTopGestureRecognizer = nil;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    CGPoint location = [touch locationInView:self.navigationItem.titleView];
    return CGRectContainsPoint(self.navigationItem.titleView.frame, location);
}

- (void) titleTapped:(id)sender {
    if (self.navController.toolbarHidden) {
        [self showToolbarAnimated:YES];
    }
    else {
        UIScrollView *scrollView = self.visibleWebViewController.webView.scrollView;
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, -scrollView.contentInset.top) animated:YES];
    }
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

- (void) controllerDidBlockLoadingRequest:(NSURLRequest *)request {
    JRFWebViewController *webViewController = [[JRFWebViewController alloc] initWithUrlRequest:request];
    webViewController.delegate = self;
    [self.navController pushViewController:webViewController animated:NO];
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

- (void) navigationController:(UINavigationController *)navController
       willShowViewController:(JRFWebViewController *)toController animated:(BOOL)animated {
    BOOL onePageVisible = self.navController.viewControllers.count < 2;
    self.navigationController.interactivePopGestureRecognizer.enabled = onePageVisible;
    self.navController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
//#warning TODO: drop the stack
    // Dispose of any resources that can be recreated.
}

- (JRFWebViewController *)visibleWebViewController {
    UIViewController *controller = [self.navController visibleViewController];
    if ([controller isKindOfClass:[JRFWebViewController class]]) {
        return (JRFWebViewController *)controller;
    }
    return nil;
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
//
//
//- (void) pannedFromRight:(UIScreenEdgePanGestureRecognizer *)sender {
//    switch (sender.state) {
//        case UIGestureRecognizerStateBegan: {
//            UIViewController *testController = [UIViewController new];
//            testController.transitioningDelegate = self;
//            break;
//        }
//        case UIGestureRecognizerStateChanged:
//            break;
//        case UIGestureRecognizerStateEnded:
//            break;
//        case UIGestureRecognizerStateCancelled:
//
//        default:
//            break;
//    }
//}


@end
