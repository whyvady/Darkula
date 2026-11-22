#import <UIKit/UIKit.h>

static NSString *DKDetailColor(UIColor *color) {
    if (!color) return @"nil";
    CGFloat red, green, blue, alpha;
    if ([color getRed:&red green:&green blue:&blue alpha:&alpha]) {
        return [NSString stringWithFormat:@"%.2f/%.2f/%.2f/%.2f", red, green, blue, alpha];
    }
    return @"other";
}

static NSString *DKDetailImage(UIImage *image) {
    if (!image) return @"nil";
    return [NSString stringWithFormat:@"%@ mode=%ld", NSStringFromCGSize(image.size), (long)image.renderingMode];
}

static void DKDetailView(UIView *view, NSInteger depth, NSMutableString *output) {
    if (depth > 8 || output.length > 60000) return;
    NSMutableString *line = [NSMutableString stringWithFormat:@"%*s%@ frame=%@ alpha=%.2f tint=%@", (int)depth * 2, "", NSStringFromClass(view.class), NSStringFromCGRect(view.frame), view.alpha, DKDetailColor(view.tintColor)];
    if (view.hidden) [line appendString:@" hidden"];
    if (view.layer.compositingFilter) [line appendFormat:@" compositing=%@", view.layer.compositingFilter];
    if (view.layer.filters.count) [line appendFormat:@" filters=%@", view.layer.filters];
    if ([view isKindOfClass:UIImageView.class]) {
        [line appendFormat:@" image=%@", DKDetailImage(((UIImageView *)view).image)];
    }
    if ([view isKindOfClass:UIButton.class]) {
        UIButton *button = (UIButton *)view;
        [line appendFormat:@" title=%@ image=%@", DKDetailColor([button titleColorForState:UIControlStateNormal]), DKDetailImage([button imageForState:UIControlStateNormal])];
    }
    [output appendFormat:@"%@\n", line];
    for (UIView *subview in view.subviews) {
        DKDetailView(subview, depth + 1, output);
    }
}

static void DKDetailCollect(UIView *view, NSSet *names, NSMutableArray *found, NSInteger depth) {
    if (depth > 20) return;
    if ([names containsObject:NSStringFromClass(view.class)]) {
        [found addObject:view];
        return;
    }
    for (UIView *subview in view.subviews) {
        DKDetailCollect(subview, names, found, depth + 1);
    }
}

static void DKDetail(void) {
    UIApplication *application = UIApplication.sharedApplication;
    if (!application || application.applicationState != UIApplicationStateActive) return;
    NSString *bundleID = NSBundle.mainBundle.bundleIdentifier ?: @"unknown";
    if ([bundleID isEqualToString:@"com.apple.springboard"]) return;
    NSSet *names = [NSSet setWithArray:@[@"UIKeyboardAssistantBar", @"_UINavigationBarContentView", @"UIToolbar", @"UISearchBar"]];
    NSMutableArray *found = [NSMutableArray array];
    for (UIWindow *window in application.windows) {
        DKDetailCollect(window, names, found, 0);
    }
    if (!found.count) return;
    NSMutableString *output = [NSMutableString string];
    for (UIView *root in found) {
        [output appendFormat:@"root %@ in %@\n", NSStringFromClass(root.class), NSStringFromClass(root.superview.class)];
        DKDetailView(root, 1, output);
    }
    NSString *file = [NSString stringWithFormat:@"darkula-detail-%@.txt", bundleID];
    [output writeToFile:[NSTemporaryDirectory() stringByAppendingPathComponent:file] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

__attribute__((constructor))
static void DKDetailInstall(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:5 repeats:YES block:^(NSTimer *timer) {
            DKDetail();
        }];
    });
}
