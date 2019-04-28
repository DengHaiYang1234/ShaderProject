// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
//P130  逐像素光照可以得到更加平滑的光照效果
Shader "Unity Shaders Book/ Chapter 5/Half Lambert"
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
				float3 worldNormal : TEXCOORD0;
			};


			v2f vert(a2v v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				//得到模型空间到世界空间的逆矩阵，然后用行矩阵与之相乘，就等于原矩阵的逆转置矩阵与法线相称。
				o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);

				return o;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(i.worldNormal);

				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 halfLambert = dot(worldNormal,worldLightDir) * 0.5 +0.5;
				
				//半兰伯特光照模型
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;				


				fixed3 color = ambient + diffuse;

				return fixed4(color,1.0);
			}

			ENDCG
		}
	}
	Fallback "Diffuse"
}