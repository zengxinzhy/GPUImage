//
//  GPUImageRhombusBlurFilter.m
//  GPUImage
//
//  Created by Xin Zeng on 12/27/16.
//  Copyright © 2016 Brad Larson. All rights reserved.
//

#import "GPUImageRhombusBlurFilter.h"

@implementation GPUImageRhombusBlurFilter

@synthesize sideLength = _sideLength;
@synthesize orientation = _orientation;

- (id)initWithFirstStageVertexShaderFromString:(NSString *)firstStageVertexShaderString firstStageFragmentShaderFromString:(NSString *)firstStageFragmentShaderString secondStageVertexShaderFromString:(NSString *)secondStageVertexShaderString secondStageFragmentShaderFromString:(NSString *)secondStageFragmentShaderString
{
    if (!(self = [super initWithFirstStageVertexShaderFromString:firstStageVertexShaderString firstStageFragmentShaderFromString:firstStageFragmentShaderString secondStageVertexShaderFromString:secondStageVertexShaderString secondStageFragmentShaderFromString:secondStageFragmentShaderString]))
    {
        return nil;
    }
    
    _sideLength = 4.0;
    return self;
}

- (id)init;
{
    NSString *currentGaussianBlurVertexShader = [[self class] vertexShaderForOptimizedBlurOfSideLength:4];
    NSString *currentGaussianBlurFragmentShader = [[self class] fragmentShaderForOptimizedBlurOfSideLength:4];
    
    return [self initWithFirstStageVertexShaderFromString:currentGaussianBlurVertexShader firstStageFragmentShaderFromString:currentGaussianBlurFragmentShader secondStageVertexShaderFromString:currentGaussianBlurVertexShader secondStageFragmentShaderFromString:currentGaussianBlurFragmentShader];
}

+ (NSString *)vertexShaderForOptimizedBlurOfSideLength:(NSUInteger)sideLength;
{
    if (sideLength < 1)
    {
        return kGPUImageVertexShaderString;
    }
    
    // From these weights we calculate the offsets to read interpolated values from
    NSUInteger numberOfOptimizedOffsets = MIN(sideLength, 16);
    
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    // Header
    [shaderString appendFormat:@"\
     attribute vec4 position;\n\
     attribute vec4 inputTextureCoordinate;\n\
     \n\
     uniform float texelWidthOffset;\n\
     uniform float texelHeightOffset;\n\
     \n\
     varying vec2 blurCoordinates[%lu];\n\
     \n\
     void main()\n\
     {\n\
     gl_Position = position;\n\
     \n\
     vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);\n", (unsigned long)(numberOfOptimizedOffsets)];
    
    // Inner offset loop
    [shaderString appendString:@"blurCoordinates[0] = inputTextureCoordinate.xy;\n"];
    for (NSUInteger currentOptimizedOffset = 1; currentOptimizedOffset < numberOfOptimizedOffsets; currentOptimizedOffset++)
    {
        [shaderString appendFormat:@"\
         blurCoordinates[%lu] = inputTextureCoordinate.xy + singleStepOffset * %f;\n", (unsigned long)(currentOptimizedOffset), (GLfloat)currentOptimizedOffset];
    }
    
    // Footer
    [shaderString appendString:@"}\n"];
    
    return shaderString;
}

