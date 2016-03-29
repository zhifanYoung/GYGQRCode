//
//  GYGQRCode.h
//  QRCode
//
//  Created by Young on 16/3/28.
//  Copyright © 2016年 Young. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GYGQRCode : UIViewController

@property (nonatomic, copy) void (^scanBlock)(NSString *);

@end
