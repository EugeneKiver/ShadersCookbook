Shader "Hidden/IFX_OldFilm"
{
	Properties
	{
		_MainTex ("Base texture", 2D) = "white" {}
		_VignetteTex("Vignette texture", 2D) = "white" {}
		_ScratchesTex("Scratches texture", 2D) = "white" {}
		_DustTex("Dust texture", 2D) = "white" {}
		_SepiaColor ("Sepia color", Color) = (1,1,1,1)
		_EffectAmount ("Old film effect amount", Range(0, 1.5)) = 1.0
		_VignetteAmount ("Vignette amount", Range(0, 1)) = 1.0
		_ScratchesYSpeed ("Scratches Y speed", Float) = 10.0
		_ScratchesXSpeed ("Scratches X speed", Float) = 10.0
		_DustYSpeed ("Dust Y speed", Float) = 10.0
		_DustXSpeed ("Dust X speed", Float) = 10.0
		_RandomValue ("Random value", Float) = 1.0
		_Contrast ("Contrast", Float) = 3.0
		_Distortion ("Distortion", Float) = 1.0
		_Scale ("Scale", Float) = 1.0
	
	}
	
	SubShader
	{
		// No culling or depth
		//Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 3.0

			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			uniform sampler2D _VignetteTex;
			uniform sampler2D _ScratchesTex;
			uniform sampler2D _DustTex;
			fixed _SepiaColor;
			fixed _EffectAmount;
			fixed _VignetteAmount;
			fixed _ScratchesYSpeed;
			fixed _ScratchesXSpeed;
			fixed _DustYSpeed;
			fixed _DustXSpeed;
			fixed _RandomValue;
			fixed _Contrast;
			fixed _Distortion;
			fixed _Scale;

			struct texInput
			{
				float2 uv : TEXCOORD0;
			};
			half2 BarrelDistortion(half2 coord, fixed distortion, fixed scale)
			{
				half2 h = coord.xy - half2(0.5, 0.5);
				half r2 = h.x * h.x + h.y * h.y;
				half f = 1.0 + r2 * (distortion * sqrt(r2));

				return f * scale * h + 0.5;
			}

			fixed4 frag (texInput i) : COLOR
			{
				half2 distortedUV = BarrelDistortion(i.uv, _Distortion, _Scale);
				distortedUV = half2(i.uv.x, i.uv.y + (_RandomValue * _SinTime.z * 0.005));
				fixed4 renderTex = tex2D(_MainTex, distortedUV);

				// scratches
				fixed4 vignetteTex = tex2D(_VignetteTex, i.uv);

				// scratches
				half2 scratchesUV = half2(i.uv.x + (_RandomValue * _SinTime.z * _ScratchesXSpeed), i.uv.y + (_Time.x * _ScratchesYSpeed));
				fixed4 scratchesTex = tex2D(_ScratchesTex, scratchesUV);

				// dust
				half2 dustUV = half2(i.uv.x + (_RandomValue * (_SinTime.z * _DustXSpeed)), i.uv.y + (_RandomValue * (_SinTime.z * _DustYSpeed)));
				fixed4 dustTex = tex2D(_DustTex, dustUV);

					// sepia
				fixed lum = dot(fixed3(0.299, 0.587, 0.114), renderTex.rgb);

				fixed4 finalColor = lum + lerp(_SepiaColor, _SepiaColor + fixed4(0.1, 0.1, 0.1, 1.0), _RandomValue);
				finalColor = pow(finalColor, _Contrast);

				// effects opacity
				fixed3 constantWhite = fixed3(1, 1, 1);

				finalColor = lerp(finalColor, finalColor * vignetteTex, _VignetteAmount);
				finalColor.rgb *= lerp(scratchesTex, constantWhite, _RandomValue);
				finalColor.rgb *= lerp(dustTex.rgb, constantWhite, (_RandomValue * _SinTime.z));
				finalColor = lerp(renderTex, finalColor, _EffectAmount);

				return finalColor;
			}
			ENDCG
		}
	}
}
