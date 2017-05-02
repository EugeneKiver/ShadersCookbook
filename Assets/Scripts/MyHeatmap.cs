using UnityEngine;
using System.Collections;
public class MyHeatmap : MonoBehaviour
{
    public Vector3[] positions;
    public float[] radiuses;
    public float[] intensities;
    public Material material;

    void Start()
    {
        Material curMaterial = GetComponent<Renderer>().materials[0];
        curMaterial.SetInt("_Points_Length", positions.Length);
        for (int i = 0; i < positions.Length; i ++)
        {
            curMaterial.SetVector("_Points" + i.ToString(), positions[i]);
            Vector2 properties = new Vector2(radiuses[i], intensities[i]);
            curMaterial.SetVector("_Properties" + i.ToString(), properties);
        }
    }
    void OnUpdate()
    {
        Material curMaterial = GetComponent<Renderer>().materials[0];
        curMaterial.SetInt("_Points_Length", positions.Length);
        for (int i = 0; i < positions.Length; i++)
        {
            curMaterial.SetVector("_Points" + i.ToString(), positions[i]);
            Vector2 properties = new Vector2(radiuses[i], intensities[i]);
            curMaterial.SetVector("_Properties" + i.ToString(), properties);
        }
    }
}