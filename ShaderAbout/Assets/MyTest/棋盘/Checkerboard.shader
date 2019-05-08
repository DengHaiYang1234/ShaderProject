// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Checkerboard"
{
	Properties
	{
		_Color("Color",Color) = (1,1,1,1)
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment frag 

			struct a2v
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			};

			fixed checker(float2 uv)
			{
				//uv扩大10倍
				float2 repeatUV = uv * 10;
				//floor:向下取证
				float2 c = floor(repeatUV) / 2;
				//frac:取小数部分
				float checker = frac(c.x + c.y) * 2;

				return checker;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
				fixed col = checker(i.uv);
				return col;
			}
			ENDCG
		}
	}
}