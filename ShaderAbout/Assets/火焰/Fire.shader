Shader "Hidden/Fire"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_FireColor("Fire Color",Color) = (1,1,1,1)
		_Mask("Mask",2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			Tags
			{
				"Queue" = "Transparent"
			}

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

			sampler2D _Mask;

			float4 _FireColor;

			float rand(float2 p){
				return frac(sin(dot(p ,float2(12.9898,78.233))) * 43758.5453);
			}

			float noise(float2 x)
			{
				float2 i = floor(x);
				float2 f = frac(x);

				float a = rand(i);
				float b = rand(i + float2(1.0, 0.0));
				float c = rand(i + float2(0.0, 1.0));
				float d = rand(i + float2(1.0, 1.0));
				float2 u = f * f * f * (f * (f * 6 - 15) + 10);

				float x1 = lerp(a,b,u.x);
				float x2 = lerp(c,d,u.x);
				return lerp(x1,x2,u.y);
			}

			float fbm(float2 x)
			{
				//雾的亮度
				float scale = 0.4;
				float res = 0;
				float w = 4;
				//雾的密度
				for(int i=0;i<6;++i)
				{
					res += noise(x * w);
					w *= 1.5;
				}
				return res * scale;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				//_Time.x * 9  火焰向上移动

				//模拟焰心且包含移动速度
				float4 noise1 = fbm(i.uv * 0.8 - float2(0,_Time.x * 9));
				//模拟火焰
				float4 noise2 = fbm(i.uv * 1.2 - float2(0,_Time.x * 18));

				float4 col = (noise1 + noise2) / 2 * _FireColor;
				//当UV的y值越高，它的颜色就越接近无色
				col = lerp(col,fixed4(0,0,0,0),i.uv.y);
				
				//采样mask
				float4 mask = tex2D(_Mask,i.uv + float2(0.1,-0.1));

				col = col * mask;

				//是一个爆炸函数（乘方函数）   会放大这个函数很多倍   若小于1就会变的很小
				col = pow(col,2);
				//剪切低于0.8的alpha通道都剪切掉（剪切掉黑烟的效果，也可以不用）
				clip(col.a - 0.8);

				return col;
			}
			ENDCG
		}
	}
}
