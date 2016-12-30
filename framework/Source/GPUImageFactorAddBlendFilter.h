//
//  GPUImageFactorAddBlendFilter.h
//  GPUImage
//
//  Created by Xin Zeng on 12/29/16.
//  Copyright © 2016 Brad Larson. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

@interface GPUImageFactorAddBlendFilter : GPUImageTwoInputFilter
{
    GLint factor1Uniform;
    GLint factor2Uniform;
}

@property(readwrite, nonatomic) CGFloat factor1;
@property(readwrite, nonatomic) CGFloat factor2;

@end
