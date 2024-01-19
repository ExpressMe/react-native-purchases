
//
//  Created by RevenueCat.
//  Copyright © 2023 RevenueCat. All rights reserved.
//

#import "RNPaywalls.h"

@interface RNPaywalls ()

@property (nonatomic, strong) id paywallProxy;

@end

@implementation RNPaywalls

RCT_EXPORT_MODULE();

- (instancetype)initWithDisabledObservation
{
    if ((self = [super initWithDisabledObservation])) {
        [self initializePaywalls];
    }

    return self;
}

- (instancetype)init
{
    if (([super init])) {
        [self initializePaywalls];
    }
    return self;
}

// `RCTEventEmitter` does not implement designated iniitializers correctly so we have to duplicate the call in both constructors.
- (void)initializePaywalls {
    if (@available(iOS 15.0, *)) {
        self.paywallProxy = [PaywallProxy new];
    } else {
        self.paywallProxy = nil;
    }
}

// MARK: -

- (NSArray<NSString *> *)supportedEvents {
    return @[safeAreaInsetsDidChangeEvent];
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (PaywallProxy *)paywalls API_AVAILABLE(ios(15.0)){
    return self.paywallProxy;
}

// MARK: -

RCT_EXPORT_METHOD(presentPaywall:(NSDictionary *)options
                  withResolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    if (@available(iOS 15.0, *)) {
        // TODO wire offeringIdentifier
        NSString *offeringIdentifier = options[@"offeringIdentifier"];
        NSNumber *displayCloseButton = options[@"displayCloseButton"];

        if (displayCloseButton == nil) {
            [self.paywallProxy presentPaywallWithPaywallResultHandler:^(NSString *result) {
                resolve(result);
            }];
            return;
        }
        [self.paywalls presentPaywallWithDisplayCloseButton:displayCloseButton.boolValue
                                       paywallResultHandler:^(NSString *result) {
            resolve(result);
        }];
    } else {
        [self rejectPaywallsUnsupportedError:reject];
    }
}

RCT_EXPORT_METHOD(presentPaywallIfNeeded:(NSDictionary *)options
                  withResolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    if (@available(iOS 15.0, *)) {
        NSString *requiredEntitlementIdentifier = options[@"requiredEntitlementIdentifier"];
        // TODO wire offeringIdentifier
        NSString *offeringIdentifier = options[@"offeringIdentifier"];
        NSNumber *displayCloseButton = options[@"displayCloseButton"];
        if (displayCloseButton == nil) {
            [self.paywalls presentPaywallIfNeededWithRequiredEntitlementIdentifier:requiredEntitlementIdentifier
                                                              paywallResultHandler:^(NSString *result) {
                resolve(result);
            }];
            return;
        }

        [self.paywalls presentPaywallIfNeededWithRequiredEntitlementIdentifier:requiredEntitlementIdentifier
                                                            displayCloseButton:displayCloseButton.boolValue
                                                          paywallResultHandler:^(NSString *result) {
            resolve(result);
        }];
    } else {
        [self rejectPaywallsUnsupportedError:reject];
    }
}

- (void)rejectPaywallsUnsupportedError:(RCTPromiseRejectBlock)reject {
    NSLog(@"Error: attempted to present paywalls on unsupported iOS version.");
    reject(@"PaywallsUnsupportedCode", @"Paywalls are not supported prior to iOS 15.", nil);
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

@end