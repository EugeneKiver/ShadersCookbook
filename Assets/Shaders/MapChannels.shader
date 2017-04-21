Shader "CookbookShaders/MapChannels" {
	Properties {
		//_Color ("Color", Color) = (1,1,1,1)
		_ColorA ("Terrain color A", Color) = (1,1,1,1)
		_ColorB ("Terrain color A", Color) = (1,1,1,1)
		_RTexture("R channel", 2D) = "" {}
		_GTexture("G channel", 2D) = "" {}
		_BTexture("B channel", 2D) = "" {}
		//_ATexture("A channel", 2D) = "" {}
		_BlendTexture("Blend texture", 2D) = "" {}
	}
		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Lambert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		//float4 _Color;
		float4 _ColorA;
		float4 _ColorB;
		sampler2D _RTexture;
		sampler2D _GTexture;
		sampler2D _BTexture;
		//sampler2D _ATexture;
		sampler2D _BlendTexture;

		struct Input {
			float2 uv_RTexture;
			float2 uv_GTexture;
			float2 uv_BTexture;
			//float2 uv_ATexture;
			float2 uv_BlendTexture;
		};

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutput o) {
			// Albedo comes from a texture tinted by color
			float4 blendData = tex2D(_BlendTexture, IN.uv_BlendTexture);

			float4 rTexData = tex2D(_RTexture, IN.uv_RTexture);
			float4 gTexData = tex2D(_GTexture, IN.uv_GTexture);
			float4 bTexData = tex2D(_BTexture, IN.uv_BTexture);
			//float4 aTexData = tex2D(_ATexture, IN.uv_ATexture);

			float4 finalColor;
			finalColor = lerp(rTexData, gTexData, blendData.g);
			finalColor = lerp(finalColor, bTexData, blendData.b);
			//finalColor = lerp(finalColor, aTexData, blendData.a);
			finalColor.a = 1.0;

			float4 terrainLayers = lerp(_ColorA, _ColorB, blendData.r);
			finalColor *= terrainLayers;
			finalColor = saturate(finalColor);

			o.Albedo = finalColor.rgb;// *_Color.rgb;
			o.Alpha = finalColor.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
