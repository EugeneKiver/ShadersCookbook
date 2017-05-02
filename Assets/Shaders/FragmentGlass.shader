// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CookbookShaders/FragmentGlass" 
{
	Properties
	{
		_MainTex("Base (RGB), Trans (A)", 2D) = "white" {}
		_BumpMap("Noise text", 2D) = "bump" {}
		_Magnitude("Magnitude", Range(0,1)) = 0.05
	}

	SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Opaque" }
		//ZWrite On Lighting Off Cull Off Fog{ Mode Off } Blend One Zero

		GrabPass
		{}
		
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			sampler2D _GrabTexture;
			sampler2D _MainTex;
			sampler2D _BumpMap;
			float _Magnitude;

			struct vertInput
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};

			struct vertOutput
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float4 uvgrab : TEXCOORD1;
			};

			vertOutput vert(vertInput i)
			{
				vertOutput o;
				o.vertex = UnityObjectToClipPos(i.vertex);
				o.texcoord = i.texcoord;
				o.uvgrab = ComputeGrabScreenPos(o.vertex);
				return o;
			}

			half4 frag(vertOutput o) : COLOR
			{
				half4 mainColor = tex2D(_MainTex, o.texcoord);

				half4 bump = tex2D(_BumpMap, o.texcoord);
				half2 distortion = UnpackNormal(bump).rg;

				o.uvgrab.xy += distortion * _Magnitude;

				fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(o.uvgrab));
				return col * mainColor;
			}
			ENDCG
		} // Pass
	} // Sub
} // Shader
