//
//  ViewController.m
//  ImageProcApp
//
//  Created by YUGWANGYONG on 2/12/16.
//  Copyright © 2016 yong. All rights reserved.
//

#import "ViewController.h"
#import "ImageProcessing.h"
#import "ImageProcInfoViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize pImageProcInfoViewController;

- (void)viewDidLoad { // 뷰 로딩이 완료된 후 추가 작업을 수행하기 위해 호출되는 메서드.
    pImageProcessing = [[ImageProcessing alloc] init];
    orginImage = [UIImage imageNamed:@"default.png"]; // 이미지를 불러옴.
    [pImageView setImage:orginImage];
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
-(IBAction)PushSetupClick // 앱 정보 화면
{
    // ImageProcInfoViewController.xib를 로드해 객체를 생성.
    if (self.pImageProcInfoViewController == nil) {
        ImageProcInfoViewController *viewController = [[ImageProcInfoViewController alloc]initWithNibName:@"ImageProcInfoViewController" bundle:nil];
        self.pImageProcInfoViewController= viewController;
    }
    // 화면이 전환되는 뷰는 모달뷰.
    [self presentViewController:self.pImageProcInfoViewController animated:YES completion:nil]; // 앱 정보 모달 뷰 화면이 나타나게 한다.
}

// 사진 앨범에서 이미지를 선택
// 사용자가 촬영한 모든 사진 앨범의 이미지 뿐만 아니라
// 즉시 사진을 촬영하여 이미지를 이용할 수 있게 지원.
-(IBAction)runGeneralPicker
{
    UIImagePickerController *picker= [[UIImagePickerController alloc] init];
    // 사용할 소스를 설정한다.
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = NO; // 편집 기능 여부 설정.
    [self presentViewController:picker animated:YES completion:nil];
}
// 이미지 피커 화면을 닫는다.
-(void) finishendPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 사진을 선택했을 경우 호출
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
// 선택한 이미지를 가져온다.
    orginImage = nil;
    orginImage = [info objectForKey: UIImagePickerControllerOriginalImage];
    
    [self finishendPicker];
    
    [pImageView setImage:orginImage];
}

//사진 선택을 취소했을 경우 호출
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self finishendPicker];
}

// 그레이스케일 변환
-(IBAction)WhiteBlackImage
{
    pImageView.image = [[[pImageProcessing setImage:orginImage] getGrayImage] getImage];
}

// 이미지를 반전하여 처리
-(IBAction)InverseImage
{
    pImageView.image = [[[pImageProcessing setImage:orginImage] getInverseImage] getImage];
}

// 이미지 윤곽선을 추출
-(IBAction) TrackingImage
{
    pImageView.image = [[pImageProcessing setImage:orginImage] getTrackingImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end









