Shader "CookbookShaders/VertexAnimation" {
	Properties {
		_ColorAmount("Color amount", Range(0,1)) = 0.5
		_ColorA ("Color A", Color) = (0,1,0,1)
		_ColorB ("Color B", Color) = (1,0,0,1)
		_Speed ("Speed", Range(0.1,80)) = 5
		_Frequency ("Frequency", Range(0,5)) = 2
		_Amplitude("Amplitude", Range(-1,1)) = 1
		_MainTex("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Lambert vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		float3 _ColorA;
		float3 _ColorB;
		float _ColorAmount;
		float _Speed;
		float _Frequency;
		float _Amplitude;
		float _OffsetVal;
		fixed4 _Color;
		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float3 vertColor;
		};

		

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			float length = _Time * _Speed;
			float waveValueA = sin(length + v.vertex.x * _Frequency) * _Amplitude;
			v.vertex.xyz = float3(v.vertex.x, v.vertex.y + waveValueA, v.vertex.z);
			v.normal = normalize(float3(v.normal.x + waveValueA, v.normal.y, v.normal.z));
			o.vertColor = float3(waveValueA, waveValueA, waveValueA);
		}

		void surf (Input IN, inout SurfaceOutput o) {
			// Albedo comes from a texture tinted by color
			float3 tintColor = lerp(_ColorA, _ColorB, IN.vertColor).rgb;
			tintColor = float3(saturate(tintColor.r), saturate(tintColor.g), saturate(tintColor.b));
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb + ( tintColor * _ColorAmount);
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
