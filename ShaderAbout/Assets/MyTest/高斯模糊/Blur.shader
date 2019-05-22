Shader "Hidden/Blur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		//模糊强度值   也就是说取的uv值越远
		_Strength("Strength",Range(0,10)) = 2
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
		

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

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
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;

			float _Strength;

			float4 _MainTex_TexelSize;

			fixed4 frag (v2f i) : SV_Target
			{
				//高斯算子：
				//              1   2  1
				//  1/16 *      2   4  2
				//              1   2  1

				fixed3 col = tex2D(_MainTex, i.uv + _MainTex_TexelSize * _Strength * float2(-1,1)).rgb * 1;
				col += tex2D(_MainTex, i.uv + _MainTex_TexelSize * _Strength  * float2(0,1)).rgb * 2;
				col += tex2D(_MainTex, i.uv + _MainTex_TexelSize * _Strength  * float2(1,1)).rgb * 1;
				col += tex2D(_MainTex, i.uv + _MainTex_TexelSize * _Strength  * float2(0,-1)).rgb * 2;
				col += tex2D(_MainTex, i.uv + _MainTex_TexelSize * _Strength  * float2(0,0)).rgb * 4;
				col += tex2D(_MainTex, i.uv + _MainTex_TexelSize * _Strength  * float2(0,1)).rgb * 2;
				col += tex2D(_MainTex, i.uv + _MainTex_TexelSize * _Strength  * float2(-1,-1)).rgb * 1;
				col += tex2D(_MainTex, i.uv + _MainTex_TexelSize * _Strength  * float2(0,-1)).rgb * 2;
				col += tex2D(_MainTex, i.uv + _MainTex_TexelSize * _Strength  * float2(1,-1)).rgb * 1;


				col = col / 16;

				return fixed4(col,1);
			}
			ENDCG
		}
	}
}
