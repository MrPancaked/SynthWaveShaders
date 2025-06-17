using System;
using UnityEngine;

public class SendMousePosition : MonoBehaviour
{
    public Material material;

    private void Update()
    {
        material.SetVector("_MousePosition", new Vector4(Input.mousePosition.x / 1920f, Input.mousePosition.y / 1080f, 0, 0));
        print(material.GetVector("_MousePosition"));
    }
}
