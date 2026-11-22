#import "config.h"
#import "keys.h"

static id DKConfigValue(NSString *key) {
    return CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)key, (__bridge CFStringRef)DK_PREFS_DOMAIN));
}

BOOL DKConfigEnabled(void) {
    id value = DKConfigValue(DK_ENABLED_KEY);
    return value ? [value boolValue] : YES;
}

BOOL DKConfigExcluded(NSString *bundleIdentifier) {
    if (!bundleIdentifier.length) return NO;
    id value = DKConfigValue([DK_EXCLUDE_PREFIX stringByAppendingString:bundleIdentifier]);
    return [value boolValue];
}
