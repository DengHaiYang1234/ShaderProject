// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Hidden/Shader"
{
	Properties
	{
		_MainClolr("MainClolr",Color) = (0,0,1,1)
		_SpecularColor("SpecularColor",Color) = (1,1,1,1)
		_Glossiness("Glossiness",Range(1,100)) = 1
	}


	SubShader
	{
		// Pass
		// {
		// 	//添加投射阴影
		// 	Tags {"LightMode" = "shadowcaster"}
		// }

		LOD 100

		Pass
		{

			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//多版本光照计算
			#pragma multi_compile_fwdbase
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			//接受阴影部分
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;

			};

			struct v2f
			{
				float3 normal : TEXCOORD0;
				float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD1;
				//具体查看接受阴影部分代码 AutoLight.cginc脚本
				LIGHTING_COORDS(2,3)
			};


			float _Glossiness;
			fixed4 _SpecularColor;
			fixed4 _MainClolr;

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.normal = v.normal;
				o.worldPos = UnityObjectToClipPos(v.vertex).xyz;
				//具体查看接受阴影部分代码 AutoLight.cginc脚本
				TRANSFER_VERTEX_TO_FRAGMENT(o)
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				//=================兰伯特光照模型（环境光+漫反射）==========================
				//=================标准的Phone模型（环境光+漫反射+高光反射）=================
				//环境光
				fixed3 col = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//漫反射(计算顶点与光照的点乘来决定顶点的光照强度)
				float3 worldNormal = mul(float4(i.normal,0),unity_WorldToObject).xyz;

				float3 normalDir = normalize(worldNormal);

				float3 lightDir = normalize(_WorldSpaceLightPos0).xyz;

				float dotValue = saturate(dot(normalDir,lightDir));

				//view
				float3 viewDir = normalize(WorldSpaceViewDir(i.pos));

				col += _LightColor0 * _MainClolr * dotValue;


				// //高光反射
				
				// //求反射光(自定义方法)
				// float3 reflect_lightDir = 2 * max(0,dot(lightDir,normalDir)) * normalDir - lightDir;
				// //使用reflect函数
				// //float3 reflect_lightDir = reflect(-lightDir,normalDir);
				// float specularValue = pow(max(0,dot(viewDir,reflect_lightDir)),_Glossiness);

				// col.rgb += _SpecularColor * specularValue;

				//=========================BlinnPhone光照模型(使用光照向量与view向量形成的H向量)================
				float3 H = normalize(lightDir + viewDir);

				float specularValue = pow(saturate(dot(H,normalDir)),_Glossiness);

				col += _SpecularColor * specularValue;	


				float3 wPos = mul(unity_ObjectToWorld,i.pos).xyz;
				// //点光源
				// col += Shade4PointLights(
				// 				unity_4LightPosX0,unity_4LightPosY0,unity_4LightPosZ0,
				// 				unity_LightColor[0].rgb,unity_LightColor[1].rgb,unity_LightColor[2].rgb,unity_LightColor[3].rgb,
				// 				unity_4LightAtten0,
				// 				wPos,
				// 				normalDir
				// );

				//具体查看接受阴影部分代码 AutoLight.cginc脚本
				UNITY_LIGHT_ATTENUATION(att,i,wPos);

				col *= att;
				
				return fixed4(col,1);
			}

			
			ENDCG
		}

		Pass
		{
			Tags {"LightMode" = "ForwardAdd"}
			blend one one 
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//多版本光照计算
			#pragma multi_compile_fwdadd_fullshadows
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			//接受阴影部分
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;

			};

			struct v2f
			{
				float3 normal : TEXCOORD0;
				float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD1;
				//具体查看接受阴影部分代码 AutoLight.cginc脚本
				LIGHTING_COORDS(2,3)
			};


			float _Glossiness;
			fixed4 _SpecularColor;
			fixed4 _MainClolr;

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.normal = v.normal;
				o.worldPos = UnityObjectToClipPos(v.vertex).xyz;
				//具体查看接受阴影部分代码 AutoLight.cginc脚本
				TRANSFER_VERTEX_TO_FRAGMENT(o)
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				//=================兰伯特光照模型（环境光+漫反射）==========================
				//=================标准的Phone模型（环境光+漫反射+高光反射）=================
				//环境光
				fixed3 col = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//漫反射(计算顶点与光照的点乘来决定顶点的光照强度)
				float3 worldNormal = mul(float4(i.normal,0),unity_WorldToObject).xyz;

				float3 normalDir = normalize(worldNormal);

				float3 lightDir = normalize(_WorldSpaceLightPos0).xyz;

				float dotValue = saturate(dot(normalDir,lightDir));

				//view
				float3 viewDir = normalize(WorldSpaceViewDir(i.pos));

				col += _LightColor0 * _MainClolr * dotValue;


				// //高光反射
				
				// //求反射光(自定义方法)
				// float3 reflect_lightDir = 2 * max(0,dot(lightDir,normalDir)) * normalDir - lightDir;
				// //使用reflect函数
				// //float3 reflect_lightDir = reflect(-lightDir,normalDir);
				// float specularValue = pow(max(0,dot(viewDir,reflect_lightDir)),_Glossiness);

				// col.rgb += _SpecularColor * specularValue;

				//=========================BlinnPhone光照模型(使用光照向量与view向量形成的H向量)================
				float3 H = normalize(lightDir + viewDir);

				float specularValue = pow(saturate(dot(H,normalDir)),_Glossiness);

				col += _SpecularColor * specularValue;	


				float3 wPos = mul(unity_ObjectToWorld,i.pos).xyz;
				//点光源
				col += Shade4PointLights(
								unity_4LightPosX0,unity_4LightPosY0,unity_4LightPosZ0,
								unity_LightColor[0].rgb,unity_LightColor[1].rgb,unity_LightColor[2].rgb,unity_LightColor[3].rgb,
								unity_4LightAtten0,
								wPos,
								normalDir
				);

				//具体查看接受阴影部分代码 AutoLight.cginc脚本
				UNITY_LIGHT_ATTENUATION(att,i,wPos);

				col *= att;
				
				return fixed4(col,1);
			}
			ENDCG
		}
	}
}
