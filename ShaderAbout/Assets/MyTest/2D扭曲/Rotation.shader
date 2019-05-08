Shader "Hidden/Rotation"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_RotScale("RotScale",Range(0,100)) = 0
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
				return o;
			}
			
			sampler2D _MainTex;

			float _RotScale;

			//中心点
			static float2 center_uv = {0.5,0.5};

			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv = i.uv;
				//获取其他UV到中心UV的向量
				float2 dt = uv - center_uv;
				
				//距离公式
				float distance = sqrt(dot(dt,dt));
				//旋转θ
				float theta = -distance * _RotScale;
				//绕y轴旋转矩阵
				float2x2 rota = 
				{
					cos(theta),sin(theta),
					-sin(theta),cos(theta)
				};
				//旋转uv
				dt = mul(rota,dt);
				//输出所有uv
				uv = dt + center_uv;

				fixed4 col = tex2D(_MainTex, uv);

				return col;
			}
			ENDCG
		}
	}
}
