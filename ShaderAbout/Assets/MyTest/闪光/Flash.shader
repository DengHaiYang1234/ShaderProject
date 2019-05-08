Shader "Hidden/Flash"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_FlashTex("Flash Tex",2D) = "black" {}

		_Brightness("Brightness",Range(0.0,1.0)) = 0.5
		_Offest("Flash Offest",Range(0.0,1.0)) = 0

	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
		Blend SrcAlpha OneMinusSrcAlpha

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
			sampler2D _FlashTex;
			fixed _Brightness;
			fixed _Offest;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col_src = tex2D(_MainTex, i.uv);

				fixed4 col_flash = tex2D(_FlashTex,i.uv + _Offest);

				// 纹理叠加   混合alpha通道  闪光
				fixed4 col_out = col_src + col_flash * col_src.a * col_flash.a * _Brightness;

				return col_out;
			}
			ENDCG
		}
	}
}
