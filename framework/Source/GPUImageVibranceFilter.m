//
//  GPUImageVibranceFilter.m
//  GPUImage
//
//  Created by Xin Zeng on 12/27/16.
//  Copyright © 2016 Brad Larson. All rights reserved.
//

#import "GPUImageVibranceFilter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageVibranceFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform mediump float vibrance;
 
 void main()
 {
    mediump vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    mediump float mx = max(textureColor.r, max(textureColor.g, textureColor.b));
    mediump float amt = (mx - (textureColor.r + textureColor.g + textureColor.b)/3.0) * (-vibrance * 3.0);
    textureColor.rgb = mix(textureColor.rgb, vec3(mx), amt);
    gl_FragColor = textureColor;
 }
 );
#else
NSString *const kGPUImageVibranceFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform float vibrance;
 
 void main()
 {
    vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    float mx = max(textureColor.r, max(textureColor.g, textureColor.b));
    float amt = (mx - (textureColor.r + textureColor.g + textureColor.b)/3.0) * (-vibrance * 3.0);
    textureColor.rgb = mix(textureColor.rgb, vec3(mx), amt);
    gl_FragColor = textureColor;
 }
 );
#endif

@implementation GPUImageVibranceFilter

@synthesize vibrance = _vibrance;

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageVibranceFragmentShaderString]))
    {
        return nil;
    }
    
    vibranceUniform = [filterProgram uniformIndex:@"vibrance"];
    self.vibrance = 0;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setVibrance:(CGFloat)newValue;
{
    _vibrance = newValue;
    
    [self setFloat:_vibrance forUniform:vibranceUniform program:filterProgram];
}


@end

