//用来渲染弯曲的结构
Shader "Unity Shaders Book/ Chapter 8/Alpha Blend ZWrite"
{
	Properties
	{
		_Color("Main Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "white" {}
		_AlphaScale("Alpha Scale",Range(0,1)) = 1
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}

		//该Pass的目的仅仅是为了把模型的深度信息写入深度缓冲中，从而剔除模型中被自身遮挡的片元
		//Pass的第一行开启了深度写入
		//第二行，我们使用了一个新的渲染命令ColorMas看k，在ShaderLab中，是用于设置颜色通道的写掩码。当ColorMask为0时，该Pass不写入任何颜色通道，不输出任何颜色
		Pass
		{
			ZWrite On 
			ColorMask 0
		}



		Pass
		{
			Tags {"LightMode" = "ForwardBase"}
			//Pass的深度写入关闭
			ZWrite Off
			//开启并设置了Pass的混合模式
			//将源颜色（该片元着色器产生的颜色）的混合因子设置SrcAlpha
			//把目标颜色（已经存在于颜色缓冲中的颜色）的混合因子设为OneMinusSrcAlpha，以得到半透明的效果
			Blend SrcAlpha OneMinusSrcAlpha


			CGPROGRAM

			#pragma vertex vert 
			#pragma fragment frag 

			#include "Lighting.cginc"
			#include "UnityCG.cginc"



			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _AlphaScale;

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

				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed4 texColor = tex2D(_MainTex,i.uv);

				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,worldLightDir));

				return fixed4(ambient + diffuse,texColor.a * _AlphaScale);
			}

			ENDCG
		}
	}

	FallBack "Transparent/VertexLit"
}