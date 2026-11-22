#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface NSObject (DKDumpWeb)
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;
@end

static NSMutableString *DKDumpOutput;
static NSInteger DKDumpCount;

static NSString *DKDumpColor(id value) {
    if (![value isKindOfClass:UIColor.class]) return @"nil";
    UIColor *color = value;
    CGFloat red, green, blue, alpha;
    if ([color getRed:&red green:&green blue:&blue alpha:&alpha]) {
        return [NSString stringWithFormat:@"%.2f/%.2f/%.2f/%.2f", red, green, blue, alpha];
    }
    CGFloat white;
    if ([color getWhite:&white alpha:&alpha]) {
        return [NSString stringWithFormat:@"w%.2f/%.2f", white, alpha];
    }
    return @"pattern";
}

static NSString *DKDumpExtra(UIView *view) {
    if ([view isKindOfClass:UILabel.class]) {
        return [NSString stringWithFormat:@" text=%@", DKDumpColor(((UILabel *)view).textColor)];
    }
    if ([view isKindOfClass:UITextView.class]) {
        UITextView *textView = (UITextView *)view;
        id attribute = nil;
        if (textView.textStorage.length) {
            attribute = [textView.textStorage attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:NULL];
        }
        return [NSString stringWithFormat:@" text=%@ attr=%@ tint=%@", DKDumpColor(textView.textColor), DKDumpColor(attribute), DKDumpColor(textView.tintColor)];
    }
    if ([view isKindOfClass:UIButton.class]) {
        return [NSString stringWithFormat:@" title=%@", DKDumpColor([(UIButton *)view titleColorForState:UIControlStateNormal])];
    }
    Class webClass = NSClassFromString(@"UIWebDocumentView");
    if (webClass && [view isKindOfClass:webClass] && [view respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
        NSString *script = @"document.body ? getComputedStyle(document.body).color + ' on ' + getComputedStyle(document.body).backgroundColor : 'no body'";
        NSString *result = [view stringByEvaluatingJavaScriptFromString:script];
        return [NSString stringWithFormat:@" web=%@", [result isKindOfClass:NSString.class] ? result : @"nil"];
    }
    return @"";
}

static void DKDumpView(UIView *view, NSInteger depth) {
    if (DKDumpCount >= 300 || depth > 14) return;
    DKDumpCount++;
    NSString *layerColor = @"-";
    if (view.layer.backgroundColor) {
        layerColor = DKDumpColor([UIColor colorWithCGColor:view.layer.backgroundColor]);
    }
    [DKDumpOutput appendFormat:@"%*s%@ bg=%@ layer=%@%@%@\n", (int)depth * 2, "", NSStringFromClass(view.class), DKDumpColor(view.backgroundColor), layerColor, DKDumpExtra(view), view.hidden ? @" hidden" : @""];
    NSUInteger limit = [view isKindOfClass:UIScrollView.class] ? 8 : NSUIntegerMax;
    NSUInteger index = 0;
    for (UIView *subview in view.subviews) {
        if (index++ >= limit) break;
        DKDumpView(subview, depth + 1);
    }
}

static void DKDumpController(UIViewController *controller) {
    while (controller) {
        [DKDumpOutput appendFormat:@"vc %@\n", NSStringFromClass(controller.class)];
        UIViewController *next = controller.presentedViewController;
        if (!next && [controller isKindOfClass:UINavigationController.class]) {
            next = ((UINavigationController *)controller).topViewController;
        }
        if (!next && [controller isKindOfClass:UITabBarController.class]) {
            next = ((UITabBarController *)controller).selectedViewController;
        }
        if (!next && controller.childViewControllers.count) {
            next = controller.childViewControllers.lastObject;
        }
        controller = next;
    }
}

static void DKDumpMethods(NSString *name, NSString *needle) {
    Class cls = NSClassFromString(name);
    if (!cls) {
        [DKDumpOutput appendFormat:@"class %@ missing\n", name];
        return;
    }
    unsigned int count = 0;
    Method *methods = class_copyMethodList(cls, &count);
    for (unsigned int index = 0; index < count; index++) {
        NSString *selector = NSStringFromSelector(method_getName(methods[index]));
        if ([selector rangeOfString:needle options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [DKDumpOutput appendFormat:@"-[%@ %@]\n", name, selector];
        }
    }
    free(methods);
}

static void DKDump(void) {
    UIApplication *application = UIApplication.sharedApplication;
    if (!application || application.applicationState != UIApplicationStateActive) return;
    NSString *bundleID = NSBundle.mainBundle.bundleIdentifier ?: @"unknown";
    if ([bundleID isEqualToString:@"com.apple.springboard"]) return;
    DKDumpOutput = [NSMutableString string];
    DKDumpCount = 0;
    [DKDumpOutput appendFormat:@"bundle %@ statusBarStyle %ld\n", bundleID, (long)application.statusBarStyle];
    for (UIWindow *window in application.windows) {
        [DKDumpOutput appendFormat:@"window %@ level %.0f\n", NSStringFromClass(window.class), window.windowLevel];
        DKDumpController(window.rootViewController);
        DKDumpView(window, 0);
    }
    for (NSString *name in @[@"UITextInputTraits", @"UIWebDocumentView", @"UIKeyboardImpl"]) {
        DKDumpMethods(name, @"ppearance");
    }
    NSString *fileName = [NSString stringWithFormat:@"darkula-dump-%@.txt", bundleID];
    for (NSString *directory in @[NSTemporaryDirectory(), @"/var/mobile"]) {
        [DKDumpOutput writeToFile:[directory stringByAppendingPathComponent:fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

__attribute__((constructor))
static void DKDumpInstall(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:5 repeats:YES block:^(NSTimer *timer) {
            DKDump();
        }];
    });
}
