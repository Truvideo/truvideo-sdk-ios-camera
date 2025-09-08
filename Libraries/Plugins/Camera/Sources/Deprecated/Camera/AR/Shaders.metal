//
//  Shaders.metal
//  MetalARRecorder
//
//  Created by Luis Francisco Piura Mejia on 25/3/24.
//

#include <metal_stdlib>
#include <simd/simd.h>

// Include header shared between this Metal shader code and C code executing Metal API commands
#import "ShaderTypes.h"

using namespace metal;

typedef struct {
    float2 position [[attribute(kVertexAttributePosition)]];
    float2 texCoord [[attribute(kVertexAttributeTexcoord)]];
} ImageVertex;


typedef struct {
    float4 position [[position]];
    float2 texCoord;
} ImageColorInOut;


// This function is used to create the vertexes of the AR captured image
vertex ImageColorInOut capturedImageVertexTransform(ImageVertex in [[stage_in]]) {
    ImageColorInOut out;
    
    // Pass through the image vertex's position
    out.position = float4(in.position, 0.0, 1.0);
    
    // Pass through the texture coordinate
    out.texCoord = in.texCoord;
    
    return out;
}

// This function uses the returned values of the `capturedImageVertexTransform`
// and it colors them to create and RGB pixel than can be rendered in the AR camera view
fragment float4 capturedImageFragmentShader(
    ImageColorInOut in [[stage_in]],
    texture2d<float, access::sample> capturedImageTextureY [[ texture(0) ]],
    texture2d<float, access::sample> capturedImageTextureCbCr [[ texture(1) ]]
) {
    constexpr sampler colorSampler(
        mip_filter::linear,
        mag_filter::linear,
        min_filter::linear
    );
    
    const float4x4 ycbcrToRGBTransform = float4x4(
        float4(+1.0000f, +1.0000f, +1.0000f, +0.0000f),
        float4(+0.0000f, -0.3441f, +1.7720f, +0.0000f),
        float4(+1.4020f, -0.7141f, +0.0000f, +0.0000f),
        float4(-0.7010f, +0.5291f, -0.8860f, +1.0000f)
    );
    
    // Sample Y and CbCr textures to get the YCbCr color at the given texture coordinate
    float4 ycbcr = float4(
        capturedImageTextureY.sample(colorSampler, in.texCoord).r,
        capturedImageTextureCbCr.sample(colorSampler, in.texCoord).rg, 1.0
    );
    
    // Return converted RGB color
    float4 color = ycbcrToRGBTransform * ycbcr;
    
    return color;
}


typedef struct {
    float3 position [[attribute(kVertexAttributePosition)]];
    float2 texCoord [[attribute(kVertexAttributeTexcoord)]];
    half3 normal    [[attribute(kVertexAttributeNormal)]];
} Vertex;


typedef struct {
    float4 position [[position]];
    float4 color;
    half3  eyePosition;
    half3  normal;
    float2 textureCoordinate;
    uint instanceCount;
    bool invertTexture;
    bool transparent;
} ColorInOut;


// This function is in charge to create the clip space for the 3D objects used for the AR Camera
vertex ColorInOut anchorGeometryVertexTransform(
    Vertex in [[stage_in]],
    constant SharedUniforms &sharedUniforms [[ buffer(kBufferIndexSharedUniforms) ]],
    constant InstanceUniforms *instanceUniforms [[ buffer(kBufferIndexInstanceUniforms) ]],
    uint vid [[vertex_id]],
    uint iid [[instance_id]]
) {
    ColorInOut out;
    
    // Make position a float4 to perform 4x4 matrix math on it
    float4 position = float4(in.position, 1.0);
    
    float4x4 modelMatrix = instanceUniforms[iid].modelMatrix;
    float4x4 modelViewMatrix = sharedUniforms.viewMatrix * modelMatrix;
    
    // Calculate the position of our vertex in clip space and output for clipping and rasterization
    out.position = sharedUniforms.projectionMatrix * modelViewMatrix * position;
    out.textureCoordinate = in.texCoord;
    
    // Calculate the position of our vertex in eye space
    out.eyePosition = half3((modelViewMatrix * position).xyz);
    
    // Rotate our normals to world coordinates
    float4 normal = modelMatrix * float4(in.normal.x, in.normal.y, in.normal.z, 0.0f);
    out.normal = normalize(half3(normal.xyz));
    
    return out;
}

