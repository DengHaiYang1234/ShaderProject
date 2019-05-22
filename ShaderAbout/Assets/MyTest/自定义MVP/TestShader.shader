// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/TestShader"
{
	SubShader
	{

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			float4x4 mvp;

			float4x4 rm;

			float4x4 sm;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;

				float4x4 m = UNITY_MATRIX_MVP * sm;

				o.vertex = mul(m,v.vertex);
				//o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : Color
			{
				return fixed4(1,1,1,1);
			}
			ENDCG
		}
	}
}
