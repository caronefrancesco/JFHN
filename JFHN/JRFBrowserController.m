//
//  JRFBrowserController.m
//  JFHN
//
//  Created by Jack Flintermann on 10/13/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFBrowserController.h"

@interface UIView(RecursiveChild)
- (BOOL) isParentOfView:(UIView *)view;
@end

@implementation UIView(RecursiveChild)

- (BOOL) isParentOfView:(UIView *)view {
    if (view == self) {
        return YES;
    }
    for (UIView *subView in self.subviews) {
        if ([subView isParentOfView:view]) {
            return YES;
        }
    }
    return NO;
}

@end

@interface JRFWebViewController : UIViewController
@property(nonatomic, readonly) NSURL *url;
@property(nonatomic, readonly) UIWebView *webView;
@property(nonatomic, readonly) UIProgressView *progressView;
- (id) initWithUrl:(NSURL *)url delegate:(id<UIWebViewDelegate>)delegate;
@end

@implementation JRFWebViewController
@synthesize webView = _webView, url = _url;
- (id) initWithUrl:(NSURL *)url delegate:(id<UIWebViewDelegate, UIScrollViewDelegate>)delegate {
    self = [super init];
    if (self) {
        UIWebView *webView = [[UIWebView alloc] init];
        webView.scalesPageToFit = YES;
        webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        webView.delegate = delegate;
        webView.scrollView.delegate = delegate;
        webView.backgroundColor = [UIColor whiteColor];
        _webView = webView;
        _url = url;
    }
    return self;
}

- (void) dealloc {
    [self.progressView removeObserver:self forKeyPath:@"progress"];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.view.autoresizesSubviews = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    
    progressView.progressTintColor = [UIColor appTintColor];
    [progressView addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionOld context:nil];
    _progressView = progressView;
    _progressView.progress = 0.0f;
    self.webView.frame = self.view.bounds;
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect progressFrame = _progressView.frame;
    progressFrame.origin.y = [self.topLayoutGuide length];
    progressFrame.size.width = self.view.frame.size.width;
    _progressView.frame = progressFrame;
}

- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context {
    if (object == self.progressView && [keyPath isEqualToString:@"progress"]) {
        CGFloat progress = self.progressView.progress;
        NSLog(@"progress: %f", progress);
        if (progress > 0.99f) {
            [UIView animateWithDuration:0.3 animations:^{
                self.progressView.alpha = 0.0f;
            }];
        }
    }
}

@end

@interface JRFBrowserController() {
    CGPoint backPanPoint;
}

@end

@implementation JRFBrowserController

- (id) initWithUrl:(NSURL *)url {
    if (self = [super init]) {
        NSString *progressEstimateName = [@"WebProgressEstimateChanged" stringByAppendingString:@"Notification"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notified:) name:progressEstimateName object:nil];
        JRFWebViewController *webViewController = [[JRFWebViewController alloc] initWithUrl:url delegate:self];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:webViewController];
        navController.delegate = self;
        [self addChildViewController:navController];
        _navController = navController;
        _toolbarMode = JRFToolbarModeHidden;
        navController.toolbarHidden = YES;
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void) notified:(NSNotification *)sender {
    NSString *key = @"WebProgressEstimatedProgressKey";
    CGFloat progress = [[sender.userInfo objectForKey:key] floatValue];
    JRFWebViewController *controller = (JRFWebViewController *)self.navController.visibleViewController;
    if ([controller respondsToSelector:@selector(progressView)]) {
        controller.progressView.progress = progress;
    }
}

- (id<UIViewControllerAnimatedTransitioning>) animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>) animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

- (NSTimeInterval) transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0;
}

- (void) animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.navController.view];
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

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [UIView animateWithDuration:duration animations:^{
        self.navigationItem.titleView.frame = self.navigationController.navigationBar.frame;
    }];
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

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType != UIWebViewNavigationTypeLinkClicked) {
        return YES;
    }
    JRFWebViewController *currentController = (JRFWebViewController *)self.navController.visibleViewController;
    if ([currentController.url isEqual:request.URL]) {
        return YES;
    }
    JRFWebViewController *webViewController = [[JRFWebViewController alloc] initWithUrl:request.URL delegate:self];
    [self.navController pushViewController:webViewController animated:NO];
    return NO;
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
    
    if (![toController isKindOfClass:[JRFWebViewController class]]) {
        return;
    }
    
    if ([fromController isKindOfClass:[JRFWebViewController class]]) {
        [fromController.webView stopLoading];
    }
    
    if (![toController.webView.request.URL isEqual:toController.url]) {
        toController.progressView.progress = 0.0f;
        toController.progressView.alpha = 1.0f;
        NSURLRequest *request = [NSURLRequest requestWithURL:toController.url];
        [toController.webView loadRequest:request];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
#warning TODO: drop the stack
    // Dispose of any resources that can be recreated.
}

@end
