// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Hidden/Diffuse"
{
	Properties
	{
		
	}
	SubShader
	{

		Tags { "LightMode" = "Forwardbase" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 normal : TEXCOORD0;
			};


			//顶点着色器计算光照的执行效率高,但不会那么平滑
			v2f vert (appdata v)
			{
				
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = v.normal;

				return o;
			}
			
			sampler2D _MainTex;


			//片段着色器计算光照较慢但会显得更加平滑
			fixed4 frag (v2f i) : SV_Target
			{
				//漫反射： 光照颜色  * dot（NormalDir*LightDir） +  环境光

				//方法1.将模型空间变换为世界空间(若物体发生非等比缩放时，该方法会出错,应该用一个模型到世界矩阵的逆矩阵的转置矩阵来做变换)
				//v.normal = mul(unity_ObjectToWorld,v.normal);
				//方法1正确写法：
				float3 normal = mul(float4(i.normal,0),unity_WorldToObject).xyz;

				//注：该地方使用的模型空间的法向量。现在造成的结果就是，该顶点的法向量在模型空间中是一直不会变化的，那么该顶点的法向量就一直与光照向量（也是固定不变的）点乘，最后怎么旋转都没用
				//查看并启用其中某一个方法
				normal = normalize(normal);

				float3 light = normalize(_WorldSpaceLightPos0);

				//方法2.将世界空间的光向量变换为模型空间下的光向量

				//light = mul(unity_WorldToObject,float4(light,0)).xyz;

				float dotValue = max(0,dot(normal,light));

				fixed4 col = _LightColor0   * dotValue + UNITY_LIGHTMODEL_AMBIENT;

				//o.color = _LightColor0   * dotValue + UNITY_LIGHTMODEL_AMBIENT;	


				return col;
			}
			ENDCG
		}
	}
}
