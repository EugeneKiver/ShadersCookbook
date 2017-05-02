using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class IFX_BCS : MonoBehaviour {

    #region Variables
    public Shader curShader;
    private Material curMaterial;

    public float brightness = 1.0f;
    public float saturation = 1.0f;
    public float contrast = 1.0f;
    #endregion

    #region Properties
    Material material
    {
        get
        {
            if(curMaterial == null)
            {
                curMaterial = new Material(curShader);
                curMaterial.hideFlags = HideFlags.HideAndDontSave;
            }
            return curMaterial;
        }
    }
    #endregion
    // Use this for initialization

    void Start () {
		if(!SystemInfo.supportsImageEffects)
        {
            enabled = false;
            return;
        }

        if(!curShader && !curShader.isSupported)
        {
            enabled = false;
        }
	}
	
	// Update is called once per frame
	void Update () {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;

        brightness = Mathf.Clamp(brightness, 0.0f, 2.0f);
        saturation = Mathf.Clamp(saturation, 0.0f, 2.0f);
        contrast = Mathf.Clamp(contrast, 0.0f, 3.0f);
    }

    void OnDisable()
    {
        if(curMaterial)
        {
            DestroyImmediate(curMaterial);
        }
    }

    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        if(curShader != null)
        {
            //material.SetFloat("_LuminosityAmount", grayScaleAmount);
            material.SetFloat("_Brightness", brightness);
            material.SetFloat("_Saturation", saturation);
            material.SetFloat("_Contrast", contrast);

            Graphics.Blit(sourceTexture, destTexture, material);
        }
        else
        {
            Graphics.Blit(sourceTexture, destTexture);
        }
    }
}
