//
//  main.m
//  DynamicScrollDirection
//
//  Created by Ford Parsons on 10/23/17.
//  Copyright © 2017 Ford Parsons. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDLib.h>

// Undocumented CoreGraphics methods, from <https://github.com/dustinrue/ControlPlane/issues/150#issuecomment-5721542>
extern int _CGSDefaultConnection(void);
extern void CGSSetSwipeScrollDirection(int cid, BOOL dir);

void SetNaturalScroll(BOOL naturalScroll) {
    // Actually change the scroll direction, using `CGSSetSwipeScrollDirection`, an undocumented CoreGraphics method.
    CGSSetSwipeScrollDirection(_CGSDefaultConnection(), naturalScroll);

    // Update the ~/Library/Preferences/.GlobalPreferences.plist file. Equivalent to `defaults write NSGlobalDomain com.apple.swipescrolldirection -bool YES`.
    CFPreferencesSetAppValue(CFSTR("com.apple.swipescrolldirection"), (CFBooleanRef)@(naturalScroll), kCFPreferencesAnyApplication);
    CFPreferencesAppSynchronize(kCFPreferencesAnyApplication);

    // Send `SwipeScrollDirectionDidChangeNotification` notification so System Preferences can update its UI.
    [NSDistributedNotificationCenter.defaultCenter postNotificationName:@"SwipeScrollDirectionDidChangeNotification" object:nil];
}

IOHIDManagerRef hidManager;

void DeviceMatchingCallback(void *context, IOReturn result, void *sender, IOHIDDeviceRef device) {
    NSLog(@"Attached %@", IOHIDDeviceGetProperty(device, CFSTR(kIOHIDProductKey)));
    SetNaturalScroll(NO);
}

void DeviceRemovalCallback(void *context, IOReturn result, void *sender, IOHIDDeviceRef device) {
    NSLog(@"Removed %@", IOHIDDeviceGetProperty(device, CFSTR(kIOHIDProductKey)));
    CFSetRef devices = IOHIDManagerCopyDevices(hidManager);
    Boolean deviceInList = CFSetContainsValue(devices, device);
    CFIndex deviceCount = CFSetGetCount(devices);
    CFIndex remainingDeviceCount = deviceCount - ((int)deviceInList);
    CFRelease(devices);
    SetNaturalScroll(remainingDeviceCount <= 0);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        hidManager = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDManagerOptionNone);
        IOHIDManagerSetDeviceMatching(hidManager, (CFDictionaryRef)@{@(kIOProviderClassKey):@(kIOHIDDeviceKey),
                                                    @(kIOHIDTransportKey):@(kIOHIDTransportUSBValue),
                                                    @(kIOHIDDeviceUsagePageKey):@(kHIDPage_GenericDesktop),
                                                    @(kIOHIDDeviceUsageKey):@(kHIDUsage_GD_Mouse)});
        IOHIDManagerRegisterDeviceMatchingCallback(hidManager, DeviceMatchingCallback, nil);
        IOHIDManagerRegisterDeviceRemovalCallback(hidManager, DeviceRemovalCallback, nil);
        IOHIDManagerScheduleWithRunLoop(hidManager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        [NSRunLoop.currentRunLoop runUntilDate:NSDate.distantFuture];
    }
    return 0;
}
