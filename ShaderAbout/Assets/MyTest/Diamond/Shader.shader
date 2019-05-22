Shader "Hidden/Shader"
{
	Properties
	{
		_Cubemap("CubMap",CUBE) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct appdata members vertex,normal)
			#pragma exclude_renderers d3d11
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
				float4 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 normal : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
				float4 uv :TEXCOORD2; 
			};

			#define REFRACT_INDEX float3(2.407, 2.426, 2.451)
			#define REFRACT_SPREAD float3 (0.0, 0.02, 0.05) // This is not physically based, just from the top of my head 
			#define MAX_BOUNCE 5
			#define COS_CRITICAL_ANGLE 0.91
			samplerCUBE _Cubemap;

			v2f vert (appdata v)
			{
				v2f o;
				float3 objectCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos);
				o.viewDir = normalize(v.vertex - objectCamera);
				o.normal = v.normal;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				float3 viewDir = normalize(i.viewDir);
				float3 normal = normalize(i.normal);
				float3 reflectDir = reflect(viewDir, normal);
				float fresnelFactor = pow(1 - abs(dot(viewDir, normal)), 2);

				float3 reflectDirW = mul(float4(reflectDir, 0.0), unity_WorldToObject);
				float4 col = texCUBE(_Cubemap, reflectDirW);
				col.rgb = col.rgb * fresnelFactor;

				// Divide 1 by refraction index, since we entering to diamond from air 
				float3 inDir = refract(i.viewDir, i.normal, 1.0/REFRACT_INDEX.r);
				// Direction to sample environment cubemap for different colors
				float3 inDirR, inDirG, inDirB;
				for (int bounce = 0; bounce < MAX_BOUNCE; bounce++)
				{
  					// Convert normal to -1, 1 range
  					float3 inN = texCUBE(_Cubemap, inDir) * 2.0 - 1.0;
  					if (abs(dot(-inDir, inN)) > COS_CRITICAL_ANGLE)
  					{
    					// The more bounces we have the heavier dispersion should be
    					inDirR = refract(inDir, inN, REFRACT_INDEX.r);
    					inDirG = refract(inDir, inN, REFRACT_INDEX.g + bounce * REFRACT_SPREAD.g);
    					inDirB = refract(inDir, inN, REFRACT_INDEX.b + bounce * REFRACT_SPREAD.b);
    					break;
  					}

  				// We didn't manage to exit diamond in MAX_BOUNCE
  				// To be able exit from diamond to air we need fake our refraction 
  				// index other way we'll get float3(0,0,0) as return
  					if (bounce == MAX_BOUNCE-1)
  					{
    					inDirR = refract(inDir, inN, 1/ REFRACT_INDEX.r);
    					inDirG = refract(inDir, inN, 1/ (REFRACT_INDEX.g + bounce * REFRACT_SPREAD.g));
    					inDirB = refract(inDir, inN, 1/ (REFRACT_INDEX.b + bounce * REFRACT_SPREAD.b));
    					break;
  					}
  					inDir = reflect(inDir, inN);
				}
				// Convert to world space
				inDirR = mul(float4(inDirR, 0.0), unity_WorldToObject);
				inDirG = mul(float4(inDirG, 0.0), unity_WorldToObject);
				inDirB = mul(float4(inDirB, 0.0), unity_WorldToObject);
				col.r += texCUBE(_Cubemap, inDirR).r;
				col.g += texCUBE(_Cubemap, inDirG).g;
				col.b +=  texCUBE(_Cubemap, inDirB).b;

				return col;
			}
			ENDCG
		}
	}
}
