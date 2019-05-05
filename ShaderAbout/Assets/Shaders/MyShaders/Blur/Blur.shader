// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Blur/Blur"
{
	Properties
	{
		_MainTex("_Main Tex",2D) = "white" {}

		_CutOff("CurOff",float) = 0.0
	}

	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass
		{

						Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM



			#pragma vertex vert 
			#pragma fragment frag 

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _CutOff;


			struct a2v
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};


			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			v2f vert(a2v v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float2 tempUV = i.uv;

				fixed4 col = tex2D(_MainTex,tempUV);

				_CutOff = _CutOff * i.worldPos.z;

				//左
				fixed4 clo12 = tex2D(_MainTex,tempUV + float2(-_CutOff,0));
				//下
				fixed4 clo13 = tex2D(_MainTex,tempUV + float2(0,-_CutOff));
				//右
				fixed4 clo14 = tex2D(_MainTex,tempUV + float2(_CutOff,0));
				//上
				fixed4 clo15 = tex2D(_MainTex,tempUV + float2(0,_CutOff));

				col = (col + clo12 + clo13 + clo14 + clo15) / 5;

				return col;
			}


			ENDCG
		}
	}
}