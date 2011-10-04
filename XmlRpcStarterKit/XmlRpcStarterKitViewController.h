//
//  XmlRpcStarterKitViewController.h
//  XmlRpcStarterKit
//
//  Created by Stitz on 10/4/11.
//  Copyright 2011 Stitz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMLRPCResponse.h"
#import "XMLRPCRequest.h"
#import "XMLRPCConnection.h"

@interface XmlRpcStarterKitViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UILabel *lblResponse;
    UIWebView *descWebView;
}

@property (nonatomic,retain) IBOutlet UILabel *lblResponse;
@property (nonatomic,retain) IBOutlet UIWebView *descWebView;
@property (nonatomic,retain) NSError *error;

- (IBAction)actionDemoHelloWorld:(id) sender;
- (IBAction)actionAuthenticateUser:(id) sender;
- (IBAction)actionGetBlogPost:(id) sender;

- (BOOL)authenticateUser:(NSString *)xmlrpc username:(NSString *)username password:(NSString *)password;
- (NSMutableDictionary *)getPost:(NSString *)xmlrpc username:(NSString *)username password:(NSString *)password;
- (NSMutableArray *)getBlogsForUser:(NSString *)xmlrpc username:(NSString *)username password:(NSString *)password;


- (id)executeXMLRPCRequest:(XMLRPCRequest *)req;


@end

