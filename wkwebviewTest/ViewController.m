//
//  ViewController.m
//  wkwebviewTest
//
//  Created by 陈庆 on 2020/7/1.
//  Copyright © 2020 陈庆. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
@interface ViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
@property (nonatomic,retain) WKWebView * wkwebview;
@property (nonatomic,retain) WKWebViewConfiguration *configuration;
@property (nonatomic,retain) WKPreferences * preference;
@property (nonatomic,retain) UIButton * button;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self initUI];
}
- (void)initUI{
    [self.view addSubview:self.wkwebview];
    [self.view addSubview:self.button];
//    加载本地HTML文件
    NSString * path = [NSBundle.mainBundle pathForResource:@"wkwebviewhtml" ofType:@"html"];
    [_wkwebview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
//    监听脚本接口名
    WKUserContentController *userCC = _configuration.userContentController;
    //MARK:在OC中添加监听的接口清单：JS脚本的接口名
    [userCC addScriptMessageHandler:self name:@"getMessage"];
    
    //为WKWebViewController设置偏好设置
    _preference = [[WKPreferences alloc]init];
    _configuration.preferences = _preference;
    
    //允许native与js交互
    _preference.javaScriptEnabled = true;
}
- (WKWebView *)wkwebview{
    if (_wkwebview==nil) {
        _configuration = [[WKWebViewConfiguration alloc]init];
        
        _wkwebview = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300) configuration:_configuration];
        _wkwebview.backgroundColor = [UIColor redColor];
        _wkwebview.navigationDelegate = self;
        _wkwebview.UIDelegate = self;
    }
    return _wkwebview;
}
- (UIButton *)button{
    if (_button == nil) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = CGRectMake(100, 350, 100, 60);
        [_button setTitle:@"oc调用js" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}
- (void)btnClick{
    NSString * js = @"document.getElementsByTagName('h2')[0].innerText = '这是一个iOS写入的方法'";
    [_wkwebview evaluateJavaScript:js completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        NSLog(@"------->%@",data);
    }];
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
}
//网页加载完成
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    //设置JS
    NSString *js = @"document.getElementsByTagName('h1')[0].innerText";
    //执行JS
    [webView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        NSLog(@"value: %@ error: %@", response, error);
        
    }];
}

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    NSLog(@"message--->%@,%@",message.name,message.body);
    UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:@"提示" message:message.body preferredStyle:UIAlertControllerStyleAlert];
        [alertcontroller addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:alertcontroller animated:true completion:^{
            
        }];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:@"提示" message:prompt preferredStyle:UIAlertControllerStyleAlert];
        [alertcontroller addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //        需要执行completionHandler，这样js才能继续执行 ,不然程序会崩溃,回传给js的数据
            completionHandler([alertcontroller textFields][0].text);
        }]];
        [alertcontroller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
        }];
        [self presentViewController:alertcontroller animated:true completion:^{
            
        }];
}
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog(@"--->%@",message);
    UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertcontroller addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        需要执行completionHandler，这样js才能继续执行 ,不然程序会崩溃
        completionHandler();
    }]];
    [self presentViewController:alertcontroller animated:true completion:^{
        
    }];
    
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    
    UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertcontroller addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //        需要执行completionHandler，这样js才能继续执行 ,不然程序会崩溃
            completionHandler(YES);
        }]];
        [alertcontroller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //        需要执行completionHandler，这样js才能继续执行 ,不然程序会崩溃
                completionHandler(NO);
            }]];
        [self presentViewController:alertcontroller animated:true completion:^{
            
        }];
}
- (void)showMsg:(NSString *)msg {
    
}

@end
