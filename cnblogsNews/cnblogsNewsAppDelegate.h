//
//  cnblogsNewsAppDelegate.h
//  cnblogsNews
//
//  Created by Jiang Chuncheng on 9/28/11.
//  Copyright 2011 SenseForce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobClick.h"

@interface cnblogsNewsAppDelegate : NSObject <UIApplicationDelegate, MobClickDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
