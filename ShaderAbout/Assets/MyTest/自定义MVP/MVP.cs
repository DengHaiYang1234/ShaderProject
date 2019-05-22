using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MVP : MonoBehaviour {

	// Use this for initialization
	void Start () 
	{


	}	
	
	// Update is called once per frame
	void Update () {
		//旋转
		Matrix4x4 rotation = new Matrix4x4();
		rotation[0,0] = Mathf.Cos(Time.realtimeSinceStartup);
		rotation[0,2] = Mathf.Sin(Time.realtimeSinceStartup);
		rotation[1,1] = 1;
		rotation[2,0] = -Mathf.Sin(Time.realtimeSinceStartup);
		rotation[2,2] = Mathf.Cos(Time.realtimeSinceStartup);
		rotation[3,3] = 1;
		//缩放
		Matrix4x4 SM = new Matrix4x4();
		SM[0,0] = Mathf.Sin(Time.realtimeSinceStartup);
		SM[1,1] = Mathf.Cos(Time.realtimeSinceStartup);
		SM[2,2] = Mathf.Sin(Time.realtimeSinceStartup);
		SM[3,3] = 1;

		//顺序为模型本地坐标转为世界坐标，世界坐标转为视图坐标，视图坐标转为屏幕裁剪坐标（代码应该反着写）
		//Matrix4x4 mvp = Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix * transform.localToWorldMatrix * rotation;	

		this.GetComponent<MeshRenderer>().material.SetMatrix("sm",rotation);
	}
}
