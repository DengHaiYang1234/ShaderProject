// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'



Shader "Unity Shaders Book/ Chapter 5/Simple Shader"{
	Properties
	{
		//声明一个Color类型的属性
		_Color("Color Tint",Color) = (1.0,1.0,1.0,1.0)
	}

	// float4 与 fixed4 区别：精度的区别，前者精度更高，计算时消耗更大。

	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			//使用一个结构体来定义顶点着色器的输入  a:Appliccatin 应用  v:vertex shader 顶点着色器  a2v就是把数据从应用层阶段传递到顶点着色器中
			struct a2v
			{
				//填充这些语义的数据是由Mesh Render 组件提供的.

				//POSITION语义告诉Unity，用模型空间的顶点坐标填充vertex变量
				float4 vertex : POSITION;
				//NORMAL语义告诉Unity，用模型空间的法线方向填充normal变量
				float3 normal : NORMAL;
				//TEXCOORD0语义告诉Unity，用模型的第一套纹理坐标填充个texcoord变量
				float4 texcoord : TEXCOORD0;
			};

			//使用一个结构体来定义顶点着色器的输出   用于顶点着色器和片元着色器之间传递信息
			//顶点着色器的输出结构中，必须包含一个变量，它的语义是SV_POSITION，否则渲染器无法得到裁剪空间中的顶点坐标，也就无法把顶点渲染到屏幕上。
			struct v2f
			{
				//SV_POSITION 语义告诉Unity，Pos里包含了顶点在裁剪空间中的位置信息
				float4 pos : SV_POSITION;
				//COLOR 语义可以用于存储颜色信息。
				fixed3 color : COLOR;
			};



			v2f vert(a2v v)
			{
				//声明输出结构
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//v.normal包含了顶点的法线方向，其分量范围在[-1.0,1.0]
				//下面的代码把分量范围映射到了[0.0,1.0]
				//存储到o.color中传递给片元着色器
				o.color = v.normal * 0.5 + fixed3(0.5,0.5,0.5);
				return o;
			}


			fixed4 frag(v2f i) : SV_Target
			{
				//将插值后的i.color显示到屏幕上
				return fixed4(i.color,1.0);
			}

			//接收一个a2v结构体的输入 SV_POSITION是输出
			// float4 vert(a2v v) :SV_POSITION
			// {
			// 	return UnityObjectToClipPos(v.vertex);
			// }

			// fixed4 frag() : SV_Target{
			// 	return fixed4(1.0,1.0,1.0,1.0);
			// }

			ENDCG
		}

	}
}