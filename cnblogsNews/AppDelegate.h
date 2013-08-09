//
//  AppDelegate.h
//  cnblogsNews
//
//  Created by Jiang Chuncheng on 8/10/13.
//  Copyright (c) 2013 SenseForce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobClick.h"
#import "MTStatusBarOverlay.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, MobClickDelegate, MTStatusBarOverlayDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