+ (NSString *)fragmentShaderForOptimizedBlurOfSideLength:(NSUInteger)sideLength;
{
    if (sideLength < 1)
    {
        return kGPUImagePassthroughFragmentShaderString;
    }
    
    NSUInteger numberOfOptimizedOffsets = MIN(sideLength, 16);
    
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    
    // Header
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    [shaderString appendFormat:@"\
     uniform sampler2D inputImageTexture;\n\
     uniform highp float texelWidthOffset;\n\
     uniform highp float texelHeightOffset;\n\
     \n\
     varying highp vec2 blurCoordinates[%lu];\n\
     \n\
     void main()\n\
     {\n\
     lowp vec4 sum = vec4(0.0);\n", (unsigned long)(numberOfOptimizedOffsets) ];
#else
    [shaderString appendFormat:@"\
     uniform sampler2D inputImageTexture;\n\
     uniform float texelWidthOffset;\n\
     uniform float texelHeightOffset;\n\
     \n\
     varying vec2 blurCoordinates[%lu];\n\
     \n\
     void main()\n\
     {\n\
     vec4 sum = vec4(0.0);\n", numberOfOptimizedOffsets ];
#endif
    
    GLfloat weight = 1.0 / (GLfloat)(sideLength);
    
    // Inner texture loop
    [shaderString appendFormat:@"sum += texture2D(inputImageTexture, blurCoordinates[0]) * %f;\n", weight];
    
    for (NSUInteger currentBlurCoordinateIndex = 1; currentBlurCoordinateIndex < numberOfOptimizedOffsets; currentBlurCoordinateIndex++)
    {
        [shaderString appendFormat:@"sum += texture2D(inputImageTexture, blurCoordinates[%lu]) * %f;\n", (unsigned long)(currentBlurCoordinateIndex), weight];
    }
    
    // If the number of required samples exceeds the amount we can pass in via varyings, we have to do dependent texture reads in the fragment shader
    if (sideLength > numberOfOptimizedOffsets)
    {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        [shaderString appendString:@"highp vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);\n"];
#else
        [shaderString appendString:@"vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);\n"];
#endif
        
        for (NSUInteger currentOverlowTextureRead = numberOfOptimizedOffsets; currentOverlowTextureRead < sideLength; currentOverlowTextureRead++)
        {
            [shaderString appendFormat:@"sum += texture2D(inputImageTexture, blurCoordinates[0] + singleStepOffset * %f) * %f;\n", (GLfloat)currentOverlowTextureRead, weight];
        }
    }
    
    // Footer
    [shaderString appendString:@"\
     gl_FragColor = sum;\n\
     }\n"];
    
    return shaderString;
}

- (void)setSideLength:(CGFloat)newValue;
{
    // 7.0 is the limit for blur size for hardcoded varying offsets
    
    if (round(newValue) != _sideLength)
    {
        _sideLength = round(newValue); // For now, only do integral sigmas

        NSString *newRhombusBlurVertexShader = [[self class] vertexShaderForOptimizedBlurOfSideLength:_sideLength];
        NSString *newRhombusBlurFragmentShader = [[self class] fragmentShaderForOptimizedBlurOfSideLength:_sideLength];
//
//        NSLog(@"Optimized vertex shader: \n%@", newRhombusBlurVertexShader);
//        NSLog(@"Optimized fragment shader: \n%@", newRhombusBlurFragmentShader);
        
        [self switchToVertexShader:newRhombusBlurVertexShader fragmentShader:newRhombusBlurFragmentShader];
    }
}

- (void)setupTexelOffsetForOrientation:(NSInteger)orientation filterFrameSize:(CGSize)filterFrameSize widthOffset:(GLfloat *)widthOffset heightOffset:(GLfloat *)heightOffset;
{
    switch (orientation) {
        case 0:
            *widthOffset = _horizontalTexelSpacing / filterFrameSize.width;
            *heightOffset = 0;
            break;
        case 1:
            *widthOffset = -_horizontalTexelSpacing / filterFrameSize.width / 2;
            *heightOffset = -_verticalTexelSpacing / filterFrameSize.height / 2 * sqrt(3);
            break;
        case 2:
            *widthOffset = -_horizontalTexelSpacing / filterFrameSize.width / 2;
            *heightOffset = _verticalTexelSpacing / filterFrameSize.height / 2 * sqrt(3);
            break;
        default:
            assert(false);
            break;
    }
    if (GPUImageRotationSwapsWidthAndHeight(inputRotation))
    {
        GLfloat tmp = *widthOffset;
        *widthOffset = *heightOffset;
        *heightOffset = tmp;
    }
}

- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    runSynchronouslyOnVideoProcessingQueue(^{
        // The first pass through the framebuffer may rotate the inbound image, so need to account for that by changing up the kernel ordering for that pass

        [self setupTexelOffsetForOrientation:_orientation filterFrameSize:filterFrameSize widthOffset:&verticalPassTexelWidthOffset heightOffset:&verticalPassTexelHeightOffset];
        
        [self setupTexelOffsetForOrientation:(_orientation+1)%3 filterFrameSize:filterFrameSize widthOffset:&horizontalPassTexelWidthOffset heightOffset:&horizontalPassTexelHeightOffset];
    });
}
@end
