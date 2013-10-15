//
//  JRFBrowserController.m
//  JFHN
//
//  Created by Jack Flintermann on 10/13/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFBrowserController.h"
#import <BDDRScrollViewAdditions/UIScrollView+BDDRScrollViewAdditions.h>

@interface JRFBrowserController ()
@property(nonatomic, weak) UINavigationController *navController;
@end

@interface JRFWebViewController : UIViewController
@property(nonatomic, readonly) NSURL *url;
@property(nonatomic, readonly) UIWebView *webView;
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
        webView.scrollView.bddr_oneFingerZoomEnabled = YES;
        webView.backgroundColor = [UIColor whiteColor];
        _webView = webView;
        
        _url = url;
    }
    return self;
}

- (void) viewDidLoad {
    self.view = self.webView;
}

@end

@implementation JRFBrowserController

- (id) initWithUrl:(NSURL *)url {
    if (self = [super init]) {
        JRFWebViewController *webViewController = [[JRFWebViewController alloc] initWithUrl:url delegate:self];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:webViewController];
        navController.delegate = self;
        navController.toolbarHidden = NO;
        [self addChildViewController:navController];
        _navController = navController;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.navController.view];
    UIScreenEdgePanGestureRecognizer *screenEdgeGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedFromRight:)];
    screenEdgeGestureRecognizer.edges = UIRectEdgeRight;
    [self.navController.view addGestureRecognizer:screenEdgeGestureRecognizer];
}

- (void) pannedFromRight:(UIScreenEdgePanGestureRecognizer *)sender {
    
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

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    for (UIView *view in webView.scrollView.subviews) {
        if ([view isKindOfClass:[UIRefreshControl class]]) {
            [((UIRefreshControl *)view) endRefreshing];
        }
    }
}

- (UIToolbar *) toolbar {
    return self.navController.toolbar;
}

- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView
                      withVelocity:(CGPoint)velocity
               targetContentOffset:(inout CGPoint *)targetContentOffset {
    // we're rubberbanding from the top
    if (scrollView.contentOffset.y < (-1*scrollView.contentInset.top)) {
        return;
    }
    // we are going up
    if (velocity.y < -1) {
        [self showToolbar];
    }
    else {
        [self hideToolbar];
    }
}

- (void) hideToolbar {
    [self.navController setToolbarHidden:YES animated:YES];
}

- (void) showToolbar {
    [self.navController setToolbarHidden:NO animated:YES];
}

- (void) navigationController:(UINavigationController *)navigationController
       willShowViewController:(JRFWebViewController *)viewController animated:(BOOL)animated {
    if (![viewController.webView.request.URL isEqual:viewController.url]) {
        [viewController.webView loadRequest:[NSURLRequest requestWithURL:viewController.url]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
