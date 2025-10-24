//
// Copyright © 2025 TruVideo. All rights reserved.
//

#import "TextFieldTableViewCell.h"

@interface TextFieldTableViewCell ()

@property (nonatomic, strong) UITextField *textField;

@end

@implementation TextFieldTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupTextField];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.textField.text = nil;
    self.textField.placeholder = nil;
    self.textField.keyboardType = UIKeyboardTypeDefault;
}

- (void)setupTextField {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    self.textField.borderStyle = UITextBorderStyleRoundedRect;

    [self.contentView addSubview:self.textField];

    UILayoutGuide *guide = self.contentView.layoutMarginsGuide;

    [NSLayoutConstraint activateConstraints:@[
        [self.textField.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor],
        [self.textField.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor],
        [self.textField.topAnchor constraintEqualToAnchor:guide.topAnchor],
        [self.textField.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor]
    ]];
}

@end
