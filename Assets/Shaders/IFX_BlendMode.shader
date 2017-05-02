Shader "Hidden/IFX_BlendMode"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BlendTex("Blend texture", 2D) = "white" {}
		_Opacity ("Opacity", Range(0, 1)) = 1.0
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
			uniform sampler2D _BlendTex;
			fixed _Opacity;

			struct texInput
			{
				float2 uv : TEXCOORD0;
			};

			fixed OverlayBlend(fixed basePixel, fixed blendPixel)
			{
				if (basePixel < 0.5)
				{
					return (2.0 * basePixel * blendPixel);
				}
				else
				{
					return (1.0 - 2.0 * (1.0 - basePixel) * (1.0 - blendPixel));
				}
			}

			fixed4 frag (texInput i) : COLOR
			{
				fixed4 renderTex = tex2D(_MainTex, i.uv);
				fixed4 blendTex = tex2D(_BlendTex, i.uv);
				fixed4 blendedTex = renderTex;

				// Multiply
				//blendedTex = renderTex * blendTex;
				
				// Add
				//blendedTex = renderTex + blendTex;
				
				// Screen
				//blendedTex = (1.0 - ((1.0 - renderTex) * (1.0 - blendTex)));
				
				// Overlay
				blendedTex.r = OverlayBlend(renderTex.r, blendTex.r);
				blendedTex.g = OverlayBlend(renderTex.g, blendTex.g);
				blendedTex.b = OverlayBlend(renderTex.b, blendTex.b);


				renderTex = lerp(renderTex, blendedTex, _Opacity);

				return renderTex;
			}
			ENDCG
		}
	}
}
