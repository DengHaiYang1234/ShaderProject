Shader "Hidden/Shader"
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
				//============错误的示范==========
				// //获取x平面上的某顶点与原点的距离
				// //float theta = length(v.vertex.x) + _Time.y;

				// float xDir = (v.vertex.zw - float2(0,0)) + _Time.y;
				// float theta = sqrt(dot(xDir,xDir));
				
				// //Y方向的缩放 (在该平面中，所有的y方向的值都为0)
				// float4x4 scale = 
				// {
				// 	float4(1,0,0,0),
				// 	float4(0,sin(theta) / 8 + 0.5,0,0),
				// 	float4(0,0,1,0),
				// 	float4(0,0,0,1),
				// };

				// v.vertex = mul(scale,v.vertex);


				//============正确的示范==========

				//正弦波公式  y = A *  sin(wx + h)
				//在xz平面的圆形波
				//v.vertex.y += 0.3 * sin(1 - length(v.vertex.xz)  + _Time.y);
				//表示振幅为0.3，角速度为1的，在x上移动的波
				//v.vertex.y += 0.3 * sin(v.vertex.x  + _Time.y);

				//x平面与z平面叠加的波
				v.vertex.y += 0.3 * sin((v.vertex.x + v.vertex.z)  + _Time.y);
				v.vertex.y -= 0.4 * sin((v.vertex.x + v.vertex.z)  + _Time.w);

				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = fixed4(v.vertex.y,v.vertex.y,v.vertex.y,1);
				return o;
			}
			
			sampler2D _MainTex;

			fixed4 frag (v2f i) : SV_Target
			{
				return i.color;
			}
			ENDCG
		}
	}
}
