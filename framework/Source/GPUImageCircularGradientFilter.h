//
//  GPUImageCircularGradientFilter.h
//  GPUImage
//
//  Created by Xin Zeng on 12/28/16.
//  Copyright © 2016 Brad Larson. All rights reserved.
//

#import "GPUImageFilter.h"

@interface GPUImageCircularGradientFilter : GPUImageFilter
{
    GLint centerXUniform;
    GLint centerYUniform;
    GLint innerRadiusUniform;
    GLint outerRadiusUniform;
    GLint widthOffsetUniform;
    GLint heightOffsetUniform;
}

@property(readwrite, nonatomic) CGPoint center;
@property(readwrite, nonatomic) CGFloat innerRadius;
@property(readwrite, nonatomic) CGFloat outerRadius;

@end
