//
//  GPUImageVibranceFilter.h
//  GPUImage
//
//  Created by Xin Zeng on 12/27/16.
//  Copyright © 2016 Brad Larson. All rights reserved.
//

#import "GPUImageFilter.h"

@interface GPUImageVibranceFilter : GPUImageFilter
{
    GLint vibranceUniform;
}

@property(readwrite, nonatomic) CGFloat vibrance;

@end
