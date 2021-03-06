//
//  ViewController.m
//  Test1
//
//  Created by bigyelow on 02/06/2017.
//  Copyright © 2017 huangduyu. All rights reserved.
//

@import WebKit;

#import "ViewController.h"
#import "SubTestExtension.h"
#import "PresentingViewController.h"
#import "TCommond.h"
#import "Test1-Swift.h"
#import "TestBlockObject.h"

static NSString * const WKWebViewStr = @"WKWebView";
static NSString * const ImageStr = @"Image";
static NSString * const VideoStr = @"Video";
static NSString * const NSURLSessionStr = @"NSURLSession";
static NSString * const URLEncodingStr = @"NSURLEncoding";
static NSString * const PresentingStr = @"Presenting";
static NSString * const Nullability = @"Nullability";
static NSString * const OpenURL = @"OpenURL";
static NSString * const Block = @"Block";
static NSInteger OpenURLCount = 0;

@interface ViewController () <NSURLSessionDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray *demos;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, assign) BOOL tag;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) NSInteger resignCount;
@property (nonatomic, assign) NSInteger becomeActiveCount;
@property (nonatomic, assign) NSInteger enterBackgroundCount;
@property (nonatomic, assign) NSInteger enterForegroundCount;
@property (nonatomic, strong) TestBlockObject *blockObject;

@end

@implementation ViewController

- (instancetype)init
{
  if (self = [super init]) {
    _demos = @[WKWebViewStr, ImageStr, VideoStr, NSURLSessionStr, URLEncodingStr, PresentingStr, Nullability, OpenURL, Block];
    _becomeActiveCount = -1;
    _blockObject = [TestBlockObject new];
    _blockObject.block = ^{
      NSMutableArray *array = [@[@"1", @"2"] mutableCopy];
      [array addObject:@"3"];
      [array addObject:@"4"];

      NSLog(@"Begin\n");

      for (NSString *obj in array) {
        NSLog(@"%@", obj);
      }
    };
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.title = @"Home";

  // TableView
  _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
  [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
  _tableView.delegate = self;
  _tableView.dataSource = self;
  [self.view addSubview:_tableView];

  // WebView
  _webView = [[WKWebView alloc] initWithFrame:CGRectZero];
  _webView.hidden = YES;
  [self.view addSubview:_webView];

  // Navigation bar
  UIBarButtonItem *switchItem = [[UIBarButtonItem alloc] initWithTitle:@"Switch"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(_te_hiddenWebView)];
  UIBarButtonItem *startLoadItem = [[UIBarButtonItem alloc] initWithTitle:@"Start"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(_te_startToLoad)];
  self.navigationItem.rightBarButtonItems = @[startLoadItem, switchItem];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_te_UIApplicationWillResignActiveNotification)
                                               name:UIApplicationWillResignActiveNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_te_UIApplicationDidBecomeActiveNotification)
                                               name:UIApplicationDidBecomeActiveNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_te_UIApplicationDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_te_UIApplicationWillEnterForegroundNotification)
                                               name:UIApplicationWillEnterForegroundNotification
                                             object:nil];
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
  _tableView.frame = self.view.bounds;
  _webView.frame = self.view.bounds;
}

#pragma mark - TableView delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _demos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])
                                                          forIndexPath:indexPath];
  cell.textLabel.text = _demos[indexPath.row];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:NO];

  if ([_demos[indexPath.row] isEqualToString:WKWebViewStr]) {
    [self _te_startToLoad];
  }
  else if ([_demos[indexPath.row] isEqualToString:ImageStr]) {
    [self.navigationController pushViewController:[ImageProcessorViewController new] animated:YES];
  }
  else if ([_demos[indexPath.row] isEqualToString:VideoStr]) {

  }
  else if ([_demos[indexPath.row] isEqualToString:NSURLSessionStr]) {
    [self _te_testHTTP2];
  }
  else if ([_demos[indexPath.row] isEqualToString:URLEncodingStr]) {
    [self _te_testURLEncoding];
  }
  else if ([_demos[indexPath.row] isEqualToString:PresentingStr]) {
    [self _te_presentVC];
  }
  else if ([_demos[indexPath.row] isEqualToString:Nullability]) {
    TCommond *commond = [[TCommond alloc] initWithID:@"123" name:nil];
    TestNullabilityViewController *ctr = [[TestNullabilityViewController alloc] initWithCommond:commond];
    [self.navigationController pushViewController:ctr animated:YES];
  }
  else if ([_demos[indexPath.row] isEqualToString:OpenURL]) {
    NSURL *url = OpenURLCount++ % 2 == 0 ? [NSURL URLWithString:@"weixin://douban.com/music/11"] : [NSURL URLWithString:@"douban://douban.com/music/11"];
    [UIApplication.sharedApplication openURL:url
                                     options:@{}
                           completionHandler:^(BOOL success) {
                             NSLog(success ? @"success" : @"failure");
                           }];
  }
  else if ([_demos[indexPath.row] isEqualToString:Block]) {
    [_blockObject doBlock];
  }
}

