//
//  SYLStudyViewController.m
//  XLForm
//
//  Created by 合商云购 on 2018/1/12.
//  Copyright © 2018年 Xmartlabs. All rights reserved.
//

#import "XLForm.h"
#import "SYLStudyViewController.h"
#import "SYLTableViewTestFieldCell.h"

@interface SYLStudyViewController ()

@end

NSString *const kSYLName = @"name";
NSString *const kSYLEmail = @"email";
NSString *const kSYLTwitter = @"twitter";
NSString *const kSYLTitleText = @"titleText";
NSString *const kSYLText = @"text";
NSString *const kSYLCustomField = @"customField";

@implementation SYLStudyViewController

- (id)init {
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:@"标题"];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    //成为第一响应者
    form.assignFirstResponderOnShow = YES;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"section标题"];
    [form addFormSection:section];
    
    //name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSYLName rowType:XLFormRowDescriptorTypeName title:@"name"];
    row.value = @"默认姓名";
    [section addFormRow:row];
    
    //email
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSYLEmail rowType:XLFormRowDescriptorTypeEmail title:@"请填写你的email"];
    //添加验证email 应该可以自己添加验证
    [row addValidator:[XLFormValidator emailValidator]];
    [section addFormRow:row];
    
    //twitter
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSYLTwitter rowType:XLFormRowDescriptorTypeTwitter title:@"Twitter"];
    row.value = @"默认值";
    //不允许点击输入
    row.disabled = @YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSYLTitleText rowType:XLFormRowDescriptorTypeTextView title:@"标题"];
    row.height = 55;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSYLText rowType:XLFormRowDescriptorTypeTextView];
    [row.cellConfigAtConfigure setObject:@"请填写" forKey:@"textView.placeholder"];
    row.height = 75;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSYLCustomField rowType:XLFormRowDescriptorTypeSYLTextField title:@"姓名："];
    [section addFormRow:row];
    
    return [self initWithForm:form];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction)];
}

- (void)saveAction {
    //验证输入的内容是否有错误
    NSArray * validationErrors = [self formValidationErrors];
    if (validationErrors.count > 0){
        [self showFormValidationError:[validationErrors firstObject]];
//        return;
    }
    [self.tableView endEditing:YES];
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Valid Form", nil)
                                                                              message:@"No errors found"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    
    //获取输入的内容
    NSDictionary *values = [self formValues];
    NSLog(@"填写的内容：%@",values);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
