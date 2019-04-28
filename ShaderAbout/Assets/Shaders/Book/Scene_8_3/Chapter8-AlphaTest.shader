// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/ Chapter 8/Alpha Test"
{
	Properties
	{
		_Color("Main Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "white" {}
		_Cutoff("Alpha Cutoff",Range(0,1)) = 0.5
	}

	SubShader
	{
		//通常使用AlphaTest的shader 都要设置这三个标签
		//1.设置队列为AlphaTest队列
		//2.RenderType标签可以让Unity把这个Shader归入到提前定义的组中，以指明Shader是一个使用了透明度测试的Shader
		//3.IngnoreProjector设置为true，意味着这个shader不会受到投影器的影响
		Tags {"Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout"}

		Pass
		{
			//定义该Pass在Unity的光照流水线中的角色
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma vertex vert 
			#pragma fragment frag 

			#include "Lighting.cginc"
			#include "UnityCG.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Cutoff;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				//获取世界空间下的光照方向
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed4 texColor = tex2D(_MainTex,i.uv);

				//若为负数，那么就会舍弃该片元的输出(也就是说会产生完全透明的效果)  同下面的if
				clip(texColor.a - _Cutoff);

				
				//if((texColor.a - _Cutoff) < 0)
				//{
					//discard;
				//}
				//反射率
				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,worldLightDir));

				return fixed4(ambient + diffuse,1.0);
			}

			ENDCG

		}
	}
	FallBack "Tramsparent/Cutout/VertexLit"
}