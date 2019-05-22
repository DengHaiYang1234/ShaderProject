using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class GetVertex : MonoBehaviour
{

    public MeshFilter mesh1;


    // Use this for initialization
    void Start ()
    {
        Vector3[] verts = mesh1.mesh.vertices;

        float max = verts.Max(v => v.x);

        float min = verts.Min(v => v.x);

        Debug.LogError(max + "       " + min);


    }
	
	// Update is called once per frame
	void Update () {
		
	}
}
