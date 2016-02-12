//
//  ViewController.h
//  ImageProcApp
//
//  Created by YUGWANGYONG on 2/12/16.
//  Copyright © 2016 yong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageProcInfoViewController.h"

@class ImageProcessing;
// 아이폰의 사진 앨범에 저장된 이미지 이용.
// UIImagePickerController 클래스가 제공하는 대화상자를 이용.
// UIImagePickerController는 모달 대화상자의 형태, 내부에 내비게이션 컨트롤을 포함하고 있는 클래스.
// UIImagePickerControllerDelegate와 UINavigationControllerDelegate 프로토콜을 준수해야한다.
@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    ImageProcInfoViewController *pImageProcInfoViewController;
    IBOutlet UIButton *infoButton;
    IBOutlet UIImageView *pImageView; // 이미지 뷰
    
    ImageProcessing *pImageProcessing; // 이미지 프로세싱 클래스
    UIImage *orginImage; // 원본 이미지
}
-(IBAction) PushSetupClick; // 앱 정보
-(IBAction) runGeneralPicker; // 사진 가져오기
-(IBAction) WhiteBlackImage; // 그레이스케일 변환
-(IBAction) InverseImage; // 이미지 반전
-(IBAction) TrackingImage; // 윤곽선 추출
@property (strong, nonatomic) ImageProcInfoViewController * pImageProcInfoViewController;

@end

