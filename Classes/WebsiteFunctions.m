/*
 *  This file is part of the TVShows 2 ("Phoenix") source code.
 *  http://github.com/victorpimentel/TVShows/
 *
 *  TVShows is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with TVShows. If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import "WebsiteFunctions.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import "RegexKitLite.h"

@implementation WebsiteFunctions

+ (BOOL) canConnectToHostname:(NSString *)hostName
{
    SCNetworkReachabilityRef target;
    SCNetworkConnectionFlags flags = 0;
    BOOL ok = NO;
    target = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    if (target != nil) {
        ok = SCNetworkReachabilityGetFlags(target, &flags);
        CFRelease(target);
    }
    return ok;
}

+ (BOOL) canConnectToURL:(NSString *)url
{
    NSURL *realURL = [NSURL URLWithString:url];
    
    if (realURL == nil || [realURL host] == nil || [url length] < 5) {
        return FALSE;
    } else {
        return [WebsiteFunctions canConnectToHostname:[realURL host]];
    }
}

+ (NSData *) downloadDataFrom:(NSString *)url
{
    // Check before if it can connect to that hostname
    if (![WebsiteFunctions canConnectToURL:url]) {
        return [NSData data];
    }
    
    // Set a restrictive timeout
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:5.0];
    
    // Get the data
    return [NSURLConnection sendSynchronousRequest:request
                                 returningResponse:nil
                                             error:nil];
}

+ (NSString *) downloadStringFrom:(NSString *)url
{
    // Get the data
    NSString *content = [[[NSString alloc] initWithData:[WebsiteFunctions downloadDataFrom:url]
                                               encoding:NSUTF8StringEncoding] autorelease];
    
    return content;
}

+ (BOOL) dataIsValidTorrent:(NSData *) data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    if ([[string substringToIndex:11] isEqualToString:@"d8:announce"]) {
        [string release];
        return YES;
    } else {
        [string release];
        return NO;
    }
}

@end
