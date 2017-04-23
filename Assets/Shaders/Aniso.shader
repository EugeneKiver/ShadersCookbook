Shader "CookbookShaders/Aniso" {
	Properties {
		_MainTint ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_SpecularColor ("SpecularColor", Color) = (1,1,1,1)
		_Specular ("Specular Amount", Range(0,1)) = 0.5
		_SpecPower ("Specular Power", Range(0,1)) = 0.5
		_AnisoDir("Aniso Texture", 2D) = "white" {}
		_AnisoOffset("Aniso Offset", Range(-10,10)) = -0.2
		_AnisoMult("Aniso Multiplier", Range(-15,15)) = 0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		
		#pragma surface surf Anisotropic
		#pragma target 3.0

		float4 _MainTint;
		float4 _SpecularColor;
		float _Specular;
		float _SpecPower;
		float _AnisoOffset;
		float _AnisoMult;

		sampler2D _AnisoDir;
		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float2 uv_AnisoDir;
		};

		struct SurfaceAnisoOutput
		{
			fixed3 Albedo;
			fixed3 Normal;
			fixed3 Emission;
			fixed3 AnisoDirection;
			half Specular;
			fixed Gloss;
			fixed Alpha;
		};


		//UNITY_INSTANCING_CBUFFER_START(Props)
		//UNITY_INSTANCING_CBUFFER_END

		void surf(Input IN, inout SurfaceAnisoOutput o)
		{
			half4 c = tex2D(_MainTex, IN.uv_MainTex) * _MainTint;
			float3 anisoTex = UnpackNormal(tex2D(_AnisoDir, IN.uv_AnisoDir));

			o.AnisoDirection = anisoTex;
			o.Specular = _Specular;
			o.Gloss = _SpecPower;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		

		inline fixed4 LightingAnisotropic(SurfaceAnisoOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
		{
			fixed3 H = normalize(normalize(lightDir) + normalize(viewDir));
			float NdotL = saturate(dot(s.Normal, lightDir));

			fixed AdotH = dot(normalize(s.Normal + s.AnisoDirection), H);
			//float satAdotH = saturate(normalize(AdotH));
			float aniso = saturate(sin(radians((AdotH*_AnisoMult + _AnisoOffset)*180)));

			float spec = saturate(pow(aniso, (s.Gloss * 128)) * s.Specular);
			//float spec = saturate(dot(s.Normal, H));
			//spec = saturate(pow(lerp(spec, aniso, s.AnisoDirection), s.Gloss * 128) * s.Specular);

			float4 c;
			c.rgb = ((s.Albedo * _LightColor0.rgb * NdotL) + (_LightColor0.rgb * _SpecularColor.rgb * spec * _MainTint)) * (atten);
			//c.rgb = ((s.Albedo * _LightColor0.rgb * NdotL) + (_LightColor0.rgb * spec)) * (atten);

			c.a = s.Alpha;
			return c;
		}
		ENDCG
	}
	FallBack "Diffuse"
}