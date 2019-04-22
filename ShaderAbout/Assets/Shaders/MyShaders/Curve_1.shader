// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CurveTest/Curve_2"
{
	Properties
	{
		_MainTex("Base (RGB)",2D) = "white" {}
		
		//_What("What",float) = 200.0

		_XOffest("X",float) = 0

		_YOffest("Y",float) = 0

		_ZOffest("Z",float) = 0
    }



    SubShader
    {
    	Pass
    	{
    		CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;

			float4 _What;

			float _XOffest;

			float _YOffest;

			float _ZOffest;

			struct v2f
			{
				float4 pos : POSITION;
				float4 uv : TEXCOORD0;
			};

			v2f vert(appdata_full v)
			{
				v2f o;
				float4 vPos = mul(UNITY_MATRIX_MV,v.vertex);
				float zOff = vPos.z / 10;
				vPos += float4(_XOffest,_YOffest,_ZOffest,0) * zOff * zOff;
				o.pos = mul(UNITY_MATRIX_P,vPos);
				o.uv = v.texcoord;
				return o;
			}	

			half4 frag(v2f i) : COLOR
			{
				half4 col = tex2D(_MainTex,i.uv.xy);
				return col;
			}


			ENDCG
    	}
    }

     FallBack "Diffuse"

}