// This function is in charge of getting the texture for every pixel of the 3D objects.
// It uses every vertex generated from the `anchorGeometryVertexTransform` method
// and draws the texture for each one of them
fragment half4 anchorGeometryFragmentLighting(
    ColorInOut in [[stage_in]],
    constant SharedUniforms &uniforms [[ buffer(kBufferIndexSharedUniforms) ]],
    texture2d<half> texture [[texture(0)]],
    sampler samplerState [[sampler(0)]]
) {
    float2 textureCoordinate = in.textureCoordinate.xy;
        
    // Sample the texture using the transformed coordinates
    // For the Y coordinate we subtract the value of Y from 1 in order
    // to get the correct textures in Y.
    return texture.sample(samplerState, float2(textureCoordinate.x, 1 - textureCoordinate.y));
}

// This function is in charge of getting the texture for every pixel of the 3D objects.
// It uses every vertex generated from the `anchorGeometryVertexTransform` method
// and draws the texture for each one of them
fragment half4 targetAnchorGeometryFragmentLighting(
    ColorInOut in [[stage_in]]
) {
    return half4(1, 1, 1, 0.7);
}

fragment half4 measureAnchorGeometryFragmentLighting(
    ColorInOut in [[stage_in]]
) {
    return half4(1, 1, 1, 1);
}

fragment half4 measurePreviewGeometryFragmentLighting(
    ColorInOut in [[stage_in]]
) {
    return half4(0.7, 0.7, 0.7, 0.7);
}

typedef struct {
    float4 position [[attribute(kVertexAttributePosition)]];
} VertexMeasure;

vertex ColorInOut measureLineGeometryVertexTransform(
    uint vid [[vertex_id]],
    constant VertexMeasure* vertexArray [[buffer(kBufferIndexInstanceUniforms)]],
    constant SharedUniforms &sharedUniforms [[ buffer(kBufferIndexSharedUniforms) ]]
) {
    ColorInOut out;
    out.position = sharedUniforms.projectionMatrix * sharedUniforms.viewMatrix * vertexArray[vid].position;
    return out;
}

fragment half4 measureLineGeometryFragmentLightning() {
    return half4(1, 1, 1, 1);
}

typedef struct {
    float3 position [[attribute(kVertexAttributePosition)]];
    float2 texCoord [[attribute(kVertexAttributeTexcoord)]];
    bool inverTexture [[attribute(kVertexAttributeNormal)]];
    bool transparent [[attribute(kVertexAttributeColor)]];
} TextVertex;


vertex ColorInOut anchorGeometryMeasureTextTransform(
    constant TextVertex* in [[buffer(kBufferIndexInstanceVertices)]],
    constant SharedUniforms &sharedUniforms [[ buffer(kBufferIndexSharedUniforms) ]],
    constant InstanceUniforms *instanceUniforms [[ buffer(kBufferIndexInstanceUniforms) ]],
    uint vid [[vertex_id]],
    uint iid [[instance_id]]
) {
    ColorInOut out;
    
    // Make position a float4 to perform 4x4 matrix math on it
    float4 position = float4(in[vid].position, 1.0);
    
    float4x4 modelMatrix = instanceUniforms[iid].modelMatrix;
    float4x4 modelViewMatrix = sharedUniforms.viewMatrix * modelMatrix;
    
    // Calculate the position of our vertex in clip space and output for clipping and rasterization
    out.position = sharedUniforms.projectionMatrix * modelViewMatrix * position;
    out.textureCoordinate = in[vid].texCoord;
    out.invertTexture = in[vid].inverTexture;
    
    // Calculate the position of our vertex in eye space
    out.eyePosition = half3((modelViewMatrix * position).xyz);
    
    out.instanceCount = iid;
    out.transparent = in[vid].transparent;
    
    return out;
}

fragment half4 anchorGeometryMeasureTextLightning(
    ColorInOut in [[stage_in]],
    constant SharedUniforms &uniforms [[ buffer(kBufferIndexSharedUniforms) ]],
    array<texture2d<half>, 64> textures [[texture(0)]],
    sampler samplerState [[sampler(0)]]
) {
    float2 scaledTextureCoordinate = in.textureCoordinate.xy;
    float rotatedX = scaledTextureCoordinate.x; // Swap x and y components
    if (in.invertTexture) {
        rotatedX = 1 - scaledTextureCoordinate.x;
    }
    float rotatedY = scaledTextureCoordinate.y; // Invert one of the components if needed
        
        // Sample the texture using the transformed coordinates
    texture2d<half> texture = textures[in.instanceCount];
    half4 color = texture.sample(samplerState, float2(rotatedX, rotatedY));
    // Get the center of the texture (assuming the center for the rounded corners effect)
    float2 center = float2(0.5, 0.5);
    
    // Calculate the distance from the center to the current fragment
    float dist = distance(in.textureCoordinate, center);
    
    // Calculate the alpha based on the distance
    half alphaDelta = in.transparent ? 0.3 : 0.0;
    half alpha = dist < 10 ? color.a - alphaDelta : 0.0;
    
    // Return the color with modified alpha
    return half4(color.rgb, alpha);
}
