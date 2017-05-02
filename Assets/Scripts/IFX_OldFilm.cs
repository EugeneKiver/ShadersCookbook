using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class IFX_OldFilm : MonoBehaviour {

    #region Variables
    public Shader oldFilmShader;
    private Material curMaterial;

    public float oldFilmEffectAmount = 1.0f;

    public Color sepiaColor = Color.white;
    public Texture2D vignetteTexture;
    public float vignetteAmount = 1.0f;

    public Texture2D scratchesTexture;
    public float scratchesYSpeed = 10.0f;
    public float scratchesXSpeed = 10.0f;

    public Texture2D dustTexture;
    public float dustYSpeed = 10.0f;
    public float dustXSpeed = 10.0f;

    public float randomValue = 1.0f;
    public float distortion = 1.0f;
    public float scale = 1.0f;
    #endregion

    #region Properties
    Material material
    {
        get
        {
            if(curMaterial == null)
            {
                curMaterial = new Material(oldFilmShader);
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

        if(!oldFilmShader && !oldFilmShader.isSupported)
        {
            enabled = false;
        }
	}
	
	// Update is called once per frame
	void Update () {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
        vignetteAmount = Mathf.Clamp01(vignetteAmount);
        oldFilmEffectAmount = Mathf.Clamp(oldFilmEffectAmount, 0.0f, 1.5f);
        randomValue = Mathf.Clamp(randomValue, -1.0f, 1.0f);
        distortion = Mathf.Clamp(distortion, -100.0f, 100.0f);
        scale = Mathf.Clamp(scale, -100.0f, 100.0f);
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
        if(oldFilmShader != null)
        {
            material.SetColor("_SepiaColor", sepiaColor);
            material.SetFloat("_VignetteAmount", vignetteAmount);
            material.SetFloat("_EffectAmount", oldFilmEffectAmount);

            if(vignetteTexture)
            {
                material.SetTexture("_VignetteTex", vignetteTexture);
            }
            if (scratchesTexture)
            {
                material.SetTexture("_ScratchesTex", scratchesTexture);
                material.SetFloat("_ScratchesYSpeed", scratchesYSpeed);
                material.SetFloat("_ScratchesXSpeed", scratchesXSpeed);
            }
            if (dustTexture)
            {
                material.SetTexture("_DustTex", dustTexture);
                material.SetFloat("_DustYSpeed", dustYSpeed);
                material.SetFloat("_DustXSpeed", dustXSpeed);

                material.SetFloat("_RandomValue", randomValue);
                material.SetFloat("_Distortion", distortion);
                material.SetFloat("_Scale", scale);
            }
            Graphics.Blit(sourceTexture, destTexture, material);
        }
        else
        {
            Graphics.Blit(sourceTexture, destTexture);
        }
    }
}
