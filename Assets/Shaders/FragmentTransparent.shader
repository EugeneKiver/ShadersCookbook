// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CookbookShaders/FragmentTransparent" 
{

	SubShader
	{
		//Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Opaque" }
		//ZWrite On Lighting Off Cull Off Fog{ Mode Off } Blend One Zero

		GrabPass
		{

		}
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _GrabTexture;

			struct vertInput
			{
				float4 vertex : POSITION;
			};

			struct vertOutput
			{
				float4 vertex : POSITION;
				float4 uvgrab : TEXCOORD1;
			};

			vertOutput vert(vertInput input)
			{
				vertOutput o;
				o.vertex = UnityObjectToClipPos(input.vertex);
				o.uvgrab = ComputeGrabScreenPos(o.vertex);
				return o;
			}

			half4 frag(vertOutput output) : COLOR
			{
				half4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(output.uvgrab));
				return col + half4(0.5,0,0,0);
			}
			ENDCG
		} // Pass
	} // Sub
} // Shader
