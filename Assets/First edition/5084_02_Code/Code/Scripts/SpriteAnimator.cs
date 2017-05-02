using UnityEngine;
using System.Collections;

public class SpriteAnimator : MonoBehaviour 
{
	
	float timeValue = 0.0f;
    void Start()
    {
        float width = 4;

        for (int i = 0; i<16; i++)
        {
            float x = i % width;
            float y = Mathf.Floor(i / width);
            Debug.LogWarning("i:" + i + " x:" + x + " y:" + y);

        }
    }
	
	// Update is called once per frame
	void FixedUpdate () 
	{
		timeValue = Mathf.Ceil(Time.time % 16);
		transform.GetComponent<Renderer>().material.SetFloat("_TimeValue", timeValue);
        float variable = ((Mathf.Sin(Time.realtimeSinceStartup)+1)/2) * 4;
        variable = 15.8f % 4;
        variable = Mathf.Ceil(variable);
        //Debug.LogWarning(variable);
	}
}
