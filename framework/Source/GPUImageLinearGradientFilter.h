//
//  GPUImageLinearGradientFilter.h
//  GPUImage
//
//  Created by Xin Zeng on 12/28/16.
//  Copyright © 2016 Brad Larson. All rights reserved.
//

#import "GPUImageFilter.h"

@interface GPUImageLinearGradientFilter : GPUImageFilter
{
    GLint centerXUniform;
    GLint centerYUniform;
    GLint innerWidthUniform;
    GLint outerWidthUniform;
    GLint sinThetaUniform;
    GLint cosThetaUniform;
}

@property(readwrite, nonatomic) CGPoint center;
@property(readwrite, nonatomic) CGFloat innerWidth;
@property(readwrite, nonatomic) CGFloat outerWidth;
@property(readwrite, nonatomic) CGFloat theta;

@end
