//
//  SYLTableViewTestFieldCell.m
//  XLForm
//
//  Created by 苏友龙 on 2018/1/13.
//  Copyright © 2018年 Xmartlabs. All rights reserved.
//

#import "SYLTableViewTestFieldCell.h"
#import <Masonry.h>

NSString *const XLFormRowDescriptorTypeSYLTextField = @"XLFormRowDescriptorTypeSYLTextField";

@interface SYLTableViewTestFieldCell()<UITextFieldDelegate>

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UITextField *inputField;

@end

@implementation SYLTableViewTestFieldCell

#pragma mark --- lazyLoad
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _titleLabel;
}

- (UITextField *)inputField{
    if (!_inputField) {
        _inputField = [[UITextField alloc] init];
        _inputField.delegate = self;
        _inputField.placeholder = @"请输入姓名";
    }
    return _inputField;
}

// 在表单中注册对应的cell以及对应的ID
+(void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[SYLTableViewTestFieldCell class] forKey:XLFormRowDescriptorTypeSYLTextField];
}

//设置属性  类似于初始化的属性不变的属性进行预先配置 添加控件和布局(纯代码)
-(void)configure {
    [super configure];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.inputField];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.size.mas_equalTo(CGSizeMake(100, self.contentView.frame.size.height));
        make.centerY.equalTo(self);
    }];
    
    [_inputField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.size.mas_equalTo(CGSizeMake(100, self.contentView.frame.size.height));
        make.centerY.equalTo(self);
    }];
    
}

-(void)update {
    [super update];
    //设置title
    _titleLabel.text = self.rowDescriptor.title;
    //根据value设置text
    _inputField.text = self.rowDescriptor.value;
}

//设置cell高度
+(CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 50;
}

#pragma mark --- UITextFieldDelegate
//必须重写
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [self.formViewController textFieldShouldReturn:textField];
}
//必须重写
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return [self.formViewController textFieldShouldBeginEditing:textField];
}
//给value赋值，在VC里才可以获取
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self textFieldDidChange:textField];
    [self.formViewController textFieldDidEndEditing:textField];
}

//-(void)setReturnKeyType:(UIReturnKeyType)returnKeyType {
//    _inputField.returnKeyType = returnKeyType;
//}
//
//-(UIReturnKeyType)returnKeyType {
//    return _inputField.returnKeyType;
//}

//设置value
- (void)textFieldDidChange:(UITextField *)textField {
    if (_inputField == textField && textField.text.length > 0) {
        self.rowDescriptor.value = textField.text;
    } else {
        self.rowDescriptor.value = nil;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
