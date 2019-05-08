using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Shadow : MonoBehaviour
{
    public Transform shadow;
	// Use this for initialization
	void Start ()
	{
        if (!shadow)
        {
            Debug.LogError("1111111111111");
            return; }


	    var shadowMat = shadow.GetComponent<SpriteRenderer>().material;

	    var heroTex = GetComponent<SpriteRenderer>().sprite.texture;

	    shadowMat.SetTexture("_HeroTex", heroTex);

	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
