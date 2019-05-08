Shader "Hidden/GradualChange"
{
	Properties
	{
		_MainTex ("Main Tex", 2D) = "white" {}
		_RampTex("Ramp Tex",2D) = "white" {}
		//混合图的偏移量
		_Offest("Ramp Offest",Range(0.0,1.0)) = 0
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
		//开启透明度混合（不开启会有一些部分是不透明的，显得很怪）    RGBA中A的值将无法生效
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
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

			sampler2D _RampTex;

			float _Offest;

			fixed4 frag (v2f i) : SV_Target
			{

				fixed4 main_col = tex2D(_MainTex, i.uv);
				//偏移量是随着时间的sin
				_Offest = _SinTime.w;

				fixed4 ramp_col = tex2D(_RampTex, i.uv + _Offest);

				float w = 0.5;

				//混合   原图的占比权重为0.1   混合图的占比权重为0.9
				//.rgb 是为了剔除多余的部分
				main_col.rgb = main_col * w + ramp_col * (1 - w);

				// just invert the colors
				//col = 1 - col;
				return main_col;
			}
			ENDCG
		}
	}
}
