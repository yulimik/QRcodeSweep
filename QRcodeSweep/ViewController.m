//
//  ViewController.m
//  QRcodeSweep
//
//  Created by 周伟 on 16/5/5.
//  Copyright © 2016年 yulimik. All rights reserved.
//

#import "ViewController.h"
#import "SweepQRcodeVC.h"
#import <Masonry.h>
@interface ViewController ()

@property (nonatomic,strong) UILabel *bottomLab;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
    [btn setBackgroundColor:[UIColor grayColor]];
    [btn setTitle:@"开始扫描" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(enterToSweepQRcode) forControlEvents:UIControlEventTouchUpInside];
    
    self.bottomLab = [[UILabel alloc]init];
    [self.view addSubview:self.bottomLab];
    [self.bottomLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(btn.mas_bottom).with.offset(50);
    }];
    
}

- (void)enterToSweepQRcode {
    [self.navigationController pushViewController:[[SweepQRcodeVC alloc]init] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    AppDelegate *myDelegate = [[UIApplication sharedApplication]delegate];
    if (nil != myDelegate.codeStr) {
        self.bottomLab.text = myDelegate.codeStr;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
