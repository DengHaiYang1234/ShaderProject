// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/ Chapter 6/BlinnPhong Use Build In Function"
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
			#pragma fragment farg

			#include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;


			struct a2v
			{
				float4 vertx : POSITION;
				fixed3 normal : NORMAL;
			};


			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};


			v2f vert(a2v v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertx);

				o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);

				o.worldPos = mul(unity_ObjectToWorld,v.vertx);

				return o;
			}


			fixed4 farg(v2f i) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(i.worldNormal);

				fixed3 wolrdLightDir = normalize(_WorldSpaceLightPos0.xyz);

				float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,wolrdLightDir));

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

				//Blinn模型
				//fixed3 relfectDir = (reflect(-wolrdLightDir,worldNormal));
				//BlinnPhong 模型

				fixed3 halfDir = normalize(wolrdLightDir + viewDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir,viewDir)),_Gloss);

				return fixed4(ambient + diffuse + specular,1.0);

			}

			ENDCG
		}
	}

	Fallback "Specular"
}