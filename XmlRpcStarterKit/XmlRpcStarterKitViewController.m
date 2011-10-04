//
//  XmlRpcStarterKitViewController.m
//  XmlRpcStarterKit
//
//  Created by Stitz on 10/4/11.
//  Copyright 2011 Stitz. All rights reserved.
//

#import "XmlRpcStarterKitViewController.h"

#define kWordpressBaseURL @"https://www.company.com/xmlrpc.php"
#define kWordpressUserName @"email@company.com"
#define kWordpressPassword @"password"

@implementation XmlRpcStarterKitViewController

@synthesize lblResponse, descWebView;
@synthesize error;

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



#pragma XMLRPC Methods
//The Hello World of Wordpress XMLRPC web service calls.
- (IBAction)actionDemoHelloWorld:(id) sender {
	NSString *server = kWordpressBaseURL;
	XMLRPCRequest *reqFRC = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:server]];
	[reqFRC setMethod:@"demo.sayHello" withObjects:[NSArray arrayWithObjects:nil]];
	
	//The result for this method is a string so we know to send it into a NSString when making the call.
    NSString *result = [self executeXMLRPCRequest:reqFRC]; 
	
	[reqFRC release]; //Release the request
	
    //Basic error checking
	if( ![result isKindOfClass:[NSString class]] ) //error occured.
		lblResponse.text=@"error";
	
    NSLog(@"demo.sayHello Response: %@", result);
	lblResponse.text = result;
}

//XMLRPC call to see if the credentials work properly
//The Wordpress recomended way to check for a valid user is to call the wp.getUsersBlogs method 
//and see if 0 or greater is returned.
- (IBAction)actionAuthenticateUser:(id) sender {
    NSString *server = kWordpressBaseURL;
    
    //Call the authenticateUser method below which does the basic work.
    BOOL authResult = [self authenticateUser:server username:kWordpressUserName password:kWordpressPassword];
    
    if (authResult) {
        NSLog(@"Authenticated");
        lblResponse.text = @"Authenticated!";
        
    } else {
        NSLog(@"Bad login or password");
        lblResponse.text = @"Bad login or password";
    }
    
}

- (IBAction)actionGetBlogPost:(id) sender {
    //XMLRPC call to retreive a single post and push the content to a UIWebView
    NSString *server = kWordpressBaseURL;
    NSMutableDictionary *returnedPost = [self getPost:server username:kWordpressUserName password:kWordpressPassword];
    
    NSString *postDescription = [returnedPost objectForKey:@"description"];
    NSLog(@"Post Description: %@", postDescription);
    
    [descWebView loadHTMLString:postDescription baseURL:nil];
    descWebView.delegate = self;
}

//This method is used by our action above to call the getBlogsForUser to verify the user credentials
- (BOOL)authenticateUser:(NSString *)xmlrpc username:(NSString *)username password:(NSString *)password {
	BOOL result = NO;
	if((xmlrpc != nil) && (username != nil) && (password != nil)) {
		if([self getBlogsForUser:xmlrpc username:username password:password] != nil)
			result = YES;
	}
	return result;
}

- (NSMutableDictionary *)getPost:(NSString *)xmlrpcServer username:(NSString *)username password:(NSString *)password {
	
    NSMutableDictionary *finalData = [[NSMutableDictionary alloc] init];
    NSString *server = xmlrpcServer;
    
	@try {
        
        NSMutableArray *args = [NSArray arrayWithObjects:[NSNumber numberWithInt:2880], username, password, nil]; //2880 is a post ID in the system
        NSString *method = [[[NSString alloc] initWithString:@"metaWeblog.getPost"] autorelease]; // the method
        XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:server]];
        [request setMethod:method withObjects:args];
        
        NSMutableDictionary *returnedData = [self executeXMLRPCRequest:request];
        
        [request release];
        
		if([returnedData isKindOfClass:[NSArray class]]) {
            [finalData release];
            //finalData = [NSArray arrayWithArray:returnedData];
		}
        else if([returnedData isKindOfClass:[NSDictionary class]]) {
            [finalData release];
            finalData = returnedData;
		}
		else if([returnedData isKindOfClass:[NSError class]]) {
			self.error = (NSError *)returnedData;
			NSString *errorMessage = [self.error localizedDescription];
			
			finalData = nil;
			
			if([errorMessage isEqualToString:@"The operation couldn’t be completed. (NSXMLParserErrorDomain error 4.)"])
				errorMessage = @"Your blog's XML-RPC endpoint was found but it isn't communicating properly. Try disabling plugins or contacting your host.";
			else if([errorMessage isEqualToString:@"Bad login/pass combination."])
                errorMessage = nil;			
		}
		else {
			finalData = nil;
			NSLog(@"method failed: %@", returnedData);
		}
	}
	@catch (NSException * e) {
		finalData = nil;
		NSLog(@"method failed: %@", e);
	}
	
	return finalData;
}

- (NSMutableArray *)getBlogsForUser:(NSString *)xmlrpc username:(NSString *)username password:(NSString *)password {
	
    NSMutableArray *usersBlogs = [[NSMutableArray alloc] init];
    
	@try {
		XMLRPCRequest *xmlrpcUsersBlogs = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:xmlrpc]];
		[xmlrpcUsersBlogs setMethod:@"wp.getUsersBlogs" withObjects:[NSArray arrayWithObjects:username, password, nil]];
        
		NSArray *usersBlogsData = [self executeXMLRPCRequest:xmlrpcUsersBlogs];
        [xmlrpcUsersBlogs release];
		
		if([usersBlogsData isKindOfClass:[NSArray class]]) {
            [usersBlogs release];
            usersBlogs = [NSArray arrayWithArray:usersBlogsData];
		}
		else if([usersBlogsData isKindOfClass:[NSError class]]) {
			self.error = (NSError *)usersBlogsData;
			NSString *errorMessage = [self.error localizedDescription];
			
			usersBlogs = nil;
			
			if([errorMessage isEqualToString:@"The operation couldn’t be completed. (NSXMLParserErrorDomain error 4.)"])
				errorMessage = @"Your blog's XML-RPC endpoint was found but it isn't communicating properly. Try disabling plugins or contacting your host.";
            
		}
		else {
			usersBlogs = nil;
			NSLog(@"getBlogsForUrl failed: %@", usersBlogsData);
		}
	}
	@catch (NSException * e) {
		usersBlogs = nil;
		NSLog(@"getBlogsForUrl failed: %@", e);
	}
	
	return usersBlogs;
}

- (id)executeXMLRPCRequest:(XMLRPCRequest *)req {
	XMLRPCResponse *userInfoResponse = [XMLRPCConnection sendSynchronousXMLRPCRequest:req];
	return [userInfoResponse object];
}




#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    descWebView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
