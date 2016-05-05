//
//  SweepQRcodeVC.h
//  hartPay-iOS
//
//  Created by 周伟 on 15/9/17.
//  Copyright (c) 2015年 &#21608;&#20255;. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface SweepQRcodeVC : UIViewController<AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic)  UIView *viewPreview;
@property (strong, nonatomic)  UILabel *lblStatus;
@property (strong, nonatomic)  UIButton *startBtn;
- (void)startStopReading:(id)sender;

@property (nonatomic,strong) UILabel *qRcodeLab;
@property (copy) NSString *str;
@property (strong, nonatomic) UIView *boxView;
@property (nonatomic) BOOL isReading;
@property (strong, nonatomic) CALayer *scanLayer;
-(BOOL)startReading;
-(void)stopReading;

//捕捉会话
@property (nonatomic, strong) AVCaptureSession *captureSession;
//展示layer
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;


@end
