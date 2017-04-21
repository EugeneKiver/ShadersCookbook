using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Radius : MonoBehaviour {

    public Material radiusMaterial;
    public float radius = 0.3f;
    public Color color = Color.white;
    public float speed = 0.1f;
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
        float X = transform.position.x + speed * Time.deltaTime;
        float Z = transform.position.z;

        transform.position = new Vector3(X, 0, Z);

        radiusMaterial.SetVector("_Center", transform.position);
        radiusMaterial.SetFloat("_Radius", radius);
        radiusMaterial.SetColor("_RadiusColor", color);
		
	}
}
