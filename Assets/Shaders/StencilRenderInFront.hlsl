Shader "Custom/StencilRenderInFront"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        // Pass 1: Render only in front of the reference object
        

        Pass
        {
            Stencil
            {
                Ref 1         // Match the reference value written earlier
                Comp Equal    // Render only where stencil value matches Ref
                Pass Keep     // Keep the stencil buffer value
            }

            ZWrite On        // Default depth write
            ZTest LEqual     // Default depth test
            Cull Back        // Default culling
            ColorMask RGBA   // Write to all color channels

            // Basic unlit color
            SetColor [_Color]
        }
        
        // Pass 2: Render normally where not overlapping the reference object
        Pass
        {
            Stencil
            {
                Ref 1         // Match the reference value written earlier
                Comp NotEqual // Render where stencil value is NOT Ref
                Pass Keep     // Keep the stencil buffer value
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
