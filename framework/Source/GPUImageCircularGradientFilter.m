//
//  GPUImageCircularGradientFilter.m
//  GPUImage
//
//  Created by Xin Zeng on 12/28/16.
//  Copyright © 2016 Brad Larson. All rights reserved.
//

#import "GPUImageCircularGradientFilter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageCircularGradientFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform highp float centerX;
 uniform highp float centerY;
 uniform mediump float innerRadius;
 uniform mediump float outerRadius;
 uniform highp float widthOffset;
 uniform highp float heightOffset;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     highp float distance = sqrt(pow((textureCoordinate.x - centerX) / widthOffset, 2.0) + pow((textureCoordinate.y - centerY) / heightOffset, 2.0));
     highp float alpha = max(min((outerRadius - distance) / (outerRadius - innerRadius), 1.0), 0.0);
     gl_FragColor = vec4(textureColor.rgb, max(textureColor.a, alpha));
 }
 );
#else
NSString *const kGPUImageCircularGradientFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform float centerX;
 uniform float centerY;
 uniform float innerRadius;
 uniform float outerRadius;
 uniform float widthOffset;
 uniform float heightOffset;
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     float distance = sqrt(pow((textureCoordinate.x - centerX) / widthOffset, 2.0) + pow((textureCoordinate.y - centerY) / heightOffset, 2.0));
     float alpha = max(min((outerRadius - distance) / (outerRadius - innerRadius), 1.0), 0.0);
     gl_FragColor = vec4(textureColor.rgb, max(textureColor.a, alpha));
 }
 );
#endif

@implementation GPUImageCircularGradientFilter

@synthesize center = _center;
@synthesize innerRadius = _innerRadius;
@synthesize outerRadius = _outerRadius;

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageCircularGradientFragmentShaderString]))
    {
        return nil;
    }
    
    centerXUniform = [filterProgram uniformIndex:@"centerX"];
    centerYUniform = [filterProgram uniformIndex:@"centerY"];
    innerRadiusUniform = [filterProgram uniformIndex:@"innerRadius"];
    outerRadiusUniform = [filterProgram uniformIndex:@"outerRadius"];
    widthOffsetUniform = [filterProgram uniformIndex:@"widthOffset"];
    heightOffsetUniform = [filterProgram uniformIndex:@"heightOffset"];
    
    _center = CGPointMake(0, 0);
    _innerRadius = 0;
    _outerRadius = 0;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    [super setupFilterForSize:filterFrameSize];
    
    float centerX = _center.x / filterFrameSize.width;
    float centerY = _center.y / filterFrameSize.height;
    
    [self setFloat:centerX forUniform:centerXUniform program:filterProgram];
    [self setFloat:centerY forUniform:centerYUniform program:filterProgram];
    [self setFloat:_innerRadius forUniform:innerRadiusUniform program:filterProgram];
    [self setFloat:_outerRadius forUniform:outerRadiusUniform program:filterProgram];
    [self setFloat:1.0/filterFrameSize.width forUniform:widthOffsetUniform program:filterProgram];
    [self setFloat:1.0/filterFrameSize.height forUniform:heightOffsetUniform program:filterProgram];
}

@end
