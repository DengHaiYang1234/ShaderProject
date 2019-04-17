Shader "Mask"
{
	Properties
	{
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_Cutoff("Cutoff",Float) = 0.5
		}

		SubShader
		{
			Tags { "RenderType"="TransparentCutout" "Queue"="Geometry" }

			LOD 100
			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"


				struct appdata
				{
					float4 vertex : POSITION;
					float4 ase_texcoord : TEXCOORD0;
				};

				struct v2f
				{
					float4 vertex : SV_POSITION;
					float4 ase_texcoord : TEXCOORD0;
					};

					uniform sampler2D _TextureSample0;
					uniform sampler2D _TextureSample1;
					uniform float4 _TextureSample1_ST;
					float _Cutoff;
					v2f vert ( appdata v )
					{
						v2f o;
						o.ase_texcoord.xy = v.ase_texcoord.xy;

						o.ase_texcoord.zw = 0;

						v.vertex.xyz +=  float3(0,0,0) ;
						o.vertex = UnityObjectToClipPos(v.vertex);
						return o;
					}

					fixed4 frag (v2f i ) : SV_Target	
					{
						fixed4 finalColor;

						float2 div = (_TextureSample1_ST.xy / 2.0) + _TextureSample1_ST.zw;
						float rot = 50.0 * _Time.y;

						i.ase_texcoord.xy-= div;

						float s, c;
						sincos(radians(rot), s, c);
						float2x2 rotMatrix = float2x2(c, -s, s, c);

						i.ase_texcoord.xy = mul(i.ase_texcoord.xy, rotMatrix);
						i.ase_texcoord.xy += div;

						float4 tex2DNode4 = tex2D( _TextureSample0, i.ase_texcoord.xy );
						float2 uv_TextureSample1 = i.ase_texcoord.xy * _TextureSample1_ST.xy + _TextureSample1_ST.zw;

						float4 appendResult10 = (float4(tex2DNode4.r , tex2DNode4.g , tex2DNode4.b , tex2D( _TextureSample1, uv_TextureSample1 ).a));

						finalColor = appendResult10;
						clip( appendResult10.a - _Cutoff );

						fixed4 col = tex2D(_TextureSample0, i.ase_texcoord);

						return col;
					}
					ENDCG
				}
			}
			Fallback"Diffuse"
		}
