//
//  ViewController.m
//  QRCode
//
//  Created by Young on 16/3/28.
//  Copyright © 2016年 Young. All rights reserved.
//

#import "ViewController.h"
#import "GYGQRCode.h"

@implementation ViewController

- (IBAction)QRCodeBtnClicked {
    
    GYGQRCode *codeVC = [[UIStoryboard storyboardWithName:@"GYGQRCode" bundle:nil] instantiateInitialViewController];
    codeVC.scanBlock = ^(NSString *tmp){
        
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:tmp preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertVc addAction:cancelAction];
        [self presentViewController:alertVc animated:YES completion:nil];
    };
    [self.navigationController pushViewController:codeVC  animated:YES];
}

@end
