//
//  XmlRpcStarterKitAppDelegate.h
//  XmlRpcStarterKit
//
//  Created by Stitz on 10/4/11.
//  Copyright 2015 Stitz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XmlRpcStarterKitViewController;

@interface XmlRpcStarterKitAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet XmlRpcStarterKitViewController *viewController;

@end
