//
//  GPUImageRhombusBlurFilter.h
//  GPUImage
//
//  Created by Xin Zeng on 12/27/16.
//  Copyright © 2016 Brad Larson. All rights reserved.
//

#import "GPUImageGaussianBlurFilter.h"

@interface GPUImageRhombusBlurFilter : GPUImageTwoPassTextureSamplingFilter
{
    CGFloat _sideLength;
    NSInteger _orientation;
}

@property (readwrite, nonatomic) CGFloat sideLength;
@property (readwrite, nonatomic) NSInteger orientation;

- (void)setupTexelOffsetForOrientation:(NSInteger)orientation filterFrameSize:(CGSize)filterFrameSize widthOffset:(GLfloat *)widthOffset heightOffset:(GLfloat *)heightOffset;

@end
