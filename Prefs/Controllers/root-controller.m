#import "root-controller.h"

@implementation DKRootController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"root" target:self];
    }
    return _specifiers;
}

@end
