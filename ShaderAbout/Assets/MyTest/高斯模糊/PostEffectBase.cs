using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectBase : MonoBehaviour
{
    public Shader shader;
    public Material meterial;


    protected bool effect_enable = false;

    void Start()
    {
        Debug.LogError("1111");
        Check();
    }

    // Use this for initialization
    protected void Check()
    {
        if (!SystemInfo.supportsImageEffects)
        {
            effect_enable = false;
            return;
        }

        if (!shader || !shader.isSupported || !meterial || meterial.shader != shader)
        {
            effect_enable = false;
            return;
        }

        effect_enable = true;

    }

    // Update is called once per frame
    void Update()
    {

    }
}
