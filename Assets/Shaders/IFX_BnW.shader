Shader "Hidden/IFX_BnW"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_LuminosityAmount("Grayscale Amount", Range(0.0, 1)) = 1.0
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
			fixed _LuminosityAmount;

			struct texInput
			{
				float2 uv : TEXCOORD0;
			};

			fixed4 frag (texInput i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				float luminosity = 0.299 * col.r + 0.587 * col.g + 0.114 * col.b;
				fixed4 finalColor = lerp(col, luminosity, _LuminosityAmount);
				return finalColor;
			}
			ENDCG
		}
	}
}
