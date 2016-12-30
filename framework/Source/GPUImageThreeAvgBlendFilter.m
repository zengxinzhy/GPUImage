//
//  GPUImageThreeAvgBlendFilter.m
//  GPUImage
//
//  Created by Xin Zeng on 12/27/16.
//  Copyright © 2016 Brad Larson. All rights reserved.
//

#import "GPUImageThreeAvgBlendFilter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageThreeAvgBlendShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 varying highp vec2 textureCoordinate3;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 
 void main()
 {
     gl_FragColor = texture2D(inputImageTexture, textureCoordinate) * 0.333333333 + texture2D(inputImageTexture2, textureCoordinate) * 0.333333333 + texture2D(inputImageTexture3, textureCoordinate) * 0.333333334;
 }
 );
#else
NSString *const kGPUImageThreeAvgBlendShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 varying vec2 textureCoordinate3;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 
 void main()
 {
     gl_FragColor = texture2D(inputImageTexture, textureCoordinate) * 0.333333333 + texture2D(inputImageTexture2, textureCoordinate) * 0.333333333 + texture2D(inputImageTexture3, textureCoordinate) * 0.333333334;
 }
 );
#endif

@implementation GPUImageThreeAvgBlendFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageThreeAvgBlendShaderString]))
    {
        return nil;
    }
    
    return self;
}
@end
