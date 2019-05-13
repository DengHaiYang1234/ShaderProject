Shader "Hidden/OutLine"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_OutLineColor("Outline Color",Color) = (1,1,1,1)
		_Outline("Outline Width",Range(0,2)) = 0.1
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
		Blend SrcAlpha OneMinusSrcAlpha


		Pass
		{
			Tags
			{
				"Queue" = "Transparent"
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;

			//纹理的像素大小
			float4 _MainTex_TexelSize;

			float _Outline;

			fixed4 _OutLineColor;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex,i.uv);

				//获取uv的上下左右uv   并设置其宽度
				float2 uv_up = i.uv + _MainTex_TexelSize * float2(0,1) * _Outline;

				float2 uv_down = i.uv + _MainTex_TexelSize * float2(0,-1) * _Outline;

				float2 uv_left = i.uv + _MainTex_TexelSize * float2(1,0) * _Outline;

				float2 uv_right = i.uv + _MainTex_TexelSize * float2(-1,0) * _Outline;

				//检测是否有alpha为0的情况
				float w = tex2D(_MainTex,uv_up).a * tex2D(_MainTex,uv_down).a * tex2D(_MainTex,uv_left).a * tex2D(_MainTex,uv_right).a;

				//当alpha为0时，混合描边颜色
				col.rgb = lerp(_OutLineColor,col.rgb,w);

				return col;
			}
			ENDCG
		}
	}
}
