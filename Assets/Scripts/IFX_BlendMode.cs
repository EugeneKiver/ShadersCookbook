using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class IFX_BlendMode : MonoBehaviour {

    #region Variables
    public Shader curShader;
    private Material curMaterial;

    public Texture2D blendTexture;
    public float blendOpacity = 1.0f;
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
        blendOpacity = Mathf.Clamp(blendOpacity, 0.0f, 1.0f);
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
            material.SetTexture("_BlendTex", blendTexture);
            material.SetFloat("_Opacity", blendOpacity);
            Graphics.Blit(sourceTexture, destTexture, material);
        }
        else
        {
            Graphics.Blit(sourceTexture, destTexture);
        }
    }
}
