Shader "Custom/HM-grad-16" {
	Properties {
		_MainTex ("Material height map", 2D) = "white" {}
		_MatMapTex("Materials map", 2D) = "white" {}
		_MapperTex("Materials Mapper", 2D) = "white" {}
		_RampTex("Materials DB map", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _MatMapTex;
		sampler2D _RampTex;
		sampler2D _MapperTex;

		struct Input {
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

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// whole spectrum is 256 (one 8 bit channel)
			// number of materials per mask map is 16

			float SdM = 16;	 // Optimization, 256/16 spectrum/numberOfMats
			float MdS = 0.0625; // Optimization 16/256 numberOfMats/spectrum
			float mapperTexWidth = 4; // sqrt(SdM)
			float pixelUVShift = 0.125; // 1/(mapperTexWidth*2); to sample center of pixel
			
			// getting ready to sample mapper texture
			float mapMask = tex2D(_MatMapTex, IN.uv_MainTex).r;
			float4 mapMaskRGB = tex2D(_MatMapTex, IN.uv_MainTex);
			float mapMaskSS = mapMask * SdM; // SS for Spectrum Space
			float mapMaskCeilSS = ceil(mapMaskSS);
			float mapMaskFloorSS = floor(mapMaskSS);
			float mapMaskCeilMS = clamp((mapMaskCeilSS-1), 0, 15); // MS for material space
			float mapMaskFloorMS = clamp((mapMaskFloorSS-1), 0, 15);

			// get UV's for mapper tex
			float2 mapMaskCeilUV = float2(
				(fmod(mapMaskCeilMS, mapperTexWidth) / mapperTexWidth) + pixelUVShift,
				((mapMaskCeilMS / mapperTexWidth) / mapperTexWidth) + pixelUVShift);
			float2 mapMaskFloorUV = float2(
				(fmod(mapMaskFloorMS, mapperTexWidth) / mapperTexWidth) + pixelUVShift,
				((mapMaskFloorMS / mapperTexWidth) / mapperTexWidth) + pixelUVShift);

			// sample mapper tex
			float matIDCeil = tex2D(_MapperTex, mapMaskCeilUV).r;
			float matIDFloor = tex2D(_MapperTex, mapMaskFloorUV).r;

			// sample material depth from height map 
			float matDepth = tex2D(_MainTex, IN.uv_MainTex).r;
			//float4 matDepthTest = tex2D(_MainTex, IN.uv_MainTex);
			// sample two materials
			float4 matCeil = tex2D(_RampTex, float2(matDepth, matIDCeil));
			float4 matFloor = tex2D(_RampTex, float2(matDepth, matIDFloor));

			// Calculate lerf factor
			float mapMaskCeil01 = mapMaskCeilSS * 16 / 256;// MdS; // 0..1 space
			float mapMaskFloor01 = mapMaskFloorSS * 16 / 256;//* MdS;
			float lerpFactor = 0;
			// TODO try mix instead of if
			//lerpFactor = mix(mapMaskFloor01, mapMaskCeil01, matDepth);
			if (mapMaskCeil01 != mapMaskFloor01)
			{
				//lerpFactor = lerp()
				//mapMask = clamp(mapMask, 0.0, 1.0);
				//mapMaskFloor01 = clamp(mapMaskFloor01, 0.0, 1.0);
				//mapMaskCeil01 = clamp(mapMaskCeil01, 0.0, 1.0);
				lerpFactor = (mapMask - mapMaskFloor01) / (mapMaskCeil01 - mapMaskFloor01);
				//lerpFactor = (mapMaskCeil01 - mapMaskFloor01) / (mapMask - mapMaskFloor01);
				lerpFactor = clamp(lerpFactor, 0.0, 1.0);
				//lerpFactor = 1.0;
			}
			
			// Interpolate between two materials
			float4 finalColor = lerp(matFloor, matCeil, (lerpFactor));
			//finalColor = lerp(matFloor, matCeil, (lerpFactor));
			
			o.Albedo = finalColor.rgb;

			//o.Albedo = matFloor.rgb;
			//o.Albedo = matCeil.rgb;
			//o.Albedo = float3(mapMask, mapMask, mapMask);
			//o.Albedo = float3(mapMaskRGB.r, mapMaskRGB.r, mapMaskRGB.r);
			//o.Albedo = mapMaskRGB.rgb;

			// TODO floor map is rough even with bilinear sampling
			//o.Albedo = float3(mapMaskFloor01, mapMaskFloor01, mapMaskFloor01);
			//o.Albedo = float3(mapMaskCeilUV.x, mapMaskCeilUV.x, mapMaskCeilUV.x);
			//o.Albedo = float3(mapMaskFloorUV.x, mapMaskFloorUV.x, mapMaskFloorUV.x);
			//o.Albedo = float3(matIDCeil, matIDCeil, matIDCeil);
			//o.Albedo = float3(matIDFloor, matIDFloor, matIDFloor);
			
			//o.Albedo = float3(mapMaskCeil01, mapMaskCeil01, mapMaskCeil01);
			//o.Albedo = float3(lerpFactor, lerpFactor, lerpFactor);
			//o.Albedo = matCeil.rgb;
			//o.Albedo = matFloor.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = finalColor.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
