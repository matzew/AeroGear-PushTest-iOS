/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AGAppDelegate.h"
#import "AeroGearPush.h"

@implementation AGAppDelegate {
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Let the device know we want to receive push notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"AeroGear Push Tutorial"
                          message: @"We hope you enjoy receving Push messages!"
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    
    
    return YES;
}

// Here we need to register this "Mobile Variant Instance"
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // currently, we need a little helper:
    NSString *pushToken = [self convertToNSString:deviceToken];
    
    // we init our "Registration helper:
    AGDeviceRegistration *registration =
    
        // WARNING: make sure, you start JBoss with the -b 0.0.0.0 option, to bind on all interfaces
        // from the iPhone, you can NOT use localhost :)
        [[AGDeviceRegistration alloc] initWithServerURL:[NSURL URLWithString:@"http://192.168.0.102:8080/ag-push/"]];
    
    [registration registerWithClientInfo:^(id<AGClientDeviceInformation> clientInfo) {
        
        // Use the Mobile Variant ID, from your register iOS Variant
        //
        // This ID was received when performing the HTTP-based registration
        // with the PushEE server:
        [clientInfo setMobileVariantID:@"402880e63ea239b9013ea23be9dc0004"];
        
        
        // apply the token, to identify THIS device
        [clientInfo setToken:pushToken];

        // set some more infos, that may be useful:
        [clientInfo setDeviceType:@"iPhone"];
        [clientInfo setOperatingSystem:@"iOS"];
        
        
    } success:^(id responseObject) {
        //
    } failure:^(NSError *error) {
        // did receive an HTTP error from the PushEE server ???
        // Let's log it for now:
        NSLog(@"PushEE registration Error: %@", error);
    }];
    
    
    
}

// There was an error with connecting to APNs or receiving an APNs generated token for this phone!
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
   
    // something went wrong, while talking to APNs
    // Let's simply log it for now...:
    NSLog(@"APNs Error: %@", error);
}

// When the program is active, this callback receives the Payload of the Push Notification message
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

    // A JSON object is received, represented as a NSDictionary.
    // use it to pick your custom key
    
    // Or, simply print it completely:
    NSLog(@"We Got: %@", userInfo);
}



// little helper to transform the NSData-based token into a (useful) String:
-(NSString *) convertToNSString:(NSData *) deviceToken {
    
    NSString *tokenStr = [deviceToken description];
    NSString *pushToken = [[[tokenStr
                            stringByReplacingOccurrencesOfString:@"<" withString:@""]
                            stringByReplacingOccurrencesOfString:@">" withString:@""]
                            stringByReplacingOccurrencesOfString:@" " withString:@""];
    return pushToken;
    
}


@end
