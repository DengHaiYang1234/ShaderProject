// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TwoSided"
{
	Properties
	{
		_FrontTex("Front Tex",2D) = "white" {}
		_BackTex("Back Tex",2D) = "white" {}
	}

	SubShader
	{
		cull off
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag 
			#pragma target 3.0

			sampler2D _FrontTex;
			sampler2D _BackTex;

			struct a2v 
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}
			
			//如果渲染表面朝向摄像机，则Face节点输出正值1，如果远离摄像机，则输出负值-1。
			fixed4 frag(v2f i,float face : VFACE) : SV_Target
			{
				fixed4 col = 1;
				col = face > 0 ? tex2D(_FrontTex,i.uv) : tex2D(_BackTex,i.uv);
				return col;
			}


			ENDCG
		}
	}
}