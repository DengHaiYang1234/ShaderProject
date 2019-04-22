// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CurveTest/Curve_1"
{
	Properties
	{
		_BackgroundColor("BackgroundColor",Color) = (1,1,1,1)
		_BackgroundColor2("BackgroundColor2",Color) = (0,0,0,0)
		_Space("Space",Range(0,1)) = 0.2
		_XOffset("XOffset",Range(-1,1)) = 0.15
		_YOffset("YOffset",Range(-1,1)) = 0.05


		_Frequency("Frenquency",Range(0,100)) = 10
		_Amplitude("Amplitude",Range(0,100)) = 0.1
		_Speed("Speed",Range(0,100)) = 10

	}

	SubShader
	{
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
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};


			fixed4 _BackgroundColor;
			fixed4 _BackgroundColor2;
			fixed _Space;
			fixed _XOffset;
			fixed _YOffset;

			half _Frequency;
			half _Amplitude;
			half _Speed;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 a = fmod(i.uv.x + _XOffset,_Space);

				a = step(0.5 * _Space,a);

				fixed b = fmod(i.uv.y + _YOffset,_Space);
				b = step(0.5 * _Space,b);

				fixed4 bgCol = _BackgroundColor * a * b + _BackgroundColor2 * (1 - a * b);

				float y = i.uv.y + sin(i.uv.x * _Frequency + _Time.y * _Speed) * _Amplitude;

				float v = abs(y - 0.5) * 100 + 1;

				v = 1  / v;

				fixed4 lineCol = fixed4(v,v,v,1);

				return bgCol + lineCol;
			}


			ENDCG
		}
	}
}