Shader "Hidden/Shader"
{

	Properties
	{
		//融合半径
		_R("R",float) = 0.1
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
				float4 color : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			float _Distance;
			float _R;

			v2f vert (appdata v)
			{
				v2f o;
				//获取齐次坐标
				o.vertex = UnityObjectToClipPos(v.vertex);

				float x = o.vertex.x / o.vertex.w;
				float dis = 0;
				dis += sin(_Time.y);

				o.color = (x > dis && x < dis + _R) ? fixed4(1,0,0,1) : fixed4(x / 2 + 0.5,x / 2 + 0.5,x / 2 + 0.5,1);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{




				return i.color;
			}
			ENDCG
		}
	}
}
