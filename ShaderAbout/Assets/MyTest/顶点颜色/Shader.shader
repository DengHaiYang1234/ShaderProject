// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Hidden/Shader"
{
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
				float4 color : TEXCOORD0;
			};

			struct v2f
			{
				float4 color : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				//正方体的顶点坐标是（-0.5，0.5）模型本身坐标
				//o.color = v.vertex.x > 0 ? fixed4(1,0,0,1) : fixed4(0,0,1,1);

				//指定顶点颜色   模型本身坐标                                                 
				//sinTime的取值是在（-1，1），所以_SinTime.w / 2 + 0.5固定它的取值范围为（0，1）
				o.color = ((v.vertex.x == 0.5) && (v.vertex.y == 0.5) && (v.vertex.z == -0.5)) ? fixed4(_SinTime.w / 2 + 0.5,_CosTime.w / 2 + 0.5,0,1) : fixed4(0,0,_SinTime.w / 2 + 0.5,1);

				// //世界坐标
				// float4 wPos = mul(unity_ObjectToWorld,v.vertex);

				// o.color = wPos.x > 0 ? fixed4(1,0,0,1) : fixed4(0,0,1,1);

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
