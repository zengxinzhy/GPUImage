#import "GPUImageTwoPassTextureSamplingFilter.h"

@implementation GPUImageTwoPassTextureSamplingFilter

@synthesize verticalTexelSpacing = _verticalTexelSpacing;
@synthesize horizontalTexelSpacing = _horizontalTexelSpacing;

#pragma mark -
#pragma mark Initialization and teardown

- (id)initWithFirstStageVertexShaderFromString:(NSString *)firstStageVertexShaderString firstStageFragmentShaderFromString:(NSString *)firstStageFragmentShaderString secondStageVertexShaderFromString:(NSString *)secondStageVertexShaderString secondStageFragmentShaderFromString:(NSString *)secondStageFragmentShaderString
{
    if (!(self = [super initWithFirstStageVertexShaderFromString:firstStageVertexShaderString firstStageFragmentShaderFromString:firstStageFragmentShaderString secondStageVertexShaderFromString:secondStageVertexShaderString secondStageFragmentShaderFromString:secondStageFragmentShaderString]))
    {
		return nil;
    }
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];

        verticalPassTexelWidthOffsetUniform = [filterProgram uniformIndex:@"texelWidthOffset"];
        verticalPassTexelHeightOffsetUniform = [filterProgram uniformIndex:@"texelHeightOffset"];
        
        horizontalPassTexelWidthOffsetUniform = [secondFilterProgram uniformIndex:@"texelWidthOffset"];
        horizontalPassTexelHeightOffsetUniform = [secondFilterProgram uniformIndex:@"texelHeightOffset"];
    });
    
    self.verticalTexelSpacing = 1.0;
    self.horizontalTexelSpacing = 1.0;
    
    return self;
}

- (void)setUniformsForProgramAtIndex:(NSUInteger)programIndex;
{
    [super setUniformsForProgramAtIndex:programIndex];
    
    if (programIndex == 0)
    {
        glUniform1f(verticalPassTexelWidthOffsetUniform, verticalPassTexelWidthOffset);
        glUniform1f(verticalPassTexelHeightOffsetUniform, verticalPassTexelHeightOffset);
    }
    else
    {
        glUniform1f(horizontalPassTexelWidthOffsetUniform, horizontalPassTexelWidthOffset);
        glUniform1f(horizontalPassTexelHeightOffsetUniform, horizontalPassTexelHeightOffset);
    }
}

- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    runSynchronouslyOnVideoProcessingQueue(^{
        // The first pass through the framebuffer may rotate the inbound image, so need to account for that by changing up the kernel ordering for that pass
        if (GPUImageRotationSwapsWidthAndHeight(inputRotation))
        {
            verticalPassTexelWidthOffset = _verticalTexelSpacing / filterFrameSize.height;
            verticalPassTexelHeightOffset = 0.0;
        }
        else
        {
            verticalPassTexelWidthOffset = 0.0;
            verticalPassTexelHeightOffset = _verticalTexelSpacing / filterFrameSize.height;
        }
        
        horizontalPassTexelWidthOffset = _horizontalTexelSpacing / filterFrameSize.width;
        horizontalPassTexelHeightOffset = 0.0;
    });
}

#pragma mark -
#pragma mark Accessors

- (void)setVerticalTexelSpacing:(CGFloat)newValue;
{
    _verticalTexelSpacing = newValue;
    [self setupFilterForSize:[self sizeOfFBO]];
}

- (void)setHorizontalTexelSpacing:(CGFloat)newValue;
{
    _horizontalTexelSpacing = newValue;
    [self setupFilterForSize:[self sizeOfFBO]];
}

- (void)switchToVertexShader:(NSString *)newVertexShader fragmentShader:(NSString *)newFragmentShader;
{
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        filterProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:newVertexShader fragmentShaderString:newFragmentShader];
        
        if (!filterProgram.initialized)
        {
            [self initializeAttributes];
            
            if (![filterProgram link])
            {
                NSString *progLog = [filterProgram programLog];
                NSLog(@"Program link log: %@", progLog);
                NSString *fragLog = [filterProgram fragmentShaderLog];
                NSLog(@"Fragment shader compile log: %@", fragLog);
                NSString *vertLog = [filterProgram vertexShaderLog];
                NSLog(@"Vertex shader compile log: %@", vertLog);
                filterProgram = nil;
                NSAssert(NO, @"Filter shader link failed");
            }
        }
        
        filterPositionAttribute = [filterProgram attributeIndex:@"position"];
        filterTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate"];
        filterInputTextureUniform = [filterProgram uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputImageTexture" for the fragment shader
        verticalPassTexelWidthOffsetUniform = [filterProgram uniformIndex:@"texelWidthOffset"];
        verticalPassTexelHeightOffsetUniform = [filterProgram uniformIndex:@"texelHeightOffset"];
        [GPUImageContext setActiveShaderProgram:filterProgram];
        
        glEnableVertexAttribArray(filterPositionAttribute);
        glEnableVertexAttribArray(filterTextureCoordinateAttribute);
        
        secondFilterProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:newVertexShader fragmentShaderString:newFragmentShader];
        
        if (!secondFilterProgram.initialized)
        {
            [self initializeSecondaryAttributes];
            
            if (![secondFilterProgram link])
            {
                NSString *progLog = [secondFilterProgram programLog];
                NSLog(@"Program link log: %@", progLog);
                NSString *fragLog = [secondFilterProgram fragmentShaderLog];
                NSLog(@"Fragment shader compile log: %@", fragLog);
                NSString *vertLog = [secondFilterProgram vertexShaderLog];
                NSLog(@"Vertex shader compile log: %@", vertLog);
                secondFilterProgram = nil;
                NSAssert(NO, @"Filter shader link failed");
            }
        }
        
        secondFilterPositionAttribute = [secondFilterProgram attributeIndex:@"position"];
        secondFilterTextureCoordinateAttribute = [secondFilterProgram attributeIndex:@"inputTextureCoordinate"];
        secondFilterInputTextureUniform = [secondFilterProgram uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputImageTexture" for the fragment shader
        secondFilterInputTextureUniform2 = [secondFilterProgram uniformIndex:@"inputImageTexture2"]; // This does assume a name of "inputImageTexture2" for second input texture in the fragment shader
        horizontalPassTexelWidthOffsetUniform = [secondFilterProgram uniformIndex:@"texelWidthOffset"];
        horizontalPassTexelHeightOffsetUniform = [secondFilterProgram uniformIndex:@"texelHeightOffset"];
        [GPUImageContext setActiveShaderProgram:secondFilterProgram];
        
        glEnableVertexAttribArray(secondFilterPositionAttribute);
        glEnableVertexAttribArray(secondFilterTextureCoordinateAttribute);
        
        [self setupFilterForSize:[self sizeOfFBO]];
        glFinish();
    });
}

@end
