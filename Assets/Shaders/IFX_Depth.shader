Shader "Hidden/IFX_Depth"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DepthPower("Depth pow", Range(1, 5)) = 1.0
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
			fixed _DepthPower;
			sampler2D _CameraDepthTexture;

			struct texInput
			{
				float2 uv : TEXCOORD0;
			};

			fixed4 frag (texInput i) : COLOR
			{
				fixed depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));
				depth = pow(Linear01Depth(depth), _DepthPower);
				return depth;
			}
			ENDCG
		}
	}
}
