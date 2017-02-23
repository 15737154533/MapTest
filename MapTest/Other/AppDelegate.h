//
//  AppDelegate.h
//  MapApp
//
//  Created by mac on 2017/2/15.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDrawerController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,strong) MMDrawerController * drawerController;

@end

