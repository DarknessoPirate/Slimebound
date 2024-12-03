Shader "Custom/PixelArtTriplanarStencil"
{
    Properties
    {
        [NoScaleOffset]_BaseColor("BaseColor", 2D) = "white" {}
        _TextureScale("TextureScale", Float) = 1
        _Smoothness("Smoothness", Float) = 0
        _Emission("Emission", Color) = (0, 0, 0, 0)
        _DetailsScale("DetailsScale", Float) = 1
        [NoScaleOffset]_DetailsTexture("DetailsTexture", 2D) = "white" {}
        _DetailsOpacity("DetailsOpacity", Range(0, 2)) = 1
        _NoiseScale("NoiseScale", Float) = 10
        _NoiseContrast("NoiseContrast", Float) = 1.5
        [ToggleUI]_InverseNoise("InverseNoise", Float) = 0
        _Warp("Warp", Float) = 0
        _MappingScale("MappingScale", Vector) = (1, 1, 0, 0)
        _ColorizeTex("ColorizeTex", Color) = (1, 1, 1, 0)
        _ColorizeDetails("ColorizeDetails", Color) = (1, 1, 1, 0)
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="Geometry"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
		// Added -------------
		// Enable Stencil Buffer Writing
		Stencil
		{
			Ref 1         // Reference value for stencil test
			Comp Always   // Always write to stencil buffer
			Pass Replace  // Replace stencil value with Ref
		}
		ColorMask RGBA   // Write to all color channels
		// End added ---------

        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
		
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _FORWARD_PLUS
        #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion : INTERP3;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP4;
            #endif
             float4 tangentWS : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor_TexelSize;
        float _TextureScale;
        float _Smoothness;
        float4 _Emission;
        float4 _DetailsTexture_TexelSize;
        float _NoiseScale;
        float _NoiseContrast;
        float _InverseNoise;
        float _DetailsOpacity;
        float _Warp;
        float _DetailsScale;
        float2 _MappingScale;
        float4 _ColorizeTex;
        float4 _ColorizeDetails;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColor);
        SAMPLER(sampler_BaseColor);
        TEXTURE2D(_DetailsTexture);
        SAMPLER(sampler_DetailsTexture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // unity-custom-func-begin
        void TriplanarUVmapping_float(float3 Position, float Tile, float3 Normal, float Blend, out float2 Out){
        float3 Node_UV = Position * Tile;
        
        float3 Node_Blend = pow(abs(Normal), Blend);
        
        Node_Blend /= (Node_Blend.x + Node_Blend.y + Node_Blend.z ).xxx;
        
        float2 Node_X = Node_UV.zy;
        
        float2 Node_Y = Node_UV.xz;
        
        float2 Node_Z = Node_UV.xy;
        
        Out = Node_X * Node_Blend.x + Node_Y * Node_Blend.y + Node_Z * Node_Blend.z;
        
        }
        // unity-custom-func-end
        
        struct Bindings_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float
        {
        float3 AbsoluteWorldSpacePosition;
        };
        
        void SG_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float(float _Warp, float _Tile, Bindings_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float IN, out float2 Out_Vector4_1)
        {
        float _Property_a4bdf31d4c204e49aa4073d18397661a_Out_0_Float = _Tile;
        float _Property_0ff2401d4526446a8967fd71528a7620_Out_0_Float = _Warp;
        float2 _TriplanarUVmappingCustomFunction_4a6ec34197d14ff9b595de762184b1e3_Out_4_Vector2;
        TriplanarUVmapping_float(IN.AbsoluteWorldSpacePosition, _Property_a4bdf31d4c204e49aa4073d18397661a_Out_0_Float, IN.AbsoluteWorldSpacePosition, _Property_0ff2401d4526446a8967fd71528a7620_Out_0_Float, _TriplanarUVmappingCustomFunction_4a6ec34197d14ff9b595de762184b1e3_Out_4_Vector2);
        Out_Vector4_1 = _TriplanarUVmappingCustomFunction_4a6ec34197d14ff9b595de762184b1e3_Out_4_Vector2;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        float Unity_SimpleNoise_ValueNoise_Deterministic_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_Tchou_2_1_float(c0, r0);
            float r1; Hash_Tchou_2_1_float(c1, r1);
            float r2; Hash_Tchou_2_1_float(c2, r2);
            float r3; Hash_Tchou_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_Deterministic_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Contrast_float(float3 In, float Contrast, out float3 Out)
        {
            float midpoint = pow(0.5, 2.2);
            Out =  (In - midpoint) * Contrast + midpoint;
        }
        
        void Unity_OneMinus_float3(float3 In, out float3 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Blend_Overwrite_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            Out = lerp(Base, Blend, Opacity);
        }
        
        void Unity_Clamp_float4(float4 In, float4 Min, float4 Max, out float4 Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_ReplaceColor_float(float3 In, float3 From, float3 To, float Range, out float3 Out, float Fuzziness)
        {
            float Distance = distance(From, In);
            Out = lerp(To, In, saturate((Distance - Range) / max(Fuzziness, 1e-5f)));
        }
        
        void Unity_Clamp_float3(float3 In, float3 Min, float3 Max, out float3 Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Saturation_float(float3 In, float Saturation, out float3 Out)
        {
            float luma = dot(In, float3(0.2126729, 0.7151522, 0.0721750));
            Out =  luma.xxx + Saturation.xxx * (In - luma.xxx);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseColor);
            float _Property_7c0fe046032c4123aa0030efd337df6e_Out_0_Float = _TextureScale;
            float3 Triplanar_6912659c33ff4153b8e96b9536a80d87_UV = IN.AbsoluteWorldSpacePosition * _Property_7c0fe046032c4123aa0030efd337df6e_Out_0_Float;
            float3 Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(float(1), floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend /= dot(Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend, 1.0);
            float4 Triplanar_6912659c33ff4153b8e96b9536a80d87_X = SAMPLE_TEXTURE2D(_Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.tex, _Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.samplerstate, Triplanar_6912659c33ff4153b8e96b9536a80d87_UV.zy);
            float4 Triplanar_6912659c33ff4153b8e96b9536a80d87_Y = SAMPLE_TEXTURE2D(_Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.tex, _Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.samplerstate, Triplanar_6912659c33ff4153b8e96b9536a80d87_UV.xz);
            float4 Triplanar_6912659c33ff4153b8e96b9536a80d87_Z = SAMPLE_TEXTURE2D(_Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.tex, _Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.samplerstate, Triplanar_6912659c33ff4153b8e96b9536a80d87_UV.xy);
            float4 _Triplanar_6912659c33ff4153b8e96b9536a80d87_Out_0_Vector4 = Triplanar_6912659c33ff4153b8e96b9536a80d87_X * Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend.x + Triplanar_6912659c33ff4153b8e96b9536a80d87_Y * Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend.y + Triplanar_6912659c33ff4153b8e96b9536a80d87_Z * Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend.z;
            float4 _Property_18c38c82ce484588aae575348e2394c3_Out_0_Vector4 = _ColorizeTex;
            float4 _Multiply_c5de1c39b6c14b2fb5c0549193a1032a_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Triplanar_6912659c33ff4153b8e96b9536a80d87_Out_0_Vector4, _Property_18c38c82ce484588aae575348e2394c3_Out_0_Vector4, _Multiply_c5de1c39b6c14b2fb5c0549193a1032a_Out_2_Vector4);
            UnityTexture2D _Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DetailsTexture);
            float _Property_87787443c0d94107a973afa19bec8473_Out_0_Float = _DetailsScale;
            float3 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_UV = IN.AbsoluteWorldSpacePosition * _Property_87787443c0d94107a973afa19bec8473_Out_0_Float;
            float3 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(float(1), floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend /= dot(Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend, 1.0);
            float4 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_X = SAMPLE_TEXTURE2D(_Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.tex, _Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.samplerstate, Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_UV.zy);
            float4 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Y = SAMPLE_TEXTURE2D(_Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.tex, _Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.samplerstate, Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_UV.xz);
            float4 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Z = SAMPLE_TEXTURE2D(_Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.tex, _Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.samplerstate, Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_UV.xy);
            float4 _Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Out_0_Vector4 = Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_X * Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend.x + Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Y * Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend.y + Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Z * Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend.z;
            float4 _Property_ae5ff527366a48808a6c451cb6350985_Out_0_Vector4 = _ColorizeDetails;
            float4 _Multiply_a74ae3377777416eab0f1e3d475bec58_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Out_0_Vector4, _Property_ae5ff527366a48808a6c451cb6350985_Out_0_Vector4, _Multiply_a74ae3377777416eab0f1e3d475bec58_Out_2_Vector4);
            float _Property_103b8d9988de43a59179d4baeb8b0baf_Out_0_Boolean = _InverseNoise;
            float _Property_e79fa408fbb84200843252e2d841c82a_Out_0_Float = _Warp;
            Bindings_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7;
            _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            float2 _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7_OutVector4_1_Vector2;
            SG_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float(_Property_e79fa408fbb84200843252e2d841c82a_Out_0_Float, float(1), _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7, _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7_OutVector4_1_Vector2);
            float2 _Property_c57582720349407ab19944989357a0cd_Out_0_Vector2 = _MappingScale;
            float2 _Multiply_81ed9f7c04d24298a5b698d703158e71_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7_OutVector4_1_Vector2, _Property_c57582720349407ab19944989357a0cd_Out_0_Vector2, _Multiply_81ed9f7c04d24298a5b698d703158e71_Out_2_Vector2);
            float _Property_1fdc57dd6a5a4f01bf7fbcd6bcee8646_Out_0_Float = _NoiseScale;
            float _SimpleNoise_315660502c104297b4122c3a92156900_Out_2_Float;
            Unity_SimpleNoise_Deterministic_float(_Multiply_81ed9f7c04d24298a5b698d703158e71_Out_2_Vector2, _Property_1fdc57dd6a5a4f01bf7fbcd6bcee8646_Out_0_Float, _SimpleNoise_315660502c104297b4122c3a92156900_Out_2_Float);
            float _Property_b730cc2902054cc38644d3877b209dc0_Out_0_Float = _NoiseContrast;
            float3 _Contrast_0e2a0f87675e4ecd8dc0dea7e999eb5a_Out_2_Vector3;
            Unity_Contrast_float((_SimpleNoise_315660502c104297b4122c3a92156900_Out_2_Float.xxx), _Property_b730cc2902054cc38644d3877b209dc0_Out_0_Float, _Contrast_0e2a0f87675e4ecd8dc0dea7e999eb5a_Out_2_Vector3);
            float3 _OneMinus_e67c38c9496b40fca9bd0aba02acbc00_Out_1_Vector3;
            Unity_OneMinus_float3(_Contrast_0e2a0f87675e4ecd8dc0dea7e999eb5a_Out_2_Vector3, _OneMinus_e67c38c9496b40fca9bd0aba02acbc00_Out_1_Vector3);
            float3 _Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3;
            Unity_Branch_float3(_Property_103b8d9988de43a59179d4baeb8b0baf_Out_0_Boolean, _OneMinus_e67c38c9496b40fca9bd0aba02acbc00_Out_1_Vector3, _Contrast_0e2a0f87675e4ecd8dc0dea7e999eb5a_Out_2_Vector3, _Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3);
            float3 _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_a74ae3377777416eab0f1e3d475bec58_Out_2_Vector4.xyz), _Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3, _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3);
            float _Split_e3def6f5de904b7abcb9f99adbcf03bf_R_1_Float = _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3[0];
            float _Split_e3def6f5de904b7abcb9f99adbcf03bf_G_2_Float = _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3[1];
            float _Split_e3def6f5de904b7abcb9f99adbcf03bf_B_3_Float = _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3[2];
            float _Split_e3def6f5de904b7abcb9f99adbcf03bf_A_4_Float = 0;
            float4 _Combine_b07dbf262c614725ad02db620dc63383_RGBA_4_Vector4;
            float3 _Combine_b07dbf262c614725ad02db620dc63383_RGB_5_Vector3;
            float2 _Combine_b07dbf262c614725ad02db620dc63383_RG_6_Vector2;
            Unity_Combine_float(_Split_e3def6f5de904b7abcb9f99adbcf03bf_R_1_Float, _Split_e3def6f5de904b7abcb9f99adbcf03bf_G_2_Float, _Split_e3def6f5de904b7abcb9f99adbcf03bf_B_3_Float, (_Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3).x, _Combine_b07dbf262c614725ad02db620dc63383_RGBA_4_Vector4, _Combine_b07dbf262c614725ad02db620dc63383_RGB_5_Vector3, _Combine_b07dbf262c614725ad02db620dc63383_RG_6_Vector2);
            float _Property_d94c916e4a654bd8b2212943c211d505_Out_0_Float = _DetailsOpacity;
            float3 _Multiply_d793936fdb3742e2826551d9a4de8473_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Property_d94c916e4a654bd8b2212943c211d505_Out_0_Float.xxx), _Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3, _Multiply_d793936fdb3742e2826551d9a4de8473_Out_2_Vector3);
            float4 _Blend_17cb2777455e45488da86992a6e9df1e_Out_2_Vector4;
            Unity_Blend_Overwrite_float4(_Multiply_c5de1c39b6c14b2fb5c0549193a1032a_Out_2_Vector4, _Combine_b07dbf262c614725ad02db620dc63383_RGBA_4_Vector4, _Blend_17cb2777455e45488da86992a6e9df1e_Out_2_Vector4, (_Multiply_d793936fdb3742e2826551d9a4de8473_Out_2_Vector3).x);
            float4 _Clamp_371ece0e403c4c8ca3c7e7d0d280820c_Out_3_Vector4;
            Unity_Clamp_float4(_Blend_17cb2777455e45488da86992a6e9df1e_Out_2_Vector4, float4(0, 0, 0, 0), float4(255, 255, 255, 1), _Clamp_371ece0e403c4c8ca3c7e7d0d280820c_Out_3_Vector4);
            float4 _Property_002c86b3f7f54c6591c2e6b576945e9c_Out_0_Vector4 = _Emission;
            float3 _ReplaceColor_bcfc10bda5ab41f2b1d8ad10eff8a579_Out_4_Vector3;
            Unity_ReplaceColor_float((_Blend_17cb2777455e45488da86992a6e9df1e_Out_2_Vector4.xyz), IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0)), IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0)), float(0.57), _ReplaceColor_bcfc10bda5ab41f2b1d8ad10eff8a579_Out_4_Vector3, float(0.23));
            float3 _Multiply_1d2fc25e75fa48769e1693e7c94602cb_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Property_002c86b3f7f54c6591c2e6b576945e9c_Out_0_Vector4.xyz), _ReplaceColor_bcfc10bda5ab41f2b1d8ad10eff8a579_Out_4_Vector3, _Multiply_1d2fc25e75fa48769e1693e7c94602cb_Out_2_Vector3);
            float3 _Clamp_d5edb04a3199431fb7d6befeb220a57e_Out_3_Vector3;
            Unity_Clamp_float3(_Multiply_1d2fc25e75fa48769e1693e7c94602cb_Out_2_Vector3, float3(0, 0, 0), float3(255, 255, 255), _Clamp_d5edb04a3199431fb7d6befeb220a57e_Out_3_Vector3);
            float3 _Saturation_64be0b6afe8d4d15b228716a619e8397_Out_2_Vector3;
            Unity_Saturation_float((_Blend_17cb2777455e45488da86992a6e9df1e_Out_2_Vector4.xyz), float(0), _Saturation_64be0b6afe8d4d15b228716a619e8397_Out_2_Vector3);
            float _Property_370cf490ec664cb7a7e74d2b93a0aa49_Out_0_Float = _Smoothness;
            float3 _Multiply_7e28d2eaaab94cbb952418124f98ec40_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Saturation_64be0b6afe8d4d15b228716a619e8397_Out_2_Vector3, (_Property_370cf490ec664cb7a7e74d2b93a0aa49_Out_0_Float.xxx), _Multiply_7e28d2eaaab94cbb952418124f98ec40_Out_2_Vector3);
            surface.BaseColor = (_Clamp_371ece0e403c4c8ca3c7e7d0d280820c_Out_3_Vector4.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = _Clamp_d5edb04a3199431fb7d6befeb220a57e_Out_3_Vector3;
            surface.Metallic = float(0);
            surface.Smoothness = (_Multiply_7e28d2eaaab94cbb952418124f98ec40_Out_2_Vector3).x;
            surface.Occlusion = float(1);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion : INTERP3;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP4;
            #endif
             float4 tangentWS : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor_TexelSize;
        float _TextureScale;
        float _Smoothness;
        float4 _Emission;
        float4 _DetailsTexture_TexelSize;
        float _NoiseScale;
        float _NoiseContrast;
        float _InverseNoise;
        float _DetailsOpacity;
        float _Warp;
        float _DetailsScale;
        float2 _MappingScale;
        float4 _ColorizeTex;
        float4 _ColorizeDetails;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColor);
        SAMPLER(sampler_BaseColor);
        TEXTURE2D(_DetailsTexture);
        SAMPLER(sampler_DetailsTexture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // unity-custom-func-begin
        void TriplanarUVmapping_float(float3 Position, float Tile, float3 Normal, float Blend, out float2 Out){
        float3 Node_UV = Position * Tile;
        
        float3 Node_Blend = pow(abs(Normal), Blend);
        
        Node_Blend /= (Node_Blend.x + Node_Blend.y + Node_Blend.z ).xxx;
        
        float2 Node_X = Node_UV.zy;
        
        float2 Node_Y = Node_UV.xz;
        
        float2 Node_Z = Node_UV.xy;
        
        Out = Node_X * Node_Blend.x + Node_Y * Node_Blend.y + Node_Z * Node_Blend.z;
        
        }
        // unity-custom-func-end
        
        struct Bindings_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float
        {
        float3 AbsoluteWorldSpacePosition;
        };
        
        void SG_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float(float _Warp, float _Tile, Bindings_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float IN, out float2 Out_Vector4_1)
        {
        float _Property_a4bdf31d4c204e49aa4073d18397661a_Out_0_Float = _Tile;
        float _Property_0ff2401d4526446a8967fd71528a7620_Out_0_Float = _Warp;
        float2 _TriplanarUVmappingCustomFunction_4a6ec34197d14ff9b595de762184b1e3_Out_4_Vector2;
        TriplanarUVmapping_float(IN.AbsoluteWorldSpacePosition, _Property_a4bdf31d4c204e49aa4073d18397661a_Out_0_Float, IN.AbsoluteWorldSpacePosition, _Property_0ff2401d4526446a8967fd71528a7620_Out_0_Float, _TriplanarUVmappingCustomFunction_4a6ec34197d14ff9b595de762184b1e3_Out_4_Vector2);
        Out_Vector4_1 = _TriplanarUVmappingCustomFunction_4a6ec34197d14ff9b595de762184b1e3_Out_4_Vector2;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        float Unity_SimpleNoise_ValueNoise_Deterministic_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_Tchou_2_1_float(c0, r0);
            float r1; Hash_Tchou_2_1_float(c1, r1);
            float r2; Hash_Tchou_2_1_float(c2, r2);
            float r3; Hash_Tchou_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_Deterministic_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Contrast_float(float3 In, float Contrast, out float3 Out)
        {
            float midpoint = pow(0.5, 2.2);
            Out =  (In - midpoint) * Contrast + midpoint;
        }
        
        void Unity_OneMinus_float3(float3 In, out float3 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Blend_Overwrite_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            Out = lerp(Base, Blend, Opacity);
        }
        
        void Unity_Clamp_float4(float4 In, float4 Min, float4 Max, out float4 Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_ReplaceColor_float(float3 In, float3 From, float3 To, float Range, out float3 Out, float Fuzziness)
        {
            float Distance = distance(From, In);
            Out = lerp(To, In, saturate((Distance - Range) / max(Fuzziness, 1e-5f)));
        }
        
        void Unity_Clamp_float3(float3 In, float3 Min, float3 Max, out float3 Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Saturation_float(float3 In, float Saturation, out float3 Out)
        {
            float luma = dot(In, float3(0.2126729, 0.7151522, 0.0721750));
            Out =  luma.xxx + Saturation.xxx * (In - luma.xxx);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseColor);
            float _Property_7c0fe046032c4123aa0030efd337df6e_Out_0_Float = _TextureScale;
            float3 Triplanar_6912659c33ff4153b8e96b9536a80d87_UV = IN.AbsoluteWorldSpacePosition * _Property_7c0fe046032c4123aa0030efd337df6e_Out_0_Float;
            float3 Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(float(1), floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend /= dot(Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend, 1.0);
            float4 Triplanar_6912659c33ff4153b8e96b9536a80d87_X = SAMPLE_TEXTURE2D(_Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.tex, _Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.samplerstate, Triplanar_6912659c33ff4153b8e96b9536a80d87_UV.zy);
            float4 Triplanar_6912659c33ff4153b8e96b9536a80d87_Y = SAMPLE_TEXTURE2D(_Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.tex, _Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.samplerstate, Triplanar_6912659c33ff4153b8e96b9536a80d87_UV.xz);
            float4 Triplanar_6912659c33ff4153b8e96b9536a80d87_Z = SAMPLE_TEXTURE2D(_Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.tex, _Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.samplerstate, Triplanar_6912659c33ff4153b8e96b9536a80d87_UV.xy);
            float4 _Triplanar_6912659c33ff4153b8e96b9536a80d87_Out_0_Vector4 = Triplanar_6912659c33ff4153b8e96b9536a80d87_X * Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend.x + Triplanar_6912659c33ff4153b8e96b9536a80d87_Y * Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend.y + Triplanar_6912659c33ff4153b8e96b9536a80d87_Z * Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend.z;
            float4 _Property_18c38c82ce484588aae575348e2394c3_Out_0_Vector4 = _ColorizeTex;
            float4 _Multiply_c5de1c39b6c14b2fb5c0549193a1032a_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Triplanar_6912659c33ff4153b8e96b9536a80d87_Out_0_Vector4, _Property_18c38c82ce484588aae575348e2394c3_Out_0_Vector4, _Multiply_c5de1c39b6c14b2fb5c0549193a1032a_Out_2_Vector4);
            UnityTexture2D _Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DetailsTexture);
            float _Property_87787443c0d94107a973afa19bec8473_Out_0_Float = _DetailsScale;
            float3 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_UV = IN.AbsoluteWorldSpacePosition * _Property_87787443c0d94107a973afa19bec8473_Out_0_Float;
            float3 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(float(1), floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend /= dot(Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend, 1.0);
            float4 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_X = SAMPLE_TEXTURE2D(_Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.tex, _Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.samplerstate, Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_UV.zy);
            float4 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Y = SAMPLE_TEXTURE2D(_Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.tex, _Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.samplerstate, Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_UV.xz);
            float4 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Z = SAMPLE_TEXTURE2D(_Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.tex, _Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.samplerstate, Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_UV.xy);
            float4 _Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Out_0_Vector4 = Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_X * Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend.x + Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Y * Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend.y + Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Z * Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend.z;
            float4 _Property_ae5ff527366a48808a6c451cb6350985_Out_0_Vector4 = _ColorizeDetails;
            float4 _Multiply_a74ae3377777416eab0f1e3d475bec58_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Out_0_Vector4, _Property_ae5ff527366a48808a6c451cb6350985_Out_0_Vector4, _Multiply_a74ae3377777416eab0f1e3d475bec58_Out_2_Vector4);
            float _Property_103b8d9988de43a59179d4baeb8b0baf_Out_0_Boolean = _InverseNoise;
            float _Property_e79fa408fbb84200843252e2d841c82a_Out_0_Float = _Warp;
            Bindings_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7;
            _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            float2 _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7_OutVector4_1_Vector2;
            SG_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float(_Property_e79fa408fbb84200843252e2d841c82a_Out_0_Float, float(1), _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7, _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7_OutVector4_1_Vector2);
            float2 _Property_c57582720349407ab19944989357a0cd_Out_0_Vector2 = _MappingScale;
            float2 _Multiply_81ed9f7c04d24298a5b698d703158e71_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7_OutVector4_1_Vector2, _Property_c57582720349407ab19944989357a0cd_Out_0_Vector2, _Multiply_81ed9f7c04d24298a5b698d703158e71_Out_2_Vector2);
            float _Property_1fdc57dd6a5a4f01bf7fbcd6bcee8646_Out_0_Float = _NoiseScale;
            float _SimpleNoise_315660502c104297b4122c3a92156900_Out_2_Float;
            Unity_SimpleNoise_Deterministic_float(_Multiply_81ed9f7c04d24298a5b698d703158e71_Out_2_Vector2, _Property_1fdc57dd6a5a4f01bf7fbcd6bcee8646_Out_0_Float, _SimpleNoise_315660502c104297b4122c3a92156900_Out_2_Float);
            float _Property_b730cc2902054cc38644d3877b209dc0_Out_0_Float = _NoiseContrast;
            float3 _Contrast_0e2a0f87675e4ecd8dc0dea7e999eb5a_Out_2_Vector3;
            Unity_Contrast_float((_SimpleNoise_315660502c104297b4122c3a92156900_Out_2_Float.xxx), _Property_b730cc2902054cc38644d3877b209dc0_Out_0_Float, _Contrast_0e2a0f87675e4ecd8dc0dea7e999eb5a_Out_2_Vector3);
            float3 _OneMinus_e67c38c9496b40fca9bd0aba02acbc00_Out_1_Vector3;
            Unity_OneMinus_float3(_Contrast_0e2a0f87675e4ecd8dc0dea7e999eb5a_Out_2_Vector3, _OneMinus_e67c38c9496b40fca9bd0aba02acbc00_Out_1_Vector3);
            float3 _Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3;
            Unity_Branch_float3(_Property_103b8d9988de43a59179d4baeb8b0baf_Out_0_Boolean, _OneMinus_e67c38c9496b40fca9bd0aba02acbc00_Out_1_Vector3, _Contrast_0e2a0f87675e4ecd8dc0dea7e999eb5a_Out_2_Vector3, _Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3);
            float3 _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_a74ae3377777416eab0f1e3d475bec58_Out_2_Vector4.xyz), _Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3, _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3);
            float _Split_e3def6f5de904b7abcb9f99adbcf03bf_R_1_Float = _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3[0];
            float _Split_e3def6f5de904b7abcb9f99adbcf03bf_G_2_Float = _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3[1];
            float _Split_e3def6f5de904b7abcb9f99adbcf03bf_B_3_Float = _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3[2];
            float _Split_e3def6f5de904b7abcb9f99adbcf03bf_A_4_Float = 0;
            float4 _Combine_b07dbf262c614725ad02db620dc63383_RGBA_4_Vector4;
            float3 _Combine_b07dbf262c614725ad02db620dc63383_RGB_5_Vector3;
            float2 _Combine_b07dbf262c614725ad02db620dc63383_RG_6_Vector2;
            Unity_Combine_float(_Split_e3def6f5de904b7abcb9f99adbcf03bf_R_1_Float, _Split_e3def6f5de904b7abcb9f99adbcf03bf_G_2_Float, _Split_e3def6f5de904b7abcb9f99adbcf03bf_B_3_Float, (_Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3).x, _Combine_b07dbf262c614725ad02db620dc63383_RGBA_4_Vector4, _Combine_b07dbf262c614725ad02db620dc63383_RGB_5_Vector3, _Combine_b07dbf262c614725ad02db620dc63383_RG_6_Vector2);
            float _Property_d94c916e4a654bd8b2212943c211d505_Out_0_Float = _DetailsOpacity;
            float3 _Multiply_d793936fdb3742e2826551d9a4de8473_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Property_d94c916e4a654bd8b2212943c211d505_Out_0_Float.xxx), _Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3, _Multiply_d793936fdb3742e2826551d9a4de8473_Out_2_Vector3);
            float4 _Blend_17cb2777455e45488da86992a6e9df1e_Out_2_Vector4;
            Unity_Blend_Overwrite_float4(_Multiply_c5de1c39b6c14b2fb5c0549193a1032a_Out_2_Vector4, _Combine_b07dbf262c614725ad02db620dc63383_RGBA_4_Vector4, _Blend_17cb2777455e45488da86992a6e9df1e_Out_2_Vector4, (_Multiply_d793936fdb3742e2826551d9a4de8473_Out_2_Vector3).x);
            float4 _Clamp_371ece0e403c4c8ca3c7e7d0d280820c_Out_3_Vector4;
            Unity_Clamp_float4(_Blend_17cb2777455e45488da86992a6e9df1e_Out_2_Vector4, float4(0, 0, 0, 0), float4(255, 255, 255, 1), _Clamp_371ece0e403c4c8ca3c7e7d0d280820c_Out_3_Vector4);
            float4 _Property_002c86b3f7f54c6591c2e6b576945e9c_Out_0_Vector4 = _Emission;
            float3 _ReplaceColor_bcfc10bda5ab41f2b1d8ad10eff8a579_Out_4_Vector3;
            Unity_ReplaceColor_float((_Blend_17cb2777455e45488da86992a6e9df1e_Out_2_Vector4.xyz), IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0)), IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0)), float(0.57), _ReplaceColor_bcfc10bda5ab41f2b1d8ad10eff8a579_Out_4_Vector3, float(0.23));
            float3 _Multiply_1d2fc25e75fa48769e1693e7c94602cb_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Property_002c86b3f7f54c6591c2e6b576945e9c_Out_0_Vector4.xyz), _ReplaceColor_bcfc10bda5ab41f2b1d8ad10eff8a579_Out_4_Vector3, _Multiply_1d2fc25e75fa48769e1693e7c94602cb_Out_2_Vector3);
            float3 _Clamp_d5edb04a3199431fb7d6befeb220a57e_Out_3_Vector3;
            Unity_Clamp_float3(_Multiply_1d2fc25e75fa48769e1693e7c94602cb_Out_2_Vector3, float3(0, 0, 0), float3(255, 255, 255), _Clamp_d5edb04a3199431fb7d6befeb220a57e_Out_3_Vector3);
            float3 _Saturation_64be0b6afe8d4d15b228716a619e8397_Out_2_Vector3;
            Unity_Saturation_float((_Blend_17cb2777455e45488da86992a6e9df1e_Out_2_Vector4.xyz), float(0), _Saturation_64be0b6afe8d4d15b228716a619e8397_Out_2_Vector3);
            float _Property_370cf490ec664cb7a7e74d2b93a0aa49_Out_0_Float = _Smoothness;
            float3 _Multiply_7e28d2eaaab94cbb952418124f98ec40_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Saturation_64be0b6afe8d4d15b228716a619e8397_Out_2_Vector3, (_Property_370cf490ec664cb7a7e74d2b93a0aa49_Out_0_Float.xxx), _Multiply_7e28d2eaaab94cbb952418124f98ec40_Out_2_Vector3);
            surface.BaseColor = (_Clamp_371ece0e403c4c8ca3c7e7d0d280820c_Out_3_Vector4.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = _Clamp_d5edb04a3199431fb7d6befeb220a57e_Out_3_Vector3;
            surface.Metallic = float(0);
            surface.Smoothness = (_Multiply_7e28d2eaaab94cbb952418124f98ec40_Out_2_Vector3).x;
            surface.Occlusion = float(1);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor_TexelSize;
        float _TextureScale;
        float _Smoothness;
        float4 _Emission;
        float4 _DetailsTexture_TexelSize;
        float _NoiseScale;
        float _NoiseContrast;
        float _InverseNoise;
        float _DetailsOpacity;
        float _Warp;
        float _DetailsScale;
        float2 _MappingScale;
        float4 _ColorizeTex;
        float4 _ColorizeDetails;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColor);
        SAMPLER(sampler_BaseColor);
        TEXTURE2D(_DetailsTexture);
        SAMPLER(sampler_DetailsTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        // GraphFunctions: <None>
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "MotionVectors"
            Tags
            {
                "LightMode" = "MotionVectors"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask RG
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.5
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_MOTION_VECTORS
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor_TexelSize;
        float _TextureScale;
        float _Smoothness;
        float4 _Emission;
        float4 _DetailsTexture_TexelSize;
        float _NoiseScale;
        float _NoiseContrast;
        float _InverseNoise;
        float _DetailsOpacity;
        float _Warp;
        float _DetailsScale;
        float2 _MappingScale;
        float4 _ColorizeTex;
        float4 _ColorizeDetails;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColor);
        SAMPLER(sampler_BaseColor);
        TEXTURE2D(_DetailsTexture);
        SAMPLER(sampler_DetailsTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        // GraphFunctions: <None>
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/MotionVectorPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask R
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor_TexelSize;
        float _TextureScale;
        float _Smoothness;
        float4 _Emission;
        float4 _DetailsTexture_TexelSize;
        float _NoiseScale;
        float _NoiseContrast;
        float _InverseNoise;
        float _DetailsOpacity;
        float _Warp;
        float _DetailsScale;
        float2 _MappingScale;
        float4 _ColorizeTex;
        float4 _ColorizeDetails;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColor);
        SAMPLER(sampler_BaseColor);
        TEXTURE2D(_DetailsTexture);
        SAMPLER(sampler_DetailsTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        // GraphFunctions: <None>
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor_TexelSize;
        float _TextureScale;
        float _Smoothness;
        float4 _Emission;
        float4 _DetailsTexture_TexelSize;
        float _NoiseScale;
        float _NoiseContrast;
        float _InverseNoise;
        float _DetailsOpacity;
        float _Warp;
        float _DetailsScale;
        float2 _MappingScale;
        float4 _ColorizeTex;
        float4 _ColorizeDetails;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColor);
        SAMPLER(sampler_BaseColor);
        TEXTURE2D(_DetailsTexture);
        SAMPLER(sampler_DetailsTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        // GraphFunctions: <None>
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            surface.NormalTS = IN.TangentSpaceNormal;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_INSTANCEID
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 texCoord2 : INTERP2;
             float3 positionWS : INTERP3;
             float3 normalWS : INTERP4;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.texCoord2.xyzw = input.texCoord2;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor_TexelSize;
        float _TextureScale;
        float _Smoothness;
        float4 _Emission;
        float4 _DetailsTexture_TexelSize;
        float _NoiseScale;
        float _NoiseContrast;
        float _InverseNoise;
        float _DetailsOpacity;
        float _Warp;
        float _DetailsScale;
        float2 _MappingScale;
        float4 _ColorizeTex;
        float4 _ColorizeDetails;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColor);
        SAMPLER(sampler_BaseColor);
        TEXTURE2D(_DetailsTexture);
        SAMPLER(sampler_DetailsTexture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // unity-custom-func-begin
        void TriplanarUVmapping_float(float3 Position, float Tile, float3 Normal, float Blend, out float2 Out){
        float3 Node_UV = Position * Tile;
        
        float3 Node_Blend = pow(abs(Normal), Blend);
        
        Node_Blend /= (Node_Blend.x + Node_Blend.y + Node_Blend.z ).xxx;
        
        float2 Node_X = Node_UV.zy;
        
        float2 Node_Y = Node_UV.xz;
        
        float2 Node_Z = Node_UV.xy;
        
        Out = Node_X * Node_Blend.x + Node_Y * Node_Blend.y + Node_Z * Node_Blend.z;
        
        }
        // unity-custom-func-end
        
        struct Bindings_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float
        {
        float3 AbsoluteWorldSpacePosition;
        };
        
        void SG_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float(float _Warp, float _Tile, Bindings_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float IN, out float2 Out_Vector4_1)
        {
        float _Property_a4bdf31d4c204e49aa4073d18397661a_Out_0_Float = _Tile;
        float _Property_0ff2401d4526446a8967fd71528a7620_Out_0_Float = _Warp;
        float2 _TriplanarUVmappingCustomFunction_4a6ec34197d14ff9b595de762184b1e3_Out_4_Vector2;
        TriplanarUVmapping_float(IN.AbsoluteWorldSpacePosition, _Property_a4bdf31d4c204e49aa4073d18397661a_Out_0_Float, IN.AbsoluteWorldSpacePosition, _Property_0ff2401d4526446a8967fd71528a7620_Out_0_Float, _TriplanarUVmappingCustomFunction_4a6ec34197d14ff9b595de762184b1e3_Out_4_Vector2);
        Out_Vector4_1 = _TriplanarUVmappingCustomFunction_4a6ec34197d14ff9b595de762184b1e3_Out_4_Vector2;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        float Unity_SimpleNoise_ValueNoise_Deterministic_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_Tchou_2_1_float(c0, r0);
            float r1; Hash_Tchou_2_1_float(c1, r1);
            float r2; Hash_Tchou_2_1_float(c2, r2);
            float r3; Hash_Tchou_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_Deterministic_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Contrast_float(float3 In, float Contrast, out float3 Out)
        {
            float midpoint = pow(0.5, 2.2);
            Out =  (In - midpoint) * Contrast + midpoint;
        }
        
        void Unity_OneMinus_float3(float3 In, out float3 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Blend_Overwrite_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            Out = lerp(Base, Blend, Opacity);
        }
        
        void Unity_Clamp_float4(float4 In, float4 Min, float4 Max, out float4 Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_ReplaceColor_float(float3 In, float3 From, float3 To, float Range, out float3 Out, float Fuzziness)
        {
            float Distance = distance(From, In);
            Out = lerp(To, In, saturate((Distance - Range) / max(Fuzziness, 1e-5f)));
        }
        
        void Unity_Clamp_float3(float3 In, float3 Min, float3 Max, out float3 Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseColor);
            float _Property_7c0fe046032c4123aa0030efd337df6e_Out_0_Float = _TextureScale;
            float3 Triplanar_6912659c33ff4153b8e96b9536a80d87_UV = IN.AbsoluteWorldSpacePosition * _Property_7c0fe046032c4123aa0030efd337df6e_Out_0_Float;
            float3 Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(float(1), floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend /= dot(Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend, 1.0);
            float4 Triplanar_6912659c33ff4153b8e96b9536a80d87_X = SAMPLE_TEXTURE2D(_Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.tex, _Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.samplerstate, Triplanar_6912659c33ff4153b8e96b9536a80d87_UV.zy);
            float4 Triplanar_6912659c33ff4153b8e96b9536a80d87_Y = SAMPLE_TEXTURE2D(_Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.tex, _Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.samplerstate, Triplanar_6912659c33ff4153b8e96b9536a80d87_UV.xz);
            float4 Triplanar_6912659c33ff4153b8e96b9536a80d87_Z = SAMPLE_TEXTURE2D(_Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.tex, _Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.samplerstate, Triplanar_6912659c33ff4153b8e96b9536a80d87_UV.xy);
            float4 _Triplanar_6912659c33ff4153b8e96b9536a80d87_Out_0_Vector4 = Triplanar_6912659c33ff4153b8e96b9536a80d87_X * Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend.x + Triplanar_6912659c33ff4153b8e96b9536a80d87_Y * Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend.y + Triplanar_6912659c33ff4153b8e96b9536a80d87_Z * Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend.z;
            float4 _Property_18c38c82ce484588aae575348e2394c3_Out_0_Vector4 = _ColorizeTex;
            float4 _Multiply_c5de1c39b6c14b2fb5c0549193a1032a_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Triplanar_6912659c33ff4153b8e96b9536a80d87_Out_0_Vector4, _Property_18c38c82ce484588aae575348e2394c3_Out_0_Vector4, _Multiply_c5de1c39b6c14b2fb5c0549193a1032a_Out_2_Vector4);
            UnityTexture2D _Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DetailsTexture);
            float _Property_87787443c0d94107a973afa19bec8473_Out_0_Float = _DetailsScale;
            float3 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_UV = IN.AbsoluteWorldSpacePosition * _Property_87787443c0d94107a973afa19bec8473_Out_0_Float;
            float3 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(float(1), floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend /= dot(Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend, 1.0);
            float4 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_X = SAMPLE_TEXTURE2D(_Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.tex, _Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.samplerstate, Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_UV.zy);
            float4 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Y = SAMPLE_TEXTURE2D(_Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.tex, _Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.samplerstate, Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_UV.xz);
            float4 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Z = SAMPLE_TEXTURE2D(_Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.tex, _Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.samplerstate, Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_UV.xy);
            float4 _Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Out_0_Vector4 = Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_X * Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend.x + Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Y * Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend.y + Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Z * Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend.z;
            float4 _Property_ae5ff527366a48808a6c451cb6350985_Out_0_Vector4 = _ColorizeDetails;
            float4 _Multiply_a74ae3377777416eab0f1e3d475bec58_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Out_0_Vector4, _Property_ae5ff527366a48808a6c451cb6350985_Out_0_Vector4, _Multiply_a74ae3377777416eab0f1e3d475bec58_Out_2_Vector4);
            float _Property_103b8d9988de43a59179d4baeb8b0baf_Out_0_Boolean = _InverseNoise;
            float _Property_e79fa408fbb84200843252e2d841c82a_Out_0_Float = _Warp;
            Bindings_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7;
            _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            float2 _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7_OutVector4_1_Vector2;
            SG_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float(_Property_e79fa408fbb84200843252e2d841c82a_Out_0_Float, float(1), _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7, _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7_OutVector4_1_Vector2);
            float2 _Property_c57582720349407ab19944989357a0cd_Out_0_Vector2 = _MappingScale;
            float2 _Multiply_81ed9f7c04d24298a5b698d703158e71_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7_OutVector4_1_Vector2, _Property_c57582720349407ab19944989357a0cd_Out_0_Vector2, _Multiply_81ed9f7c04d24298a5b698d703158e71_Out_2_Vector2);
            float _Property_1fdc57dd6a5a4f01bf7fbcd6bcee8646_Out_0_Float = _NoiseScale;
            float _SimpleNoise_315660502c104297b4122c3a92156900_Out_2_Float;
            Unity_SimpleNoise_Deterministic_float(_Multiply_81ed9f7c04d24298a5b698d703158e71_Out_2_Vector2, _Property_1fdc57dd6a5a4f01bf7fbcd6bcee8646_Out_0_Float, _SimpleNoise_315660502c104297b4122c3a92156900_Out_2_Float);
            float _Property_b730cc2902054cc38644d3877b209dc0_Out_0_Float = _NoiseContrast;
            float3 _Contrast_0e2a0f87675e4ecd8dc0dea7e999eb5a_Out_2_Vector3;
            Unity_Contrast_float((_SimpleNoise_315660502c104297b4122c3a92156900_Out_2_Float.xxx), _Property_b730cc2902054cc38644d3877b209dc0_Out_0_Float, _Contrast_0e2a0f87675e4ecd8dc0dea7e999eb5a_Out_2_Vector3);
            float3 _OneMinus_e67c38c9496b40fca9bd0aba02acbc00_Out_1_Vector3;
            Unity_OneMinus_float3(_Contrast_0e2a0f87675e4ecd8dc0dea7e999eb5a_Out_2_Vector3, _OneMinus_e67c38c9496b40fca9bd0aba02acbc00_Out_1_Vector3);
            float3 _Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3;
            Unity_Branch_float3(_Property_103b8d9988de43a59179d4baeb8b0baf_Out_0_Boolean, _OneMinus_e67c38c9496b40fca9bd0aba02acbc00_Out_1_Vector3, _Contrast_0e2a0f87675e4ecd8dc0dea7e999eb5a_Out_2_Vector3, _Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3);
            float3 _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_a74ae3377777416eab0f1e3d475bec58_Out_2_Vector4.xyz), _Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3, _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3);
            float _Split_e3def6f5de904b7abcb9f99adbcf03bf_R_1_Float = _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3[0];
            float _Split_e3def6f5de904b7abcb9f99adbcf03bf_G_2_Float = _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3[1];
            float _Split_e3def6f5de904b7abcb9f99adbcf03bf_B_3_Float = _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3[2];
            float _Split_e3def6f5de904b7abcb9f99adbcf03bf_A_4_Float = 0;
            float4 _Combine_b07dbf262c614725ad02db620dc63383_RGBA_4_Vector4;
            float3 _Combine_b07dbf262c614725ad02db620dc63383_RGB_5_Vector3;
            float2 _Combine_b07dbf262c614725ad02db620dc63383_RG_6_Vector2;
            Unity_Combine_float(_Split_e3def6f5de904b7abcb9f99adbcf03bf_R_1_Float, _Split_e3def6f5de904b7abcb9f99adbcf03bf_G_2_Float, _Split_e3def6f5de904b7abcb9f99adbcf03bf_B_3_Float, (_Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3).x, _Combine_b07dbf262c614725ad02db620dc63383_RGBA_4_Vector4, _Combine_b07dbf262c614725ad02db620dc63383_RGB_5_Vector3, _Combine_b07dbf262c614725ad02db620dc63383_RG_6_Vector2);
            float _Property_d94c916e4a654bd8b2212943c211d505_Out_0_Float = _DetailsOpacity;
            float3 _Multiply_d793936fdb3742e2826551d9a4de8473_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Property_d94c916e4a654bd8b2212943c211d505_Out_0_Float.xxx), _Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3, _Multiply_d793936fdb3742e2826551d9a4de8473_Out_2_Vector3);
            float4 _Blend_17cb2777455e45488da86992a6e9df1e_Out_2_Vector4;
            Unity_Blend_Overwrite_float4(_Multiply_c5de1c39b6c14b2fb5c0549193a1032a_Out_2_Vector4, _Combine_b07dbf262c614725ad02db620dc63383_RGBA_4_Vector4, _Blend_17cb2777455e45488da86992a6e9df1e_Out_2_Vector4, (_Multiply_d793936fdb3742e2826551d9a4de8473_Out_2_Vector3).x);
            float4 _Clamp_371ece0e403c4c8ca3c7e7d0d280820c_Out_3_Vector4;
            Unity_Clamp_float4(_Blend_17cb2777455e45488da86992a6e9df1e_Out_2_Vector4, float4(0, 0, 0, 0), float4(255, 255, 255, 1), _Clamp_371ece0e403c4c8ca3c7e7d0d280820c_Out_3_Vector4);
            float4 _Property_002c86b3f7f54c6591c2e6b576945e9c_Out_0_Vector4 = _Emission;
            float3 _ReplaceColor_bcfc10bda5ab41f2b1d8ad10eff8a579_Out_4_Vector3;
            Unity_ReplaceColor_float((_Blend_17cb2777455e45488da86992a6e9df1e_Out_2_Vector4.xyz), IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0)), IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0)), float(0.57), _ReplaceColor_bcfc10bda5ab41f2b1d8ad10eff8a579_Out_4_Vector3, float(0.23));
            float3 _Multiply_1d2fc25e75fa48769e1693e7c94602cb_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Property_002c86b3f7f54c6591c2e6b576945e9c_Out_0_Vector4.xyz), _ReplaceColor_bcfc10bda5ab41f2b1d8ad10eff8a579_Out_4_Vector3, _Multiply_1d2fc25e75fa48769e1693e7c94602cb_Out_2_Vector3);
            float3 _Clamp_d5edb04a3199431fb7d6befeb220a57e_Out_3_Vector3;
            Unity_Clamp_float3(_Multiply_1d2fc25e75fa48769e1693e7c94602cb_Out_2_Vector3, float3(0, 0, 0), float3(255, 255, 255), _Clamp_d5edb04a3199431fb7d6befeb220a57e_Out_3_Vector3);
            surface.BaseColor = (_Clamp_371ece0e403c4c8ca3c7e7d0d280820c_Out_3_Vector4.xyz);
            surface.Emission = _Clamp_d5edb04a3199431fb7d6befeb220a57e_Out_3_Vector3;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor_TexelSize;
        float _TextureScale;
        float _Smoothness;
        float4 _Emission;
        float4 _DetailsTexture_TexelSize;
        float _NoiseScale;
        float _NoiseContrast;
        float _InverseNoise;
        float _DetailsOpacity;
        float _Warp;
        float _DetailsScale;
        float2 _MappingScale;
        float4 _ColorizeTex;
        float4 _ColorizeDetails;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColor);
        SAMPLER(sampler_BaseColor);
        TEXTURE2D(_DetailsTexture);
        SAMPLER(sampler_DetailsTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        // GraphFunctions: <None>
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor_TexelSize;
        float _TextureScale;
        float _Smoothness;
        float4 _Emission;
        float4 _DetailsTexture_TexelSize;
        float _NoiseScale;
        float _NoiseContrast;
        float _InverseNoise;
        float _DetailsOpacity;
        float _Warp;
        float _DetailsScale;
        float2 _MappingScale;
        float4 _ColorizeTex;
        float4 _ColorizeDetails;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColor);
        SAMPLER(sampler_BaseColor);
        TEXTURE2D(_DetailsTexture);
        SAMPLER(sampler_DetailsTexture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // unity-custom-func-begin
        void TriplanarUVmapping_float(float3 Position, float Tile, float3 Normal, float Blend, out float2 Out){
        float3 Node_UV = Position * Tile;
        
        float3 Node_Blend = pow(abs(Normal), Blend);
        
        Node_Blend /= (Node_Blend.x + Node_Blend.y + Node_Blend.z ).xxx;
        
        float2 Node_X = Node_UV.zy;
        
        float2 Node_Y = Node_UV.xz;
        
        float2 Node_Z = Node_UV.xy;
        
        Out = Node_X * Node_Blend.x + Node_Y * Node_Blend.y + Node_Z * Node_Blend.z;
        
        }
        // unity-custom-func-end
        
        struct Bindings_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float
        {
        float3 AbsoluteWorldSpacePosition;
        };
        
        void SG_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float(float _Warp, float _Tile, Bindings_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float IN, out float2 Out_Vector4_1)
        {
        float _Property_a4bdf31d4c204e49aa4073d18397661a_Out_0_Float = _Tile;
        float _Property_0ff2401d4526446a8967fd71528a7620_Out_0_Float = _Warp;
        float2 _TriplanarUVmappingCustomFunction_4a6ec34197d14ff9b595de762184b1e3_Out_4_Vector2;
        TriplanarUVmapping_float(IN.AbsoluteWorldSpacePosition, _Property_a4bdf31d4c204e49aa4073d18397661a_Out_0_Float, IN.AbsoluteWorldSpacePosition, _Property_0ff2401d4526446a8967fd71528a7620_Out_0_Float, _TriplanarUVmappingCustomFunction_4a6ec34197d14ff9b595de762184b1e3_Out_4_Vector2);
        Out_Vector4_1 = _TriplanarUVmappingCustomFunction_4a6ec34197d14ff9b595de762184b1e3_Out_4_Vector2;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        float Unity_SimpleNoise_ValueNoise_Deterministic_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_Tchou_2_1_float(c0, r0);
            float r1; Hash_Tchou_2_1_float(c1, r1);
            float r2; Hash_Tchou_2_1_float(c2, r2);
            float r3; Hash_Tchou_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_Deterministic_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Contrast_float(float3 In, float Contrast, out float3 Out)
        {
            float midpoint = pow(0.5, 2.2);
            Out =  (In - midpoint) * Contrast + midpoint;
        }
        
        void Unity_OneMinus_float3(float3 In, out float3 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Blend_Overwrite_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            Out = lerp(Base, Blend, Opacity);
        }
        
        void Unity_Clamp_float4(float4 In, float4 Min, float4 Max, out float4 Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseColor);
            float _Property_7c0fe046032c4123aa0030efd337df6e_Out_0_Float = _TextureScale;
            float3 Triplanar_6912659c33ff4153b8e96b9536a80d87_UV = IN.AbsoluteWorldSpacePosition * _Property_7c0fe046032c4123aa0030efd337df6e_Out_0_Float;
            float3 Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(float(1), floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend /= dot(Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend, 1.0);
            float4 Triplanar_6912659c33ff4153b8e96b9536a80d87_X = SAMPLE_TEXTURE2D(_Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.tex, _Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.samplerstate, Triplanar_6912659c33ff4153b8e96b9536a80d87_UV.zy);
            float4 Triplanar_6912659c33ff4153b8e96b9536a80d87_Y = SAMPLE_TEXTURE2D(_Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.tex, _Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.samplerstate, Triplanar_6912659c33ff4153b8e96b9536a80d87_UV.xz);
            float4 Triplanar_6912659c33ff4153b8e96b9536a80d87_Z = SAMPLE_TEXTURE2D(_Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.tex, _Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.samplerstate, Triplanar_6912659c33ff4153b8e96b9536a80d87_UV.xy);
            float4 _Triplanar_6912659c33ff4153b8e96b9536a80d87_Out_0_Vector4 = Triplanar_6912659c33ff4153b8e96b9536a80d87_X * Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend.x + Triplanar_6912659c33ff4153b8e96b9536a80d87_Y * Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend.y + Triplanar_6912659c33ff4153b8e96b9536a80d87_Z * Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend.z;
            float4 _Property_18c38c82ce484588aae575348e2394c3_Out_0_Vector4 = _ColorizeTex;
            float4 _Multiply_c5de1c39b6c14b2fb5c0549193a1032a_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Triplanar_6912659c33ff4153b8e96b9536a80d87_Out_0_Vector4, _Property_18c38c82ce484588aae575348e2394c3_Out_0_Vector4, _Multiply_c5de1c39b6c14b2fb5c0549193a1032a_Out_2_Vector4);
            UnityTexture2D _Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DetailsTexture);
            float _Property_87787443c0d94107a973afa19bec8473_Out_0_Float = _DetailsScale;
            float3 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_UV = IN.AbsoluteWorldSpacePosition * _Property_87787443c0d94107a973afa19bec8473_Out_0_Float;
            float3 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(float(1), floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend /= dot(Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend, 1.0);
            float4 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_X = SAMPLE_TEXTURE2D(_Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.tex, _Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.samplerstate, Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_UV.zy);
            float4 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Y = SAMPLE_TEXTURE2D(_Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.tex, _Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.samplerstate, Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_UV.xz);
            float4 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Z = SAMPLE_TEXTURE2D(_Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.tex, _Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.samplerstate, Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_UV.xy);
            float4 _Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Out_0_Vector4 = Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_X * Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend.x + Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Y * Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend.y + Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Z * Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend.z;
            float4 _Property_ae5ff527366a48808a6c451cb6350985_Out_0_Vector4 = _ColorizeDetails;
            float4 _Multiply_a74ae3377777416eab0f1e3d475bec58_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Out_0_Vector4, _Property_ae5ff527366a48808a6c451cb6350985_Out_0_Vector4, _Multiply_a74ae3377777416eab0f1e3d475bec58_Out_2_Vector4);
            float _Property_103b8d9988de43a59179d4baeb8b0baf_Out_0_Boolean = _InverseNoise;
            float _Property_e79fa408fbb84200843252e2d841c82a_Out_0_Float = _Warp;
            Bindings_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7;
            _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            float2 _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7_OutVector4_1_Vector2;
            SG_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float(_Property_e79fa408fbb84200843252e2d841c82a_Out_0_Float, float(1), _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7, _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7_OutVector4_1_Vector2);
            float2 _Property_c57582720349407ab19944989357a0cd_Out_0_Vector2 = _MappingScale;
            float2 _Multiply_81ed9f7c04d24298a5b698d703158e71_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7_OutVector4_1_Vector2, _Property_c57582720349407ab19944989357a0cd_Out_0_Vector2, _Multiply_81ed9f7c04d24298a5b698d703158e71_Out_2_Vector2);
            float _Property_1fdc57dd6a5a4f01bf7fbcd6bcee8646_Out_0_Float = _NoiseScale;
            float _SimpleNoise_315660502c104297b4122c3a92156900_Out_2_Float;
            Unity_SimpleNoise_Deterministic_float(_Multiply_81ed9f7c04d24298a5b698d703158e71_Out_2_Vector2, _Property_1fdc57dd6a5a4f01bf7fbcd6bcee8646_Out_0_Float, _SimpleNoise_315660502c104297b4122c3a92156900_Out_2_Float);
            float _Property_b730cc2902054cc38644d3877b209dc0_Out_0_Float = _NoiseContrast;
            float3 _Contrast_0e2a0f87675e4ecd8dc0dea7e999eb5a_Out_2_Vector3;
            Unity_Contrast_float((_SimpleNoise_315660502c104297b4122c3a92156900_Out_2_Float.xxx), _Property_b730cc2902054cc38644d3877b209dc0_Out_0_Float, _Contrast_0e2a0f87675e4ecd8dc0dea7e999eb5a_Out_2_Vector3);
            float3 _OneMinus_e67c38c9496b40fca9bd0aba02acbc00_Out_1_Vector3;
            Unity_OneMinus_float3(_Contrast_0e2a0f87675e4ecd8dc0dea7e999eb5a_Out_2_Vector3, _OneMinus_e67c38c9496b40fca9bd0aba02acbc00_Out_1_Vector3);
            float3 _Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3;
            Unity_Branch_float3(_Property_103b8d9988de43a59179d4baeb8b0baf_Out_0_Boolean, _OneMinus_e67c38c9496b40fca9bd0aba02acbc00_Out_1_Vector3, _Contrast_0e2a0f87675e4ecd8dc0dea7e999eb5a_Out_2_Vector3, _Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3);
            float3 _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_a74ae3377777416eab0f1e3d475bec58_Out_2_Vector4.xyz), _Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3, _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3);
            float _Split_e3def6f5de904b7abcb9f99adbcf03bf_R_1_Float = _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3[0];
            float _Split_e3def6f5de904b7abcb9f99adbcf03bf_G_2_Float = _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3[1];
            float _Split_e3def6f5de904b7abcb9f99adbcf03bf_B_3_Float = _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3[2];
            float _Split_e3def6f5de904b7abcb9f99adbcf03bf_A_4_Float = 0;
            float4 _Combine_b07dbf262c614725ad02db620dc63383_RGBA_4_Vector4;
            float3 _Combine_b07dbf262c614725ad02db620dc63383_RGB_5_Vector3;
            float2 _Combine_b07dbf262c614725ad02db620dc63383_RG_6_Vector2;
            Unity_Combine_float(_Split_e3def6f5de904b7abcb9f99adbcf03bf_R_1_Float, _Split_e3def6f5de904b7abcb9f99adbcf03bf_G_2_Float, _Split_e3def6f5de904b7abcb9f99adbcf03bf_B_3_Float, (_Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3).x, _Combine_b07dbf262c614725ad02db620dc63383_RGBA_4_Vector4, _Combine_b07dbf262c614725ad02db620dc63383_RGB_5_Vector3, _Combine_b07dbf262c614725ad02db620dc63383_RG_6_Vector2);
            float _Property_d94c916e4a654bd8b2212943c211d505_Out_0_Float = _DetailsOpacity;
            float3 _Multiply_d793936fdb3742e2826551d9a4de8473_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Property_d94c916e4a654bd8b2212943c211d505_Out_0_Float.xxx), _Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3, _Multiply_d793936fdb3742e2826551d9a4de8473_Out_2_Vector3);
            float4 _Blend_17cb2777455e45488da86992a6e9df1e_Out_2_Vector4;
            Unity_Blend_Overwrite_float4(_Multiply_c5de1c39b6c14b2fb5c0549193a1032a_Out_2_Vector4, _Combine_b07dbf262c614725ad02db620dc63383_RGBA_4_Vector4, _Blend_17cb2777455e45488da86992a6e9df1e_Out_2_Vector4, (_Multiply_d793936fdb3742e2826551d9a4de8473_Out_2_Vector3).x);
            float4 _Clamp_371ece0e403c4c8ca3c7e7d0d280820c_Out_3_Vector4;
            Unity_Clamp_float4(_Blend_17cb2777455e45488da86992a6e9df1e_Out_2_Vector4, float4(0, 0, 0, 0), float4(255, 255, 255, 1), _Clamp_371ece0e403c4c8ca3c7e7d0d280820c_Out_3_Vector4);
            surface.BaseColor = (_Clamp_371ece0e403c4c8ca3c7e7d0d280820c_Out_3_Vector4.xyz);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Universal 2D"
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor_TexelSize;
        float _TextureScale;
        float _Smoothness;
        float4 _Emission;
        float4 _DetailsTexture_TexelSize;
        float _NoiseScale;
        float _NoiseContrast;
        float _InverseNoise;
        float _DetailsOpacity;
        float _Warp;
        float _DetailsScale;
        float2 _MappingScale;
        float4 _ColorizeTex;
        float4 _ColorizeDetails;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseColor);
        SAMPLER(sampler_BaseColor);
        TEXTURE2D(_DetailsTexture);
        SAMPLER(sampler_DetailsTexture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // unity-custom-func-begin
        void TriplanarUVmapping_float(float3 Position, float Tile, float3 Normal, float Blend, out float2 Out){
        float3 Node_UV = Position * Tile;
        
        float3 Node_Blend = pow(abs(Normal), Blend);
        
        Node_Blend /= (Node_Blend.x + Node_Blend.y + Node_Blend.z ).xxx;
        
        float2 Node_X = Node_UV.zy;
        
        float2 Node_Y = Node_UV.xz;
        
        float2 Node_Z = Node_UV.xy;
        
        Out = Node_X * Node_Blend.x + Node_Y * Node_Blend.y + Node_Z * Node_Blend.z;
        
        }
        // unity-custom-func-end
        
        struct Bindings_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float
        {
        float3 AbsoluteWorldSpacePosition;
        };
        
        void SG_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float(float _Warp, float _Tile, Bindings_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float IN, out float2 Out_Vector4_1)
        {
        float _Property_a4bdf31d4c204e49aa4073d18397661a_Out_0_Float = _Tile;
        float _Property_0ff2401d4526446a8967fd71528a7620_Out_0_Float = _Warp;
        float2 _TriplanarUVmappingCustomFunction_4a6ec34197d14ff9b595de762184b1e3_Out_4_Vector2;
        TriplanarUVmapping_float(IN.AbsoluteWorldSpacePosition, _Property_a4bdf31d4c204e49aa4073d18397661a_Out_0_Float, IN.AbsoluteWorldSpacePosition, _Property_0ff2401d4526446a8967fd71528a7620_Out_0_Float, _TriplanarUVmappingCustomFunction_4a6ec34197d14ff9b595de762184b1e3_Out_4_Vector2);
        Out_Vector4_1 = _TriplanarUVmappingCustomFunction_4a6ec34197d14ff9b595de762184b1e3_Out_4_Vector2;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        float Unity_SimpleNoise_ValueNoise_Deterministic_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_Tchou_2_1_float(c0, r0);
            float r1; Hash_Tchou_2_1_float(c1, r1);
            float r2; Hash_Tchou_2_1_float(c2, r2);
            float r3; Hash_Tchou_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_Deterministic_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Contrast_float(float3 In, float Contrast, out float3 Out)
        {
            float midpoint = pow(0.5, 2.2);
            Out =  (In - midpoint) * Contrast + midpoint;
        }
        
        void Unity_OneMinus_float3(float3 In, out float3 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Blend_Overwrite_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            Out = lerp(Base, Blend, Opacity);
        }
        
        void Unity_Clamp_float4(float4 In, float4 Min, float4 Max, out float4 Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseColor);
            float _Property_7c0fe046032c4123aa0030efd337df6e_Out_0_Float = _TextureScale;
            float3 Triplanar_6912659c33ff4153b8e96b9536a80d87_UV = IN.AbsoluteWorldSpacePosition * _Property_7c0fe046032c4123aa0030efd337df6e_Out_0_Float;
            float3 Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(float(1), floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend /= dot(Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend, 1.0);
            float4 Triplanar_6912659c33ff4153b8e96b9536a80d87_X = SAMPLE_TEXTURE2D(_Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.tex, _Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.samplerstate, Triplanar_6912659c33ff4153b8e96b9536a80d87_UV.zy);
            float4 Triplanar_6912659c33ff4153b8e96b9536a80d87_Y = SAMPLE_TEXTURE2D(_Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.tex, _Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.samplerstate, Triplanar_6912659c33ff4153b8e96b9536a80d87_UV.xz);
            float4 Triplanar_6912659c33ff4153b8e96b9536a80d87_Z = SAMPLE_TEXTURE2D(_Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.tex, _Property_a3dcc902416a442ab53f59f593d5b76f_Out_0_Texture2D.samplerstate, Triplanar_6912659c33ff4153b8e96b9536a80d87_UV.xy);
            float4 _Triplanar_6912659c33ff4153b8e96b9536a80d87_Out_0_Vector4 = Triplanar_6912659c33ff4153b8e96b9536a80d87_X * Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend.x + Triplanar_6912659c33ff4153b8e96b9536a80d87_Y * Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend.y + Triplanar_6912659c33ff4153b8e96b9536a80d87_Z * Triplanar_6912659c33ff4153b8e96b9536a80d87_Blend.z;
            float4 _Property_18c38c82ce484588aae575348e2394c3_Out_0_Vector4 = _ColorizeTex;
            float4 _Multiply_c5de1c39b6c14b2fb5c0549193a1032a_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Triplanar_6912659c33ff4153b8e96b9536a80d87_Out_0_Vector4, _Property_18c38c82ce484588aae575348e2394c3_Out_0_Vector4, _Multiply_c5de1c39b6c14b2fb5c0549193a1032a_Out_2_Vector4);
            UnityTexture2D _Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DetailsTexture);
            float _Property_87787443c0d94107a973afa19bec8473_Out_0_Float = _DetailsScale;
            float3 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_UV = IN.AbsoluteWorldSpacePosition * _Property_87787443c0d94107a973afa19bec8473_Out_0_Float;
            float3 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(float(1), floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend /= dot(Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend, 1.0);
            float4 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_X = SAMPLE_TEXTURE2D(_Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.tex, _Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.samplerstate, Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_UV.zy);
            float4 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Y = SAMPLE_TEXTURE2D(_Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.tex, _Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.samplerstate, Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_UV.xz);
            float4 Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Z = SAMPLE_TEXTURE2D(_Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.tex, _Property_5a282ddf73dd45fdbfcfac39d07d2d5b_Out_0_Texture2D.samplerstate, Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_UV.xy);
            float4 _Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Out_0_Vector4 = Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_X * Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend.x + Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Y * Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend.y + Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Z * Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Blend.z;
            float4 _Property_ae5ff527366a48808a6c451cb6350985_Out_0_Vector4 = _ColorizeDetails;
            float4 _Multiply_a74ae3377777416eab0f1e3d475bec58_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Triplanar_828a0c159eaf4c3a8dcbba38dd3a4bff_Out_0_Vector4, _Property_ae5ff527366a48808a6c451cb6350985_Out_0_Vector4, _Multiply_a74ae3377777416eab0f1e3d475bec58_Out_2_Vector4);
            float _Property_103b8d9988de43a59179d4baeb8b0baf_Out_0_Boolean = _InverseNoise;
            float _Property_e79fa408fbb84200843252e2d841c82a_Out_0_Float = _Warp;
            Bindings_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7;
            _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            float2 _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7_OutVector4_1_Vector2;
            SG_TriplanarUVsubgraph_91ccac32cc2000040beca5773d87d416_float(_Property_e79fa408fbb84200843252e2d841c82a_Out_0_Float, float(1), _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7, _TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7_OutVector4_1_Vector2);
            float2 _Property_c57582720349407ab19944989357a0cd_Out_0_Vector2 = _MappingScale;
            float2 _Multiply_81ed9f7c04d24298a5b698d703158e71_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TriplanarUVsubgraph_1ec6fb0211d54567b68b57d5079bc2c7_OutVector4_1_Vector2, _Property_c57582720349407ab19944989357a0cd_Out_0_Vector2, _Multiply_81ed9f7c04d24298a5b698d703158e71_Out_2_Vector2);
            float _Property_1fdc57dd6a5a4f01bf7fbcd6bcee8646_Out_0_Float = _NoiseScale;
            float _SimpleNoise_315660502c104297b4122c3a92156900_Out_2_Float;
            Unity_SimpleNoise_Deterministic_float(_Multiply_81ed9f7c04d24298a5b698d703158e71_Out_2_Vector2, _Property_1fdc57dd6a5a4f01bf7fbcd6bcee8646_Out_0_Float, _SimpleNoise_315660502c104297b4122c3a92156900_Out_2_Float);
            float _Property_b730cc2902054cc38644d3877b209dc0_Out_0_Float = _NoiseContrast;
            float3 _Contrast_0e2a0f87675e4ecd8dc0dea7e999eb5a_Out_2_Vector3;
            Unity_Contrast_float((_SimpleNoise_315660502c104297b4122c3a92156900_Out_2_Float.xxx), _Property_b730cc2902054cc38644d3877b209dc0_Out_0_Float, _Contrast_0e2a0f87675e4ecd8dc0dea7e999eb5a_Out_2_Vector3);
            float3 _OneMinus_e67c38c9496b40fca9bd0aba02acbc00_Out_1_Vector3;
            Unity_OneMinus_float3(_Contrast_0e2a0f87675e4ecd8dc0dea7e999eb5a_Out_2_Vector3, _OneMinus_e67c38c9496b40fca9bd0aba02acbc00_Out_1_Vector3);
            float3 _Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3;
            Unity_Branch_float3(_Property_103b8d9988de43a59179d4baeb8b0baf_Out_0_Boolean, _OneMinus_e67c38c9496b40fca9bd0aba02acbc00_Out_1_Vector3, _Contrast_0e2a0f87675e4ecd8dc0dea7e999eb5a_Out_2_Vector3, _Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3);
            float3 _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Multiply_a74ae3377777416eab0f1e3d475bec58_Out_2_Vector4.xyz), _Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3, _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3);
            float _Split_e3def6f5de904b7abcb9f99adbcf03bf_R_1_Float = _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3[0];
            float _Split_e3def6f5de904b7abcb9f99adbcf03bf_G_2_Float = _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3[1];
            float _Split_e3def6f5de904b7abcb9f99adbcf03bf_B_3_Float = _Multiply_06d4a6a829204afb9d68f4d2e1ffbfb7_Out_2_Vector3[2];
            float _Split_e3def6f5de904b7abcb9f99adbcf03bf_A_4_Float = 0;
            float4 _Combine_b07dbf262c614725ad02db620dc63383_RGBA_4_Vector4;
            float3 _Combine_b07dbf262c614725ad02db620dc63383_RGB_5_Vector3;
            float2 _Combine_b07dbf262c614725ad02db620dc63383_RG_6_Vector2;
            Unity_Combine_float(_Split_e3def6f5de904b7abcb9f99adbcf03bf_R_1_Float, _Split_e3def6f5de904b7abcb9f99adbcf03bf_G_2_Float, _Split_e3def6f5de904b7abcb9f99adbcf03bf_B_3_Float, (_Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3).x, _Combine_b07dbf262c614725ad02db620dc63383_RGBA_4_Vector4, _Combine_b07dbf262c614725ad02db620dc63383_RGB_5_Vector3, _Combine_b07dbf262c614725ad02db620dc63383_RG_6_Vector2);
            float _Property_d94c916e4a654bd8b2212943c211d505_Out_0_Float = _DetailsOpacity;
            float3 _Multiply_d793936fdb3742e2826551d9a4de8473_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Property_d94c916e4a654bd8b2212943c211d505_Out_0_Float.xxx), _Branch_00639e35599e4a26bce3f8f126664009_Out_3_Vector3, _Multiply_d793936fdb3742e2826551d9a4de8473_Out_2_Vector3);
            float4 _Blend_17cb2777455e45488da86992a6e9df1e_Out_2_Vector4;
            Unity_Blend_Overwrite_float4(_Multiply_c5de1c39b6c14b2fb5c0549193a1032a_Out_2_Vector4, _Combine_b07dbf262c614725ad02db620dc63383_RGBA_4_Vector4, _Blend_17cb2777455e45488da86992a6e9df1e_Out_2_Vector4, (_Multiply_d793936fdb3742e2826551d9a4de8473_Out_2_Vector3).x);
            float4 _Clamp_371ece0e403c4c8ca3c7e7d0d280820c_Out_3_Vector4;
            Unity_Clamp_float4(_Blend_17cb2777455e45488da86992a6e9df1e_Out_2_Vector4, float4(0, 0, 0, 0), float4(255, 255, 255, 1), _Clamp_371ece0e403c4c8ca3c7e7d0d280820c_Out_3_Vector4);
            surface.BaseColor = (_Clamp_371ece0e403c4c8ca3c7e7d0d280820c_Out_3_Vector4.xyz);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}