//
//  cnblogsNewsAppDelegate.h
//  cnblogsNews
//
//  Created by Jiang Chuncheng on 9/28/11.
//  Copyright 2011 SenseForce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobClick.h"
#import "MTStatusBarOverlay.h"

@interface cnblogsNewsAppDelegate : NSObject <UIApplicationDelegate, MobClickDelegate, MTStatusBarOverlayDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
