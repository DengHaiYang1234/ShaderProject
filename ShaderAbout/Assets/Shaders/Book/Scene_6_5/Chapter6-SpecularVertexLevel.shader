// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/ Chapter 6/Specular Vertex-Level"
{
	Properties
	{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
		//控制高光反射颜色
		_Specular("Specular",Color) = (1,1,1,1)
		//控制高光区域的大小
		_Gloss("Glosss",Range(8.0,256)) = 20
	}

	SubShader
	{
		Pass
		{
			//定义Pass在流水线中的角色  只有定义了才能得到一些Unity内置的光照变量，例如_LightColor0
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment frag 

			#include "Lighting.cginc"

			//为了使用Properties语义块中声明的属性，需要定义和这些属性相匹配的变量
			fixed4 _Diffuse;
			fixed4 _Specular;
			fixed4 _Gloss;

			//定义顶点着色器的输入及输出（输出结构同时也是片元着色器的输入结构）

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 color : COLOR;
			};

			v2f vert(a2v v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//从模型空间变化到世界空间   在世界空间中法线是由原空间变换的逆转置矩阵乘以法线得到的，同时是也等于法线乘以逆矩阵
				fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));

				//获取世界空间下的光照方向
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//计算漫反射公式
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));
				//计算反射公式   第一个参数为光照的入射方向  第二个参数为法线方向  
				//由于Cg的reflect函数的入射方向要求是由光源指向交点处，因此我们需要对worldLightDir取反后再传给reflect函数
				fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));	
				//获取世界空间下的视角方向
				//先得到世界空间下相机的位置，再把顶点位置从模型空间变换到世界空间得到的位置，通过和相机位置的相减得到世界空间下的视角方向
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld,v.vertex).xyz);
				//高光反射公式
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(viewDir,reflectDir)),_Gloss);

				o.color = ambient + diffuse + specular;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return fixed4(i.color,1.0);
			}



			ENDCG

		}
	}

	Fallback "Specular"



}