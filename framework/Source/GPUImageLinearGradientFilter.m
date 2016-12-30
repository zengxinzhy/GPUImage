//
//  GPUImageLinearGradientFilter.m
//  GPUImage
//
//  Created by Xin Zeng on 12/28/16.
//  Copyright © 2016 Brad Larson. All rights reserved.
//

#import "GPUImageLinearGradientFilter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageLinearGradientFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform highp float centerX;
 uniform highp float centerY;
 uniform lowp float innerWidth;
 uniform lowp float outerWidth;
 uniform lowp float sinTheta;
 uniform lowp float cosTheta;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     highp float distance = abs((textureCoordinate.x - centerX) * sinTheta + (textureCoordinate.y - centerY) * cosTheta);
     highp float alpha = max(min((outerWidth - distance) / (outerWidth - innerWidth), 1.0), 0.0);
     gl_FragColor = vec4(textureColor.rgb, max(textureColor.a, alpha));
 }
 );
#else
NSString *const kGPUImageLinearGradientFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform float centerX;
 uniform float centerY;
 uniform float innerWidth;
 uniform float outerWidth;
 uniform float sinTheta;
 uniform float cosTheta;
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     float distance = abs((textureCoordinate.x - centerX) * sinTheta + (textureCoordinate.y - centerY) * cosTheta);
     float alpha = max(min((outerWidth - distance) / (outerWidth - innerWidth), 1.0), 0.0);
     gl_FragColor = vec4(textureColor.rgb, max(textureColor.a, alpha));
 } );
#endif

@implementation GPUImageLinearGradientFilter

@synthesize center = _center;
@synthesize innerWidth = _innerWidth;
@synthesize outerWidth = _outerWidth;
@synthesize theta = _theta;

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageLinearGradientFragmentShaderString]))
    {
        return nil;
    }
    
    centerXUniform = [filterProgram uniformIndex:@"centerX"];
    centerYUniform = [filterProgram uniformIndex:@"centerY"];
    innerWidthUniform = [filterProgram uniformIndex:@"innerWidth"];
    outerWidthUniform = [filterProgram uniformIndex:@"outerWidth"];
    sinThetaUniform = [filterProgram uniformIndex:@"sinTheta"];
    cosThetaUniform = [filterProgram uniformIndex:@"cosTheta"];
    
    _center = CGPointMake(0, 0);
    _innerWidth = 0;
    _outerWidth = 0;
    _theta = 0;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    [super setupFilterForSize:filterFrameSize];
    
    float centerX = _center.x / filterFrameSize.width;
    float centerY = _center.y / filterFrameSize.height;
    float iWidth = _innerWidth * sqrt(pow(1/filterFrameSize.width*sin(_theta), 2) + pow(1/filterFrameSize.height*cos(_theta), 2));
    float oWidth = _outerWidth * sqrt(pow(1/filterFrameSize.width*sin(_theta), 2) + pow(1/filterFrameSize.height*cos(_theta), 2));
    
    [self setFloat:centerX forUniform:centerXUniform program:filterProgram];
    [self setFloat:centerY forUniform:centerYUniform program:filterProgram];
    [self setFloat:iWidth forUniform:innerWidthUniform program:filterProgram];
    [self setFloat:oWidth forUniform:outerWidthUniform program:filterProgram];
    [self setFloat:-sinf(_theta) forUniform:sinThetaUniform program:filterProgram];
    [self setFloat:cosf(_theta) forUniform:cosThetaUniform program:filterProgram];
}

@end
