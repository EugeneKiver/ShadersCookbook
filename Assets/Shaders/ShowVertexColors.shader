Shader "CookbookShaders/ShowVertexColors" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		
		struct Input {
			float2 uv_MainTex;
			float3 vertColor;
		};
		#pragma surface surf Standard vertex:vert
		#pragma target 3.0

		fixed4 _Color;

		UNITY_INSTANCING_CBUFFER_START(Props)
		UNITY_INSTANCING_CBUFFER_END

		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.vertColor = v.color;
		}
		void surf (Input IN, inout SurfaceOutputStandard o) {
			o.Albedo = IN.vertColor * _Color.rgb;
		}


		ENDCG
	}
	FallBack "Diffuse"
}
