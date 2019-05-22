// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/Shaer"
{
	Properties
	{
		
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
				float4 color : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				// float2 dVir = (v.vertex.zw - float2(0,0)) * _SinTime.w;

				// float theta = sqrt(dot(dVir,dVir));

				//float theta = length(v.vertex) * _SinTime.w;

				// float4x4 rotation = 
				// {
				// 	float4(cos(theta),0,sin(theta),0),
				// 	float4(0,1,0,0),
				// 	float4(-sin(theta),0,cos(theta),0),
				// 	float4(0,0,0,1)
				// };

				// v.vertex = mul(rotation,v.vertex);

				//优化旋转
				// float x = cos(theta) * v.vertex.x + sin(theta) * v.vertex.z;
				// float z = cos(theta) * v.vertex.z - sin(theta) * v.vertex.x;

				//v.vertex.x = x;
				//v.vertex.z = z;

				//=================缩放=========

				//根据z轴的大小来决定缩放的大小
				float2 dVir = (v.vertex.z - float2(0,0)) + _Time.y;

				float theta = sqrt(dot(dVir,dVir));

				// //X轴缩放
				// float4x4 scale = 
				// {
				// 	float4(sin(theta) / 8 + 0.5,0,0,0),
				// 	float4(0,1,0,0),
				// 	float4(0,0,1,0),
				// 	float4(0,0,0,1)
				// };

				// v.vertex = mul(scale,v.vertex);
				
				//优化
				float x = sin(theta) / 8 + 0.5 * v.vertex.x;

				v.vertex.x = x;

				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);

				o.color = float4(0,1,1,1);
				
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
