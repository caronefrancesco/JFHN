//
//  JRFInstapaperViewController.m
//  JFHN
//
//  Created by Jack Flintermann on 10/22/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFInstapaperViewController.h"

@interface JRFInstapaperViewController ()
@property(nonatomic) NSURLRequest *request;
@end

@implementation JRFInstapaperViewController

- (id) initWithUrlRequest:(NSURLRequest *)request {
    self = [super init];
    if (self) {

        NSString *urlEncodedLink = [self urlenc:[request.URL absoluteString]];
        NSString *instapaperBaseUrl = @"http://mobilizer.instapaper.com/m?u=";
        NSString *readabilityBaseUrl = @"http://www.readability.com/m?url=";
        NSString *urlString = [readabilityBaseUrl stringByAppendingString:urlEncodedLink];
        _request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString ]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:webView];
    [webView loadRequest:self.request];
}

- (BOOL) prefersStatusBarHidden {
    return YES;
}

-(NSString *)urlenc:(NSString *)val
{
    CFStringRef safeString =
    CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (CFStringRef)val,
                                            NULL,
                                            CFSTR("/%&=?$#+-~@<>|\\*,.()[]{}^!:"),
                                            kCFStringEncodingUTF8);
    return [NSString stringWithFormat:@"%@", safeString];
}


@end
