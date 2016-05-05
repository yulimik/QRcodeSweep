//
//  SweepQRcodeVC.m
//  hartPay-iOS
//
//  Created by 周伟 on 15/9/17.
//  Copyright (c) 2015年 &#21608;&#20255;. All rights reserved.
//

#import "SweepQRcodeVC.h"
#import "AppDelegate.h"
#import <Masonry.h>
@implementation SweepQRcodeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"backNavItem.png" ]  style:UIBarButtonItemStyleDone target:self action:@selector(backPop)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    CGSize size = self.view.bounds.size;
    
    self.viewPreview = [[UIView alloc]initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, size.height)];
    [self.view addSubview:self.viewPreview];
    //    [self.viewPreview mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(self.view.mas_centerX);
    //        make.bottom.equalTo(self.view.mas_bottom);
    //        make.size.mas_equalTo(CGSizeMake(size.width, size.height*.9));
    //    }];
    self.viewPreview.backgroundColor = [UIColor whiteColor];
    
    self.lblStatus = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 200, 20)];
    [self.view addSubview:self.lblStatus];
    self.lblStatus.hidden = YES;
    [self.lblStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.viewPreview.mas_top);
    }];
    //    [self.lblStatus setText:@"准备"];
    [self.lblStatus setTextAlignment:NSTextAlignmentCenter];
    
    self.startBtn = [[UIButton alloc]initWithFrame:CGRectMake(160, 200, 50, 50)];
    //    [self.startBtn setTitle:@"扫描" forState:UIControlStateNormal];
    [self.view addSubview:self.startBtn];
    self.startBtn.hidden = YES;
    [self.startBtn addTarget:self action:@selector(startStopReading:) forControlEvents:UIControlEventTouchUpInside];
    
    [self startStopReading:self.startBtn];
    
    _captureSession = nil;
    _isReading = NO;

}

- (BOOL)startReading {
    NSError *error;
    
    //1.初始化捕捉设备（AVCaptureDevice），类型为AVMediaTypeVideo
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //2.用captureDevice创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    //3.创建媒体数据输出流
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    //4.实例化捕捉会话
    _captureSession = [[AVCaptureSession alloc] init];
    
    //4.1.将输入流添加到会话
    [_captureSession addInput:input];
    
    //4.2.将媒体输出流添加到会话中
    [_captureSession addOutput:captureMetadataOutput];
    
    //5.创建串行队列，并加媒体输出流添加到队列当中
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    //5.1.设置代理
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    
    //5.2.设置输出媒体数据类型为QRCode
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    //6.实例化预览图层
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    
    
    //7.设置预览图层填充方式
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //8.设置图层的frame
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    
    //9.将图层添加到预览view的图层上
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
    //10.设置扫描范围
    captureMetadataOutput.rectOfInterest = CGRectMake(0.2f, 0.2f, 0.8f, 0.8f);
    
    //10.1.扫描框
    _boxView = [[UIView alloc] initWithFrame:CGRectMake(_viewPreview.bounds.size.width * 0.2f, _viewPreview.bounds.size.height * 0.2f, _viewPreview.bounds.size.width - _viewPreview.bounds.size.width * 0.4f, _viewPreview.bounds.size.width - _viewPreview.bounds.size.width * 0.4f)];
    _boxView.layer.borderColor = [UIColor whiteColor].CGColor;
    _boxView.layer.borderWidth = 0.5f;
    
    [_viewPreview addSubview:_boxView];
    
    self.qRcodeLab = [UILabel new];
    [_viewPreview addSubview:self.qRcodeLab];
    self.qRcodeLab.frame = CGRectMake(0, _viewPreview.bounds.size.height * .2f + _viewPreview.bounds.size.width - _viewPreview.bounds.size.width * 0.4f, _viewPreview.bounds.size.width, 20);
    //    [self.qRcodeLab mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(_viewPreview.mas_centerX);
    //        make.top.equalTo(_viewPreview.mas_bottom).with.offset(10);
    //    }];
    [self.qRcodeLab setText:@"将二维码放入框内,即可自动扫描"];
    [self.qRcodeLab setFont:[UIFont systemFontOfSize:13]];
    [self.qRcodeLab setTextAlignment:NSTextAlignmentCenter];
    [self.qRcodeLab setTextColor:[UIColor colorWithRed:0.73 green:0.7 blue:0.69 alpha:1]];
    
    
    //10.2.扫描线
    _scanLayer = [[CALayer alloc] init];
    _scanLayer.frame = CGRectMake(0, 0, _boxView.bounds.size.width, 1);
    _scanLayer.backgroundColor = [UIColor brownColor].CGColor;
    
    [_boxView.layer addSublayer:_scanLayer];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(moveScanLayer:) userInfo:nil repeats:YES];
    [timer fire];
    //10.开始扫描
    [_captureSession startRunning];
    return YES;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //判断是否有数据
    
    //判断回传的数据类型
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSLog(@"执行一次");
            self.str = [metadataObj stringValue];
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            _isReading = NO;
            
            [self performSelectorOnMainThread:@selector(backPopGetQRcode) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)moveScanLayer:(NSTimer *)timer
{
    CGRect frame = _scanLayer.frame;
    if (_boxView.frame.size.height < _scanLayer.frame.origin.y) {
        frame.origin.y = 0;
        _scanLayer.frame = frame;
    }else{
        
        frame.origin.y += 5;
        
        [UIView animateWithDuration:0.0001 animations:^{
            _scanLayer.frame = frame;
        }];
    }
}

- (void)startStopReading:(id)sender {
    if (!_isReading) {
        if ([self startReading]) {
            [_startBtn setTitle:@"停止" forState:UIControlStateNormal];
            [_lblStatus setText:@"正在扫描"];
        }
    }
    else{
        [self stopReading];
        [_startBtn setTitle:@"Start!" forState:UIControlStateNormal];
    }
    
    _isReading = !_isReading;
}

-(void)stopReading{
    [_captureSession stopRunning];
    _captureSession = nil;
    [_scanLayer removeFromSuperlayer];
    [_videoPreviewLayer removeFromSuperlayer];
}

- (void)backPopGetQRcode
{
    NSLog(@"扫到了,内容是%@",self.str);
    
    AppDelegate *myDelegate = [[UIApplication sharedApplication]delegate];
    myDelegate.codeStr = self.str;
//    if (self.str.length >= 73) {
//        NSInteger length = self.str.length;
//        NSLog(@"length is %d",length);
//        self.str = [self.str substringWithRange:NSMakeRange(62, 6)];
//        NSLog(@"str is %@",self.str);
//        myDelegate.codeStr = self.str;
//        myDelegate.isReceived = YES;
//    }else
//    {
//        myDelegate.isError = YES;
//    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backPop
{
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
