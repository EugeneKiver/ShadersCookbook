Shader "Custom/HM-grad-16" 
{
	Properties 
	{
		_MainTex ("Material height map", 2D) = "white" {}
		_MatMapTex("Materials map", 2D) = "white" {}
		_MapperTex("Materials Mapper", 2D) = "white" {}
		_RampTex("Materials DB map", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		#define M_PI 3.1415926535897932384626433832795
		//#pragma vertex vert
		//#pragma fragment frag
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows
		//#pragma surface surf NoLight
		//#pragma enable_d3d11_debug_symbols
		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _MatMapTex;
		
		sampler2D _RampTex;
		sampler2D _MapperTex;
		
		struct Input 
		{
			float2 uv_MainTex;
		};


		half _Glossiness;
		half _Metallic;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
		// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		/*fixed4 LightingNoLight(SurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
		{
			float4 c;
			c.rgb = s.Albedo;
			c.a = s.Alpha;

			return c;
		}*/
			
		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			// whole spectrum is 256 (one 8 bit channel)
			// number of materials per mask map is 16
			float SdM = 16;	 // Optimization, 256/16 spectrum/numberOfMats
			float MdS = 0.0625; // Optimization 16/256 numberOfMats/spectrum
			//float spectrum = 256;
			float mapperTexWidth = 4; // sqrt(SdM)
			float mapperTexWidthFrac = 0.25;
			float pixelUVShift = 0.125;// 0.125; // 1/(mapperTexWidth*2); to sample center of pixel

			// Material masks
			float mapMask = tex2D(_MatMapTex, IN.uv_MainTex).r;
			float mapMaskSS = mapMask * SdM; // SS for Spectrum Space // TODO ? optimize
			float mapMaskBaseSS = floor(mapMaskSS);
			float mapMaskCoatSS = clamp(mapMaskBaseSS + 1, 0, 256);

			// experimental
			//float mapMaskBS = mapMask * spectrum; // full int Bit space space
			//float mapMaskCoatBS = mapMaskCoatSS * MdS; // or coat * 256
			//float mapMaskBaseSS = clamp(mapMaskBaseSS - 1, 0.0, 1.0);

			// UV' in mapper
			pixelUVShift = 0; // TODO ? optimize			
			float2 mapMaskCoatUV = float2(
				(fmod(mapMaskCoatSS, mapperTexWidth) * mapperTexWidthFrac) + pixelUVShift,
				(floor(mapMaskCoatSS * mapperTexWidthFrac) * mapperTexWidthFrac) + pixelUVShift);
			float2 mapMaskBaseUV = float2(
				(fmod(mapMaskBaseSS, mapperTexWidth) * mapperTexWidthFrac) + pixelUVShift,
				(floor(mapMaskBaseSS * mapperTexWidthFrac) * mapperTexWidthFrac) + pixelUVShift);

			// Mat ID's
			float matIDCoat = tex2D(_MapperTex, mapMaskCoatUV).r;
			float matIDBase = tex2D(_MapperTex, mapMaskBaseUV).r;

			// sample material depth from height map 
			float matDepth = tex2D(_MainTex, IN.uv_MainTex).r;

			// sample two materials
			float4 matCoat = tex2D(_RampTex, float2(matDepth, matIDCoat));
			float4 matBase = tex2D(_RampTex, float2(matDepth, matIDBase));

			//o.Albedo = matBase.rgb;
			//o.Albedo = matCoat.rgb;

			// Calculate lerf factor ---------------------------------------------------
			float angle = (sin(mapMask*M_PI*16 + M_PI/4));
			float lerpFactor = 1;
			float halfPI = M_PI / 2;
			angle = mapMask * halfPI;
			if (sin(mapMask*M_PI*16)>=0)
			{
				lerpFactor = abs(sin(angle * 16 + M_PI));
			}
			else
			{
				lerpFactor = abs(sin(angle * 16 + halfPI));
			}

			o.Albedo = lerp(matBase, matCoat, lerpFactor).rgb;

			// -DEBUG-------------------------------------------------------------------------
			// DONE >>>step 1 mapMask check 
			//o.Albedo = float3(mapMask, mapMask, mapMask);

			// >>>step 4 mapMaskBaseSS check 
			//o.Albedo = float3(float(mapMaskBaseSS*MdS), float(mapMaskBaseSS*MdS), float(mapMaskBaseSS*MdS));

			// >>>step 3 mapMaskCoatSS check 
			//o.Albedo = float3(float(mapMaskCoatSS * MdS), float(mapMaskCoatSS * MdS), float(mapMaskCoatSS * MdS));

			// >>>step 8 mapMaskBaseUV check 
			//o.Albedo = float3(mapMaskBaseUV.x, mapMaskBaseUV.x, mapMaskBaseUV.x);
			//o.Albedo = float3(mapMaskBaseUV.y, mapMaskBaseUV.y, mapMaskBaseUV.y);

			// >>>step 7 mapMaskCoatUV check 
			//o.Albedo = float3(mapMaskCoatUV.x, mapMaskCoatUV.x, mapMaskCoatUV.x);
			//o.Albedo = float3(mapMaskCoatUV.y, mapMaskCoatUV.y, mapMaskCoatUV.y);

			// >>>step 9 matID check
			//o.Albedo = float3(matIDBase, matIDBase, matIDBase);
			//o.Albedo = float3(matIDCoat, matIDCoat, matIDCoat);

			// >>>step mat
			//o.Albedo = matBase.rgb;
			//o.Albedo = matCoat.rgb;

			// Draw half with debug info
			//if (IN.uv_MainTex.x > 0.5)
			//{o.Albedo = float3(lerpFactor, lerpFactor, lerpFactor);}
			
			// >>>step 11 lerpFactor
			//o.Albedo = float3(lerpFactor, lerpFactor, lerpFactor);
			
			// --DEBUG-END-----------------------------------------------------			
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = 1.0;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
