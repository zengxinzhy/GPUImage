//
//  GPUImageFactorAddBlendFilter.m
//  GPUImage
//
//  Created by Xin Zeng on 12/29/16.
//  Copyright © 2016 Brad Larson. All rights reserved.
//

#import "GPUImageFactorAddBlendFilter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageFactorAddBlendFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform lowp float factor1;
 uniform lowp float factor2;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate);
    
     gl_FragColor = vec4(textureColor.rgb * factor1 + textureColor2.rgb * factor2, 1);
 }
 );
#else
NSString *const kGPUImageFactorAddBlendFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform float factor1;
 uniform float factor2;
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate);
     
     gl_FragColor = vec4(textureColor.rgb * factor1 + textureColor2.rgb * factor2, 1);
 }
 );
#endif

@implementation GPUImageFactorAddBlendFilter

@synthesize factor1 = _factor1;
@synthesize factor2 = _factor2;

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageFactorAddBlendFragmentShaderString]))
    {
        return nil;
    }
    
    factor1Uniform = [filterProgram uniformIndex:@"factor1"];
    factor2Uniform = [filterProgram uniformIndex:@"factor2"];
    
    _factor1 = 0.5;
    _factor2 = 0.5;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setFactor1:(CGFloat)newValue;
{
    _factor1 = newValue;
    
    [self setFloat:_factor1 forUniform:factor1Uniform program:filterProgram];
}

- (void)setFactor2:(CGFloat)newValue;
{
    _factor2 = newValue;
    
    [self setFloat:_factor2 forUniform:factor2Uniform program:filterProgram];
}

@end
