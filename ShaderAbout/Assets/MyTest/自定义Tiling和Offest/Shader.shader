Shader "Hidden/Shader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Tiling_X("Ttiling_X",float) = 1
		_Tiling_Y("Ttiling_Y",float) = 1
		_Offest_X("_Offest_X",float) = 0
		_Offest_Y("_Offest_Y",float) = 0
	}



	SubShader
	{
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

			float _Offest_X;
			float _Offest_Y;
			float _Tiling_X;
			float _Tiling_Y;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.uv.x *= _Tiling_X;
				o.uv.y *= _Tiling_Y;

				o.uv.x += _Offest_X;
				o.uv.y += _Offest_Y;


				return o;
			}
			
			sampler2D _MainTex;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
