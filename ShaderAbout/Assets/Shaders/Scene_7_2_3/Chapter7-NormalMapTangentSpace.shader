// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//P151
//https://www.jianshu.com/p/d04ce432a4ee
Shader "Unity Shaders Book/ Chapter 7/Normal Map Tangent Space"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "white" {}
		_BumpMap("Normal Map",2D) = "bump" {}
		_BumpScale("Bump Scale",Float) = 1.0
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
			//纹理名_ST 声明某个纹理的属性，ST是缩放和 平移的缩写。.xy是缩放值 .zw是平移值
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT; //切线
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				//对顶点纹理坐标进行相应的变换  类似于  o.uv = v.texcoord.xy * float2(1,1) + float2(0,0) 和 o.uv = TRANSFORM_TEX(v.texcoord,_Main_TEX)
				//TRANSFORM_TEX主要作用是拿顶点的uv去和材质球的tiling和offset作运算， 确保材质球里的缩放和偏移设置是正确的。 
				//将模型顶点的uv和Tiling、Offset两个变量进行运算，计算出实际显示用的定点uv
				//其中v是appdata_base类型，v.texcoord就是模型顶点的uv数据。
				//_MainTex是使用的图片。
				//name##_ST实际上就是_MainTex_ST。
				//name##_ST.xy就是Tiling的xy值。
				//name##_ST.zw就是Offset的xy值。
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				//叉乘 得到的副切线方向    
				//最后乘以v.tangent.w 是因为切线和法线方向都垂直的方向有两个 而w决定了我们选择其中哪一个方向
				float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz)) * v.tangent.w;

				//切线方向  副切线方向  法线方向    得到从模型空间到切线空间的变换矩阵
				float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);
				//得到rotation变换矩阵
				//TANGENT_SPACE_ROTATION;

				//将得到的光照方向变换到切线空间中去
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
				//比如bump类型纹理上存储的值代表的含义是该点的法向量，而普通纹理一般代表的是该点的颜色值），具体过程是根据对应uv坐标（i.uv.zwp）在_BumpMap类型纹理（_BumpMap）上得到该点存储的值
				fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);

				fixed3 tangentNormal;

				tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;

				//开根号
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));

				//贴图的normalMap 
				tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));

				//反射
				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				//使用_LightColor0 时一定要 #include "Lighting.cginc"
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(tangentNormal,tangentLightDir));
				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);

				fixed3 specular =  _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(tangentNormal,halfDir)),_Gloss);

				return fixed4(ambient + diffuse + specular,1.0);


			}


			ENDCG
		}
	}
}