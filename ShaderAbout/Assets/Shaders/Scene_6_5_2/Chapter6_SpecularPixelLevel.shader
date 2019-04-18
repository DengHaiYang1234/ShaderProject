// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


//使用的Phong模型
Shader "Unity Shaders Book/ Chapter 6/Specular Pixel-Level"
{
	Properties
	{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)

		_Gloss("Gloss",Range(8.0,256)) = 20 
	}

	SubShader
	{
		Pass
		{
			Tags {"LightMode" = "ForwardBase"}


			CGPROGRAM

			#pragma vertex vert 
			#pragma fragment frag 

			#include "Lighting.cginc"

			fixed3 _Diffuse;
			fixed3 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				fixed3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			//顶点着色器只需要计算世界空间下法线方向和顶点坐标，并把它们传递给片元着色器
			v2f vert(a2v v)
			{
				v2f o;
				//顶点坐标变换
				o.pos = UnityObjectToClipPos(v.vertex);
				//将普通的法线向量变化至世界空间中
				o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
				//将普通的顶点坐标变换至世界空间中
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

				return o;
			}

			//片元着色器计算关键的光照模型
			fixed4 frag(v2f i) : SV_Target
			{
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//归一化
				fixed3 worldNormal = normalize(i.worldNormal);
				//世界空间下的光照方向
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//漫反射光照计算公式
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));
				//反射计算公式
				fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));
				//得到视角方向
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(viewDir,reflectDir)), _Gloss);

				return (ambient + diffuse + specular,1.0);
			}

			ENDCG
		}
	}

	Fallback "Specular"
}