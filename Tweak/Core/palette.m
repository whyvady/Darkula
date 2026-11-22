#import "palette.h"
#import "config.h"
#import <objc/runtime.h>
#import <string.h>

static const CGFloat DKGrayTolerance = 0.06;
static const CGFloat DKMinimumAlpha = 0.05;
static const CGFloat DKDarkLimit = 0.35;
static const CGFloat DKLightLimit = 0.88;
static const CGFloat DKWhiteLimit = 0.98;
static const CGFloat DKCardValue = 0.11;
static const CGFloat DKMidValue = 0.04;
static const CGFloat DKTextPivot = 0.5;
static const CGFloat DKTextBase = 0.96;
static const CGFloat DKTextSlope = 0.7;
static const CGFloat DKSeparatorValue = 0.28;
static const CGFloat DKSelectionValue = 0.22;

static BOOL DKGrayValue(UIColor *color, CGFloat *value, CGFloat *alpha) {
    CGFloat red = 0, green = 0, blue = 0;
    if (![color getRed:&red green:&green blue:&blue alpha:alpha]) return NO;
    if (MAX(red, MAX(green, blue)) - MIN(red, MIN(green, blue)) > DKGrayTolerance) return NO;
    *value = (red + green + blue) / 3;
    return YES;
}

static CGFloat DKBackgroundValue(CGFloat value) {
    if (value <= DKDarkLimit) return value;
    if (value >= DKWhiteLimit) return DKCardValue;
    if (value > DKLightLimit) {
        return DKMidValue * (DKWhiteLimit - value) / (DKWhiteLimit - DKLightLimit);
    }
    return DKDarkLimit - (value - DKDarkLimit) * (DKDarkLimit - DKMidValue) / (DKLightLimit - DKDarkLimit);
}

static CGFloat DKTextValue(CGFloat value) {
    if (value >= DKTextPivot) return value;
    return DKTextBase - value * DKTextSlope;
}

BOOL DKProcessEnabled(void) {
    static BOOL enabled;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSString *identifier = NSBundle.mainBundle.bundleIdentifier;
        if (!identifier.length) {
            enabled = [NSProcessInfo.processInfo.processName isEqualToString:@"splashboardd"] && DKConfigEnabled();
            return;
        }
        enabled = ![identifier isEqualToString:@"com.apple.springboard"] && DKConfigEnabled() && !DKConfigExcluded(identifier);
    });
    return enabled;
}

BOOL DKIsPrivateObject(id object) {
    const char *name = class_getName(object_getClass(object));
    return name[0] == '_' && strncmp(name, "_Tt", 3) != 0;
}

BOOL DKIsSolidColor(UIColor *color) {
    CGFloat red = 0, green = 0, blue = 0, alpha = 0;
    return [color getRed:&red green:&green blue:&blue alpha:&alpha];
}

BOOL DKIsLightGray(UIColor *color) {
    CGFloat value = 0, alpha = 0;
    return DKGrayValue(color, &value, &alpha) && value > DKTextPivot;
}

BOOL DKIsUniformText(NSAttributedString *text) {
    if (!text.length) return YES;
    NSUInteger length = text.length;
    __block BOOL uniform = YES;
    [text enumerateAttribute:NSForegroundColorAttributeName
                     inRange:NSMakeRange(0, length)
                     options:0
                  usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (range.length == length) return;
        uniform = NO;
        *stop = YES;
    }];
    return uniform;
}

UIColor *DKBackgroundColor(UIColor *color) {
    CGFloat value = 0, alpha = 0;
    if (!DKGrayValue(color, &value, &alpha) || alpha < DKMinimumAlpha) return color;
    CGFloat mapped = DKBackgroundValue(value);
    if (mapped == value) return color;
    return [UIColor colorWithWhite:mapped alpha:alpha];
}

UIColor *DKTextColor(UIColor *color) {
    CGFloat value = 0, alpha = 0;
    if (!DKGrayValue(color, &value, &alpha) || alpha < DKMinimumAlpha) return color;
    CGFloat mapped = DKTextValue(value);
    if (mapped == value) return color;
    return [UIColor colorWithWhite:mapped alpha:alpha];
}

UIColor *DKSeparatorColor(void) {
    static UIColor *color;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        color = [UIColor colorWithWhite:DKSeparatorValue alpha:1];
    });
    return color;
}

UIColor *DKSelectionColor(void) {
    static UIColor *color;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        color = [UIColor colorWithWhite:DKSelectionValue alpha:1];
    });
    return color;
}
