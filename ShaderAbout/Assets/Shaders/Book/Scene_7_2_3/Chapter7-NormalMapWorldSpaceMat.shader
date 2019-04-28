// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader  "Unity Shaders Book/ Chapter 7/Normal Map World Space Mat"
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
			float4 tangent : TANGENT;
			float4 texcoord : TEXCOORD0;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			float4 uv : TEXCOORD0;
			float4 TtoW0 : TEXCOORD1;
			float4 TtoW1 : TEXCOORD2;
			float4 TtoW2 : TEXCOORD3;
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

			float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
			fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
			fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
			fixed3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;

			o.TtoW0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
			o.TtoW1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
			o.TtoW2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

			return o;
		}

		fixed4 frag(v2f i) :SV_Target
		{
			float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);

			fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
			fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

			fixed3 bump = UnpackNormal(tex2D(_BumpMap,i.uv.zw));
			bump.xy *= _BumpScale;
			bump.z = sqrt(1.0 - saturate(dot(bump.xy,bump.xy)));

			bump = normalize(half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));

			//反射
			fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
			//环境光
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
			//使用_LightColor0 时一定要 #include "Lighting.cginc"
			fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(bump,lightDir));
			fixed3 halfDir = normalize(lightDir + viewDir);

			fixed3 specular =  _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(bump,halfDir)),_Gloss);

			return fixed4(ambient + diffuse + specular,1.0);
		}

		ENDCG

		}
	}
	Fallback "Specular"
}
	
