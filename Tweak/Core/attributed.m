#import "attributed.h"
#import "palette.h"

NSAttributedString *DKAttributedText(NSAttributedString *text) {
    if (!text.length) return text;
    __block NSMutableAttributedString *result = nil;
    [text enumerateAttribute:NSForegroundColorAttributeName
                     inRange:NSMakeRange(0, text.length)
                     options:0
                  usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (![value isKindOfClass:UIColor.class]) return;
        UIColor *mapped = DKTextColor(value);
        if (mapped == value) return;
        if (!result) result = [text mutableCopy];
        [result addAttribute:NSForegroundColorAttributeName value:mapped range:range];
    }];
    return result ?: text;
}
