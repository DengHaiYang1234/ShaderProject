Shader "Custom/SurfaceShader" {
	Properties {

		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_CenterPos("CenterPos",Range(-3.98,3.98)) = 0
		_R("R",Range(0,0.5)) = 0.2
		_MainColor("MainClolr",Color) = (1,1,1,1)
		_SColor("SColor",Color) = (1,1,1,1)
	}
	SubShader 
	{
		Tags { "RenderType" = "Opaque" }
		LOD 200
     	CGPROGRAM
     	//这句话不要加，暂时不知道什么原因
     	//#pragma surface surf Standard fullforwardshadows
     	#pragma surface surf Standard vertex:vert
		//Standard

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float posX;
		};

		void vert(inout appdata_full v, out Input o)
		{
			 UNITY_INITIALIZE_OUTPUT(Input,o);
			 o.uv_MainTex = v.texcoord.xy;
			o.posX = v.vertex.z;
		}

		half _Glossiness;
		half _Metallic;

		float _R;
		float _CenterPos;

		fixed4 _MainColor;
		fixed4 _SColor;


		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;

			float d = IN.posX - _CenterPos;

			float absD = abs(d);

			float t = absD / _R;

			d *= t;

			d =  d / 2 + 0.5;


			o.Albedo *= lerp(_MainColor,_SColor,d);

		}
		ENDCG
	}
	FallBack "Diffuse"
}
