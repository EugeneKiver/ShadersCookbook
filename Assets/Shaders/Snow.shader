Shader "CookbookShaders/Snow" {
	Properties {
		
		_Color ("Color", Color) = (1.0,1.0,1.0,1.0)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Bump("Bump", 2D) = "bump" {}
		_SnowLevel("Snow level", Range(-1,1)) = 1
		_SnowColor("Snow Color", Color) = (1.0,1.0,1.0,1.0)
		_SnowDirection("Dir of snow", Vector) = (0,1,0)
		_SnowDepth("Snow level", Range(0,1)) = 0

	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard vertex:vert
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _Bump;

		struct Input {
			float2 uv_MainTex;
			float2 uv_Bump;
			float3 worldNormal;
			INTERNAL_DATA
		};

		float4 _Color;
		float _SnowLevel;
		float4 _SnowColor;
		float3 _SnowDirection;
		float _SnowDepth;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void vert(inout appdata_full v)
		{
			float4 sn = mul(UNITY_MATRIX_IT_MV, _SnowDirection);
			if (dot(v.normal, sn.xyz) >= _SnowLevel)
				v.vertex.xyz += sn.xyz * v.normal * _SnowDepth;// *_SnowLevel;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			half4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Normal = UnpackNormal(tex2D(_Bump, IN.uv_Bump));
			if (dot(WorldNormalVector(IN, o.Normal), _SnowDirection.xyz) >= _SnowLevel)
			{
				o.Albedo = _SnowColor.rgb;
			}
			else
			{
				o.Albedo = c.rgb * _Color;
			}
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
