Shader "Hidden/Wave"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Amount("Amount",Range(0.0,1.0)) = 0
		_W("ω",Range(0,100)) = 0
		_Speed("Speed",Range(0,500)) = 0
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
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

			fixed _Amount;
			float _Speed;
			float _W;

			fixed4 frag (v2f i) : SV_Target
			{
				//正弦曲线公式：y = A sin(ωx)  A正弦 函数的幅度（振幅）,相当于在y轴上扩大A倍；ωx代表周期缩短了1/ω倍,即2π/ω,ω=1时候周期2π,ω=2时候周期π
				//相当与就是A决定波的范围；而ω决定波的疏密程度
				//在波形移动的时候需要注意的是：振幅A变大，波形在y轴上最大与最小值的差值变大；
				//振幅A变小，则相反；角速度ω变大，则波形在X轴上收缩（波形变紧密）；角速度ω变小，则波形在X轴上延展（波形变稀疏）
				//正弦函数原点对称（奇函数），余弦函数y轴对称（偶函数）

				//中心uv
				fixed2 center_uv = (0.5,0.5);

				float2 uv = i.uv;
				//其他uv到中心uv的距离
				float2 distance = center_uv - uv;
				//距离公式
				float len = sqrt(dot(distance,distance));
				//计算振幅  速度*（与距离目标uv的距离）的乘积
				float amount = _Amount / (0.1 + len * _Speed);
				//平滑度
				amount = amount < 0.001 ? 0 : amount;
				//正弦曲线公式
				uv.y += amount * cos(len * _W * UNITY_PI);
				
				fixed4 col = tex2D(_MainTex, uv);

				return col;
			}
			ENDCG
		}
	}
}
