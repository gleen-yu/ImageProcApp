//
//  ImageProcessing.m
//  ImageProcApp
//
//  Created by YUGWANGYONG on 2/12/16.
//  Copyright © 2016 yong. All rights reserved.
//

#import "ImageProcessing.h"
#import <UIKit/UIKit.h>

typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;

@implementation ImageProcessing

// 이미지 저장 공간을 할당합니다.
// 이미지를 저장하기위해서는 1px당 32bit, 4byte의 공간이 필요하기 때문에
// 전체 이미지를 저장하려면 이미지 넓이 x 이미지깊이 x 4byte의 메모리가 필요.
-(void)AllocMemoryImage:(int)width Height:(int)height {
    imageWidth = width;
    imageHeight = height;
    
    // 메모리를 할당합니다.
    rawImage = (uint8_t *)malloc(imageWidth * imageHeight * 4 * sizeof(char *));
    memset(rawImage, 0, imageWidth * imageHeight * 4 * sizeof(char *));
}

// 프로세싱할 이미지를 설정.
-(id)setImage:(UIImage *)image
{
    [self DataInit];
    if( image == nil) {
        return nil;
    }
    
    CGSize size = image.size;
    [self AllocMemoryImage:size.width Height:size.height]; // 비트맵 메모리를 할당.
    
    // 디바이스의 RGB 컬러 스페이스를 생성.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 비트맵 그래픽 컨텍스트를 생성.
    CGContextRef context = CGBitmapContextCreate(rawImage, imageWidth, imageHeight, 8, imageWidth * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    // 이미지를 그린다.
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth,imageHeight), image.CGImage);
    CGContextRelease(context); // 그래픽컨텍스트를해제.
    CGColorSpaceRelease(colorSpace); // 컬러 스페이스를 해제.
    
    return self;
}

-(UIImage*)getImage
{
    return [self BitmapToUIImage];
}

// 비트맵 이미지를 UIImage로 변환
-(UIImage*)BitmapToUIImage:(unsigned char *) bitmap BitmapSize:(CGSize)size
{
    // 디바이스의 컬러 스페이스를 생성.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 그래픽 컨텍스트를 생성.
    CGContextRef Context = CGBitmapContextCreate(bitmap, size.width, size.height, 8, size.width*4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace); // 컬러 스페이스를 해제.
    CGImageRef ref = CGBitmapContextCreateImage(Context);
    // 비트맵을 이미지로 랜더링(변환)
    CGContextRelease(Context); // 그래픽 컨텍스트를 해제
    UIImage *img = [UIImage imageWithCGImage:ref];
    CFRelease(ref);
    return img;
}

