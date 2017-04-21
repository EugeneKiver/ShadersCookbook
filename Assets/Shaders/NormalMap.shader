Shader "CookbookShaders/NormalMap" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_NormalTex ("Normal", 2D) = "bump" {}
		_NormalIntensity ("Normal intensity", Range(0,2)) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _NormalTex;

		struct Input {
			float2 uv_NormalTex;
		};

		fixed4 _Color;
		fixed _NormalIntensity;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed3 normalMap = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex)).rgb;
			//float3 normalMap = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex));
			normalMap.x *= _NormalIntensity;
			normalMap.y *= _NormalIntensity;

			o.Albedo = _Color.rgb;
			//o.Normal = normalMap.rgb;
			o.Normal = normalize(normalMap);
		}
		ENDCG
	}
	FallBack "Diffuse"
}
