Shader "Hidden/Shadow"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_HeroTex("Hero Tex",2D) = "white" {}
		_Brightness("Brightness",Range(0.0,1.0)) = 0.0
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
				//镜像
				o.uv.y = 1 - o.uv.y;
				return o;
			}
			
			sampler2D _MainTex;

			sampler2D _HeroTex;

			fixed _Brightness;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_HeroTex, i.uv);

				//如果纹理不是透明的，那么就可以把它的rgb设置为黑色的，产生阴影效果.同下
				//col.rgb = col.a >= 0 ? _Brightness : col.rgb;

				if(col.a > 0)
				{
					col.rgb = 0;
					col.a = 0.5;
				}

				

				return col;
			}
			ENDCG
		}
	}
}
