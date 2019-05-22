// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Hidden/Shaer"
{
	Properties
	{
		_R("R",Range(1,5)) = 1
		//X平面的偏移
		_X("X",Range(-5,5)) = 0
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

			float _R;

			float _X;

			v2f vert (appdata v)
			{
				//将模型空间的坐标变换至世界空间中去
				float4 worldPos = mul(unity_ObjectToWorld,v.vertex);
				float2 xy = worldPos.xz;

				//沿着Y轴往平面看，就是XZ平面 (注意：这是相对模型空间的坐标)
				//float2 xy = v.vertex.xz;
				//获取距离向量
				float2 d = xy - float2(0,0) + float2(_X,0);
				//获取两个向量之间的距离（圆半径）  _R - len是为了距离原点越近，凸起的高度越高 
				//通俗来说就是点距离圆心的距离
				float len = _R -  sqrt(dot(d,d));

				len = len < 0 ? 0 : len;

				float height = 1;

				//新的顶点坐标
				float4 upPos = float4(v.vertex.x,len,v.vertex.z,v.vertex.w);

				//v.vertex = float4(v.vertex.x,heigth + v.vertex.y,v.vertex.z,1);

				v2f o;
				o.vertex = UnityObjectToClipPos(upPos);

				o.color = fixed4(upPos.y,upPos.y,upPos.y,1);

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