#pragma mark - Test

- (void)_te_startToLoad
{
  NSURLRequest *request;
  if (_tag) {
    NSURL *url = [NSURL URLWithString:@"https://erebor.douban.com/redirect/?ad=185609&uid=&bid=c13147858ac7e0c759bc194402c04bfaea7d2193&unit=dale_feed_today_fifth&crtr=&mark=&hn=dis4&sig=690a8833c1fc9b1a9cc91af982bce043b469fe6fa236c49bb88811f81ec3a9895c7421eec35ee5e645976080dabc83eb5e525bafcd013e33b498d1bc2e1332d7&pid=debug_bcc04c2100b7567cbfaf86c98443252a4db7751d&target=https%3A%2F%2Fclick.gridsumdissector.com%2Ftrack.ashx%3Fgsadid%3Dgad_158_vbn837cv"];
    request = [NSURLRequest requestWithURL:url];

    self.tag = NO;
  }
  else {
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];

    self.tag = YES;
  }

  [_webView loadRequest:request];
}

- (void)_te_presentVC
{
  [self presentViewController:[[UINavigationController alloc] initWithRootViewController:[PresentingViewController new]]
                     animated:YES
                   completion:nil];
}

- (void)_te_testURLEncoding
{
  TestSwift *ts = [TestSwift new];
  [ts test];
}

- (void)_te_testHTTP2
{
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  configuration.HTTPAdditionalHeaders = @{@"User-Agent": @"api-client/0.1.3 com.douban.frodo/4.9.0 iOS/10.2 x86_64"};
  NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];

  NSString *string1 = @"https://211.147.4.40/api/v2/group/yinxiangbiji?apikey=0dad551ec0f84ed02907ff5c42e8ec70&alt=json&douban_udid=e42a26fba5a1b560a4e6a465bb033e7ea402e4ff&event_loc_id=108288&latitude=0&loc_id=108288&longitude=0&udid=77cbb9dd272e97162d19281f92978a0049768e11&version=4.9.0";
  NSString *string2 = @"https://frodo.douban.com/api/v2/movie/26873826?alt=json&apikey=0b8257e8bcbc63f4228707ba36352bdc&douban_udid=e42a26fba5a1b560a4e6a465bb033e7ea402e4ff&event_loc_id=108288&latitude=0&loc_id=108288&longitude=0&udid=77cbb9dd272e97162d19281f92978a0049768e11&version=4.9.0";
  NSURL *url = [NSURL URLWithString:string1];
  NSURLSessionDataTask *task = [session dataTaskWithURL:url
                                      completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                        if (error) {
                                          NSLog(@"error");
                                        }
                                        else {
                                          NSLog(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                        }
                                      }];
  [task resume];
}

- (void)_te_hiddenWebView
{
  _webView.hidden = !_webView.hidden;
}

#pragma mark - Notifications
- (void)_te_UIApplicationWillResignActiveNotification
{
  NSLog(@"resign active: %@", @(++_resignCount));
  NSLog(@"UIApplicationWillResignActiveNotification");
}

- (void)_te_UIApplicationDidEnterBackgroundNotification
{
  NSLog(@"enter background: %@", @(++_enterBackgroundCount));
  NSLog(@"UIApplicationDidEnterBackgroundNotification");
}

- (void)_te_UIApplicationWillEnterForegroundNotification
{
  NSLog(@"enter foreground: %@", @(++_enterForegroundCount));
  NSLog(@"UIApplicationWillEnterForegroundNotification");
}

- (void)_te_UIApplicationDidBecomeActiveNotification
{
  NSLog(@"become active: %@", @(++_becomeActiveCount));
  NSLog(@"UIApplicationDidBecomeActiveNotification");
}

#pragma mark - URLSession delegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
  completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}

@end
