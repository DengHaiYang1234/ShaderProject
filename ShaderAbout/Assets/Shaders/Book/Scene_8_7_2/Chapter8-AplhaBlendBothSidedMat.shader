Shader "Unity Shaders Book/ Chapter 8/Alpha Blend Both Side Mat"
  {
      Properties
      {
          _Color("Main Tint",Color) = (1,1,1,1)
          _MainTex("Main Texture", 2D) = "white" {}
          _AlphaScale("Alpha Scale",Range(0,1)) = 1
     }
 
     SubShader
     {
        //得到双面的效果必须保证背面是在正面之前被渲染，得到正确的深度渲染关系
         Pass
        {
             Tags
             {
                 "LightMode" = "ForwardBase"
             }

             //只渲染背面
             Cull Front
 
             ZWrite Off
            //开启并设置了Pass的混合模式
            //将源颜色（该片元着色器产生的颜色）的混合因子设置SrcAlpha
            //把目标颜色（已经存在于颜色缓冲中的颜色）的混合因子设为OneMinusSrcAlpha，以得到半透明的效果
            Blend SrcAlpha OneMinusSrcAlpha


            CGPROGRAM

            #pragma vertex vert 
            #pragma fragment frag 

            #include "Lighting.cginc"
            #include "UnityCG.cginc"



            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaScale;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);

                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed4 texColor = tex2D(_MainTex,i.uv);

                fixed3 albedo = texColor.rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,worldLightDir));

                return fixed4(ambient + diffuse,texColor.a * _AlphaScale);
            }

            ENDCG
        }

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            //只渲染正面
            Cull Back
            //Pass的深度写入关闭
            ZWrite Off
            //开启并设置了Pass的混合模式
            //将源颜色（该片元着色器产生的颜色）的混合因子设置SrcAlpha
            //把目标颜色（已经存在于颜色缓冲中的颜色）的混合因子设为OneMinusSrcAlpha，以得到半透明的效果
            Blend SrcAlpha OneMinusSrcAlpha


            CGPROGRAM

            #pragma vertex vert 
            #pragma fragment frag 

            #include "Lighting.cginc"
            #include "UnityCG.cginc"



            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaScale;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);

                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed4 texColor = tex2D(_MainTex,i.uv);

                fixed3 albedo = texColor.rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,worldLightDir));

                return fixed4(ambient + diffuse,texColor.a * _AlphaScale);
            }

            ENDCG
        }


     }
 
     Fallback "Diffuse"
 }