-(UIImage *)BitmapToUIImage
{
    // 컬러 스페이스를 생성
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef Context = CGBitmapContextCreate (rawImage, imageWidth, imageHeight, 8, imageWidth * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    CGImageRef ref = CGBitmapContextCreateImage(Context);
    // 비트맵을 이미지로 랜더링(변환)합니다.
    CGContextRelease(Context); // 그래픽 컨텍스트를 해제.
    UIImage *img = [UIImage imageWithCGImage:ref];
    CFRelease(ref);
    return img;
}

#pragma mark -
#pragma mark Image Processing
-(id)getGrayImage
{
    // 그레이스케일로 변환하는 공식
    // V = R X 0.299 + G X 0.587 + B X 0.114
    for(int y = 0; y < imageHeight; y++) {
        for(int x = 0; x < imageWidth; x++) {
            uint8_t *pRawImage = (uint8_t *) & rawImage[(y * imageWidth + x) * 4];
            uint32_t gray = 0.299 * pRawImage[RED] + 0.587 * pRawImage[GREEN] + 0.114 * pRawImage[BLUE];
            pRawImage[RED] = (unsigned char) gray;
            pRawImage[GREEN] = (unsigned char) gray;
            pRawImage[BLUE] = (unsigned char) gray;
        }
    }
    return self;
}

// 이미지 반전 메서드
// 최대 값인 255에서 해당 위치의 R,G,B 값을 빼면 된다.
-(id)getInverseImage
{
    for(int y = 0; y <imageHeight; y++) {
        for (int x = 0; x < imageWidth; x++) {
            uint8_t *pRawImage = (uint8_t *) &rawImage[(y * imageWidth + x) * 4];
            pRawImage[RED] = 255 - pRawImage[RED];
            pRawImage[GREEN] = 255 - pRawImage[GREEN];
            pRawImage[BLUE] = 255 - pRawImage[BLUE];
        }
    }
    return self;
}

int getOffset(int x, int y, int width, int index) {return y * width * 4 + x * 4 + index;};


// 윤곽선 검출 기법에는 소벨(Sobel), 로버트(Roverts), 프리윗(Prewitt),
// 라플라시안(Laplacian), 캐니(Canny) 등 여러가지가 있다.
// 보통 프로그래밍을 하기 위해서는 알고리즘에 의한 직접 계산보다는 마스크를 이용하는 방법을 사용.
-(UIImage *)getTrackingImage
{
    // 비트맵 저장 메로리를 생성.
    unsigned char *OutBitmap = (unsigned char *)malloc(imageHeight * imageWidth * 4);
    [self getGrayImage]; // 그레이스케일로 변환.
    
    int Matrix1[9] = {-1, 0, 1, -2, 0, 2, -1, 0, 1}; // Sobel mask X
    int Matrix2[9] = {-1, -2, -1, 0, 0, 0, 1, 2 ,1 }; // Sobel mask Y
    
    for(int y = 0; y < imageHeight; y++)
        for(int x = 0; x <imageWidth; x++){

            int sumr1 = 0, sumr2 = 0; // 초기화
            int sumg1 = 0, sumg2 = 0;
            int sumb1 = 0, sumb2 = 0;
            
            int offset = 0;
            for(int j = 0; j < 3; j++)
                for (int i = 0; i < 3; i++) {
                    sumr1 += rawImage[getOffset(x+i, y+j, imageWidth, RED)] *Matrix1[offset];
                    sumr2 += rawImage[getOffset(x+i, y+j, imageWidth, RED)] *Matrix2[offset];
            
                    sumg1 += rawImage[getOffset(x+i, y+j, imageWidth, GREEN)] *Matrix1[offset];
                    sumg2 += rawImage[getOffset(x+i, y+j, imageWidth, GREEN)] *Matrix2[offset];
                    
                    sumb1 += rawImage[getOffset(x+i, y+j, imageWidth, BLUE)] *Matrix1[offset];
                    sumb2 += rawImage[getOffset(x+i, y+j, imageWidth, BLUE)] *Matrix2[offset];
                    
                    offset++;
                }
            
            int sumr = MIN(((ABS(sumr1) + ABS(sumr2)) / 2), 255);
            int sumg = MIN(((ABS(sumg1) + ABS(sumg2)) / 2), 255);
            int sumb = MIN(((ABS(sumb1) + ABS(sumb2)) / 2), 255);
            
            OutBitmap[getOffset(x+1, y+1, imageWidth, RED)] = (unsigned char) sumr;
            OutBitmap[getOffset(x+1, y+1, imageWidth, GREEN)] = (unsigned char) sumg;
            OutBitmap[getOffset(x+1, y+1, imageWidth, BLUE)] = (unsigned char) sumb;
            OutBitmap[getOffset(x+1, y+1, imageWidth, ALPHA)] = (unsigned char) rawImage[getOffset(x, y, imageWidth, ALPHA)];
            
        }
    return [self BitmapToUIImage:OutBitmap BitmapSize:CGSizeMake(imageWidth, imageHeight)];
}

#pragma mask -
// 메모리를 해제하고 초기화
-(void)DataInit
{
    if( rawImage){
        free(rawImage);
        rawImage = nil;
    }
}
@end



























