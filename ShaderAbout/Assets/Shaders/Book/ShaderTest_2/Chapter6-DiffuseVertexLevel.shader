// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
//P128  漫反射
Shader "Unity Shaders Book/ Chapter 5/Diffuse Vertex-Level"
{
	Properties
	{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
	}

	SubShader
	{
		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			//材质的反射系数
			fixed4 _Diffuse;


			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL; //通过使用NORMAL语义来告诉Unity要把模型顶点的法线信息存储到normal变量中。
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 color : COLOR;
			};


			v2f vert(a2v v)
			{
				v2f o;
				//将顶点位置从模型空间转换到裁剪空间
				o.pos = UnityObjectToClipPos(v.vertex);
				//得到环境光部分
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//表面法线，是使用变换矩阵的逆转置矩阵对法线进行相同的变换。且 转置矩阵与列矩阵相乘等于非转置矩阵与行矩阵相乘
				fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				//得到光源的方向  
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				//漫反射的计算公式 其中_LightColor0.rgb 表示入射光线的颜色和强度
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));

				o.color = ambient + diffuse;

				return o;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				return fixed4(i.color,1.0);
			}

			ENDCG
		}
	}
	Fallback "Diffuse"
}