//
//  cnblogsNewsAppDelegate.m
//  cnblogsNews
//
//  Created by Jiang Chuncheng on 9/28/11.
//  Copyright 2011 SenseForce. All rights reserved.
//

#import "cnblogsNewsAppDelegate.h"
#import "Constants.h"

@implementation cnblogsNewsAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [MobClick setDelegate:self];
//    [MobClick setDelegate:self reportPolicy:REALTIME];
    [MobClick appLaunched];
    // Add the navigation controller's view to the window and display.
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    [MTStatusBarOverlay sharedInstance].animation = MTStatusBarOverlayAnimationFallDown;
    [MTStatusBarOverlay sharedInstance].historyEnabled = YES;
    [MTStatusBarOverlay sharedInstance].delegate = self;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [MobClick appTerminated];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    [MobClick appLaunched];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [MobClick appTerminated];
}

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [super dealloc];
}

#pragma mark -
#pragma mark Umeng MobClick

- (NSString *)appKey {
    return MobClickAppKey;
}

- (NSString *)channelId {
    
#define ChannelIdAppStore   @"App Store"
#define ChannelId91Store    @"91store"
#define ChannelIdTongbu     @"tongbu"
    
    return ChannelIdAppStore;
}

#pragma mark -
#pragma mark MTStatusBarOverlay Delegate Methods

- (void)statusBarOverlayDidHide {

}

- (void)statusBarOverlayDidSwitchFromOldMessage:(NSString *)oldMessage toNewMessage:(NSString *)newMessage {

}

- (void)statusBarOverlayDidClearMessageQueue:(NSArray *)messageQueue {

}

@end
