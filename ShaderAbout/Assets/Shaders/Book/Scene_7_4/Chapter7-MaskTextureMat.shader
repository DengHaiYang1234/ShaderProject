// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/ Chapter 7/MaskTextureMat" {
	Properties 
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "White" {}
		_BumpMap("Normal Tex",2D) = "bump" {}
		_BumpScale("Bump Scale",float) = 1.0
		//高光遮罩纹理
		_SpecularMask("Specular Mask",2D) = "white" {}
		_SpecularScale("Specular Scale",float) = 1.0
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

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _Maintex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			sampler2D _SpecularMask;
			float4 _SpecularMask_ST;
			float _SpecularScale;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : Normal;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
				float2 uvSpecular : TEXCOORD3;
			};

			v2f vert(a2v v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				//就是将模型顶点的uv和Tiling、Offset两个变量进行运算，计算出实际显示用的顶点uv。
				o.uv.xy = v.texcoord.xy * _Maintex_ST.xy + _Maintex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				o.uvSpecular = v.texcoord.xy * _SpecularMask_ST.xy + _SpecularMask_ST.zw;
				// 定义转换world space的向量到tangent space的rotation 矩阵。
				TANGENT_SPACE_ROTATION;
				//输入模型空间的顶点位置，返回模型空间下从该点到光源的光照方向
				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;

				o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 tangentLightDir = normalize(i.lightDir);

				fixed3 tangentViewDir = normalize(i.viewDir);
				//利用tex2D对法线纹理_BumpMap采样
				//tex2D作用仅仅是通过一个二维uv坐标在纹理上获取该处值，根据纹理的类型不同，获取的值的含义也不一样，
				//比如bump类型纹理上存储的值代表的含义是该点的法向量，而普通纹理一般代表的是该点的颜色值），具体过程是根据对应uv坐标（i.uv）在_BumpMap类型纹理（_BumpMap）上得到该点存储的值
				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap,i.uv.zw));
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));
				//反射率
				fixed3 albedo = tex2D(_MainTex,i.uv.xy).rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(tangentNormal,tangentLightDir));

				fixed3 halfdir = normalize(tangentLightDir + tangentViewDir);
				//先对遮罩进行采样  选择使用r分量来计算掩码值与_SpecularScale相乘.一起来控制高光反射的强度
				fixed specularMask = tex2D(_SpecularMask,i.uvSpecular).r * _SpecularScale;
				//用高光遮罩来计算高光放射的值
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(tangentNormal,halfdir)),_Gloss) * specularMask;

				return fixed4(ambient + diffuse + specular,1.0);
			}


			ENDCG
		}
	}
	FallBack "Diffuse"
}
