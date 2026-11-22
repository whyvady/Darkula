#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "palette.h"

// Mail asserts on any backdrop style except the light one (2010).
// Always feed it the light style so dark bars don't crash the app.
static const NSUInteger DKMailLightBackdrop = 2010;

static void DKShimMailBackdrop(void) {
    SEL sel = NSSelectorFromString(@"updateForBackdropStyle:");
    const char *image = [NSBundle mainBundle].executablePath.fileSystemRepresentation;
    unsigned count = 0;
    const char **names = objc_copyClassNamesForImage(image, &count);
    for (unsigned i = 0; i < count; i++) {
        Class cls = objc_getClass(names[i]);
        unsigned n = 0;
        Method *methods = class_copyMethodList(cls, &n);
        for (unsigned j = 0; j < n; j++) {
            if (method_getName(methods[j]) != sel) continue;
            IMP orig = method_getImplementation(methods[j]);
            method_setImplementation(methods[j], imp_implementationWithBlock(^(id self, NSUInteger style) {
                ((void (*)(id, SEL, NSUInteger))orig)(self, sel, DKMailLightBackdrop);
            }));
        }
        free(methods);
    }
    free(names);
}

%ctor {
    if (!DKProcessEnabled()) return;
    if (![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.mobilemail"]) return;
    DKShimMailBackdrop();
}
