using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostEffect : PostEffectBase
{
    [Range(0,16)]
    public int times = 1; //高斯混合次数
	// Use this for initialization
	void Start ()
    {
		Check();
	}
	
	// Update is called once per frame
	void Update () 
    {
		
	}

    void OnRenderImage(RenderTexture src,RenderTexture des)
    {
        if(effect_enable)
        {
            //思路：将高斯混合的结果再次进行高斯混合
            RenderTexture temp1 = new RenderTexture(src.width,src.height,src.depth);
            RenderTexture temp2 = new RenderTexture(src.width,src.height,src.depth);

            //将获取到的rendertexture拷贝给temp1
            Graphics.Blit(src,temp1);

            for(int i = 0;  i< times;i++)
            {
                //将temp1的rendertexture拷贝至temp2
                Graphics.Blit(temp1,temp2,meterial);
                Graphics.Blit(temp2,temp1);
            }

            Graphics.Blit(temp1,des,meterial);

            temp1.Release();
            temp2.Release();
        }
        else
        {
            Graphics.Blit(src,des);
        }
    }
}
