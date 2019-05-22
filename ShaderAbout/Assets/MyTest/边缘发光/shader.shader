// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/shader"
{
	Properties
	{
		_Scale("Scale",Range(1.0,5.0)) = 1.0
		_OutRange("OutRange",Range(0,1)) = 0.2
		_MainColor("MainColor",Color) = (1,1,1,1)
	}
	SubShader
	{

		Tags {"Queue" = "Transparent"}
		//由内向外的透明的混合
		Pass
		{
			//透明混合
			Blend SrcAlpha OneMinusSrcAlpha
			//关闭深度写入
			ZWrite off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal :NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 vertex : TEXCOORD0;
				float3 normal :TEXCOORD1;
			};

			float _OutRange;
			
			v2f vert (appdata v)
			{
				v.vertex.xyz += v.normal * _OutRange;
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.vertex = v.vertex;
				o.normal = v.normal;
				return o;
			}

			float _Scale;

			fixed4 _MainColor;
			
			fixed4 frag (v2f i) : SV_Target
			{
				//世界空间下的法向量
				float3 N = normalize(mul(float4(i.normal,0),unity_WorldToObject).xyz);	

				float4 worldPos = mul(unity_ObjectToWorld,i.vertex);
				//视图向量
				float3 V = _WorldSpaceCameraPos.xyz - worldPos.xyz;

				V = normalize(V);

				//亮光由内向外扩散
				float bright = dot(N,V);

				bright = pow(bright,_Scale);

				//只改变透明度
				_MainColor.a *= bright;

				//fixed4 col = fixed4(1,1,1,1) * bright;

				return _MainColor;
			}
			ENDCG
		}

		Pass
		{
			//上Pass - 当前Pass
			Blendop RevSub
			//dstalpha：这个阶段的值乘以源alpha的值
			//one：上一次pass的计算全部通过
			Blend dstalpha one

			ZWrite off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;

			};

			struct v2f
			{
				float4 pos : SV_POSITION;

			};

			fixed4 _MainColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				return fixed4(1,1,1,1);
			}
			ENDCG
		}


		//由外向内的透明+颜色的混合
		Pass
		{
			//透明混合
			Blend SrcAlpha OneMinusSrcAlpha
			//关闭深度写入
			ZWrite off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal :NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 vertex : TEXCOORD0;
				float3 normal :TEXCOORD1;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.vertex = v.vertex;
				o.normal = v.normal;
				return o;
			}

			float _Scale;
			
			fixed4 frag (v2f i) : SV_Target
			{
				//世界空间下的法向量
				float3 N = normalize(mul(float4(i.normal,0),unity_WorldToObject).xyz);	

				float4 worldPos = mul(unity_ObjectToWorld,i.vertex);
				//视图向量
				float3 V = _WorldSpaceCameraPos.xyz - worldPos.xyz;

				V = normalize(V);

				float bright = 1 - dot(N,V);

				bright = pow(bright,_Scale);

				fixed4 col = fixed4(1,1,1,1) * bright;

				return col;
			}
			ENDCG
		}
	}
}
