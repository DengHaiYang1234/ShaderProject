//使用该Shader需要知道顶点数据
Shader "Hidden/Shader"
{
	Properties
	{
		_CenterPos("CenterPos",Range(-0.71,0.71)) = 0
		_MainColor("MainColor",Color) = (1,1,1,1)
		_SColor("SColor",Color) = (1,1,1,1)
		_R("R",Range(0,0.5)) = 0.2
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

			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 vertexY : TEXCOORD0;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.vertexY = v.vertex.y;
				return o;
			}
			
			float _CenterPos;
			fixed4 _MainColor;
			fixed4 _SColor;
			float _R;


			fixed4 frag (v2f i) : SV_Target
			{
				//获取顶点y与指定pos的距离
				float curPos = i.vertexY - _CenterPos;
				//获取距离的绝对值
				float absPos = abs(curPos) + 0.00001;
				//取得正负号（保证分母不为0）
				curPos = curPos / absPos;
				//在融合半径范围内的顶点坐标的取值范围是（0,1）最大 0.2 / _R = 1 最小0 / _R = 0
				//不在融合半径的就直接取两个颜色中的一个。因为要么直接大于1，要么直接小于0
				float t = absPos / _R;

				t = saturate(t);

				//根据正负确定上下关系，以便最后再次取值
				curPos *= t;

				curPos = curPos / 2 +0.5;

				return lerp(_MainColor,_SColor,curPos);
				
			}
			ENDCG
		}
	}
}
