Shader "Custom/StencilReference"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            // Enable Stencil Buffer Writing
            Stencil
            {
                Ref 1         // Reference value for stencil test
                Comp Always   // Always write to stencil buffer
                Pass Replace  // Replace stencil value with Ref
            }

            ZWrite On        // Default depth write
            ZTest LEqual     // Default depth test
            Cull Back        // Default culling
            ColorMask RGBA   // Write to all color channels

            // Basic unlit color
            SetColor [_Color]
        }
    }
}
