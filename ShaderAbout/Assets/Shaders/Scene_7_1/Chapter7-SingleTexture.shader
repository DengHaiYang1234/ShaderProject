// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/ Chapter 5/Single Texture"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		//2D是纹理属性的声明方式，white是纹理内置的名字，也就是一个全白的纹理
		_MainTex("Main Tex",2D) = "white"{}
			//镜面
			_Specular("Specular",Color) = (1,1,1,1) 
			//	光泽
			_Gloss("Gloss",Range(8.0,256)) = 20	
	}

	

	SubShader
	{
		Pass
		{
			//LightMode标签是Pass标签中的一种，它用来定义尬Pass在Unity的光照流水线中的角色
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag


			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			//纹理名_ST,其中，ST是缩放和平移的缩写,_MainTex_ST可以得到该纹理的缩放和平移（偏移）值
			//_MainTex_ST.xy存储的是缩放值  _MainTex_ST.zw存储的是偏移值
			float4 _MainTex_ST;
			fixed4 _Specular;
			float4 _Gloss;


			struct a2v
			{
				//模型空间的顶点坐标填充vertex
				float4 vertex : POSITION;
				//模型空间的法线向量填充normal
				float3 normal : NORMAL;
				//模型空间的第一组纹理坐标填充特texcoord
				float4 texcoord : TEXCOORD0;
			};


			struct v2f
			{
				//变换坐标
				float4 pos : SV_POSITION;
				//法线
				float3 worldNormal : TEXCOORD0;
				//世界坐标
				float3 worldPos : TEXCOORD1;
				//用于存储纹理坐标的变量uv，以便在片元着色器中使用该坐标进行纹理采样
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;

				//坐标变换至世界空间
				o.pos = UnityObjectToClipPos(v.vertex);
				//把法线方向从模型空间转换到世界空间中
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				//将模型空间的坐标变换到世界空间中
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				//变换顶点纹理坐标，先缩放后平移    或者o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);  定义在UnityCG.cginc
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				return o;
			}


			fixed4 frag(v2f i) : SV_Target
			{
				//世界空间下的法线方向
				fixed3 worldNormal = normalize(i.worldNormal);
				//世界空间下的光照方向    输入一个模型空间中的顶点位置，返回世界空间中从该点到光源的光照方向。没有被归一化
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				//使用Cg的tex2D函数对纹理进行采样。
				//它的第一个参数是需要被采样的纹理，第二个参数是一个float2类型的纹理坐标，它将返回计算得到的纹素值。
				//使用采样结果和颜色属性_Color的乘积来作为材质的反射率albedo
				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
				//环境光照乘以反射率得到环境光部分
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				//计算漫反射
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,worldLightDir));
				//输入一个模型空间中的顶点位置，返回模型空间中从该点到摄像机的观察方向,没有被归一化
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				fixed3 halfDir = normalize(worldLightDir + viewDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal,halfDir)),_Gloss);

				return fixed4(ambient + diffuse + specular,1.0);
			}
			ENDCG
		}
	}
	
	Fallback "Specular"
}