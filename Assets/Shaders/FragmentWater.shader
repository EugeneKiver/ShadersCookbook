Shader "CookbookShaders/FragmentWater" 
{
	Properties
	{
		_NoiseTex("Noise text", 2D) = "white" {}
		_Color("Colour", Color) = (1,1,1,1)

		_Period("Period", Range(0,50)) = 1
		_Magnitude("Magnitude", Range(0,0.5)) = 0.05
		_Scale("Scale", Range(0,10)) = 1
	}
	SubShader
	{
		//Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Opaque" }
		//ZWrite On Lighting Off Cull Off Fog{ Mode Off } Blend One Zero

		GrabPass
		{ "_GrabTexture" }
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _GrabTexture;

			sampler2D _NoiseTex;	
			fixed4 _Color;

			float  _Period;
			float  _Magnitude;
			float  _Scale;

			struct vertInput
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct vertOutput
			{
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;

				float4 worldPos : TEXCOORD1;
				float4 uvgrab : TEXCOORD2;
			};

			vertOutput vert(vertInput i)
			{
				vertOutput o;
				o.vertex = UnityObjectToClipPos(i.vertex);
				o.color = i.color;
				o.texcoord = i.texcoord;

				o.worldPos = mul(unity_ObjectToWorld, i.vertex);
				o.uvgrab = ComputeGrabScreenPos(o.vertex);
				return o;
			}

			half4 frag(vertOutput o) : COLOR
			{
				float sinT = sin(_Time.w / _Period);
				
				// World space distortion
				float2 distortion = float2(
									tex2D(_NoiseTex,	o.worldPos.xy / _Scale + float2(sinT, 0)).r		- 0.5,
									tex2D(_NoiseTex,	o.worldPos.xy / _Scale + float2(0, sinT)).r		- 0.5);
				
				// Object space distortion
				/*float2 distortion1 = float2(
					tex2D(_NoiseTex, o.texcoord.xy / _Scale + float2(sinT, 0)).r,
					tex2D(_NoiseTex, o.texcoord.xy / _Scale + float2(0, sinT)).r);*/

				o.uvgrab.xy += distortion * _Magnitude;

				fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(o.uvgrab));
				return col * _Color;
			}
			ENDCG
		} // Pass
	} // Sub
} // Shader
