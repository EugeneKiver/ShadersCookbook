Shader "Hidden/IFX_BCS"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Brightness ("Brightness", Range(0, 1)) = 1.0
		_Saturation("Saturation", Range(0, 1)) = 1.0
		_Contrast("Contrast", Range(0, 1)) = 1.0
	}
	
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 3.0

			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			fixed _Brightness;
			fixed _Saturation;
			fixed _Contrast;
			
			half3 BrtSatCon(half3 color, half brt, half sat, half con)
			{
				half avgLumR = 0.5;
				half avgLumG = 0.5;
				half avgLumB = 0.5;

				half3 lumCoef = half3(0.2125, 0.7154, 0.0721);
				//half3 lumCoef = half3(0.5, 0.5, 0.5);

				//Brt
				half3 avgLum = half3(avgLumR, avgLumG, avgLumB);
				half3 brtCol = color * brt;

				// Sat
				half intensifyf = dot(brtCol, lumCoef);
				half3 intensity = half3(intensifyf, intensifyf, intensifyf);				
				half3 satCol = lerp(intensity, brtCol, sat);

				// Con
				half3 conCol = lerp(avgLum, satCol, con);

				return conCol;
			}

			struct texInput
			{
				float2 uv : TEXCOORD0;
			};

			fixed4 frag (texInput i) : COLOR
			{
				fixed4 renderTex = tex2D(_MainTex, i.uv);
				
				renderTex.rgb = BrtSatCon(renderTex.rgb, _Brightness, _Saturation, _Contrast);
				return renderTex;
			}
			ENDCG
		}
	}
}
