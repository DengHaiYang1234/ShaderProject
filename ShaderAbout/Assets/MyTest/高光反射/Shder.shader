// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Hidden/Shder"
{
	Properties
	{
		//光泽度（衰减）
		_Shininess("Shininess",Range(1,10)) = 4
		_SpecularColor("SpecularColor",Color) = (1,1,1,1)
	}

	SubShader
	{
		// No culling or depth
		//Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};



			struct v2f
			{
				float3 normal : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.normal = v.normal;
				
				return o;
			}
			
			
			float _Shininess;
			float4 _SpecularColor;

			fixed4 frag (v2f i) : SV_Target
			{

				float3 worldNormal = mul(i.normal,unity_WorldToObject).xyz;

				float3 normalDir = normalize(worldNormal);

				float3 lightDir = normalize(_WorldSpaceLightPos0).xyz;

				float dotValue = saturate(dot(normalDir,lightDir));

				fixed4 col = _LightColor0  * dotValue + UNITY_LIGHTMODEL_AMBIENT;

				//高光反射
				//入射光
				float3 in_LightDir = -normalize(_WorldSpaceLightPos0).xyz;
				//反射光
				float3 R = normalize(reflect(in_LightDir,normalDir));

				//视野方向(世界空间下视图位置)
				float3 viewDir = normalize(WorldSpaceViewDir(i.vertex));

				float specularScale = pow((saturate(dot(viewDir,R))),_Shininess);

				col.rgb += _SpecularColor * specularScale;

				return col;
			}
			ENDCG
		}
	}
}
