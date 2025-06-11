using System;
using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
public class Mountains : MonoBehaviour
{
    [SerializeField] private Vector2Int size = new Vector2Int(10, 10); // width (x), depth (z)
    [SerializeField] private Transform cameraTransform;
    [SerializeField] private float waveAmplitude = 2f;
    [SerializeField] private float distanceToHills = 10f;
    [SerializeField] private float dropoffSpeed = 50f;
    [SerializeField] private float offset = 10f;
    [SerializeField] private float heightRingHeight = 10f;
    [SerializeField] private float heightRingDistance = 100f;

    private Mesh mesh;
    private Vector3[] baseVertices;

    void Start()
    {
        mesh = new Mesh();
        mesh.name = "Procedural Grid";

        int vertCount = size.x * size.y;
        Vector3[] vertices = new Vector3[vertCount];
        Vector2[] uvs = new Vector2[vertCount];
        int[] triangles = new int[(size.x - 1) * (size.y - 1) * 6];

        // Create vertices and UVs
        for (int z = 0; z < size.y; z++)
        {
            for (int x = 0; x < size.x; x++)
            {
                int index = z * size.x + x;
                vertices[index] = new Vector3(x - size.x / 2f, 0f, z - size.y / 2f);
                uvs[index] = new Vector2((float)x / (size.x - 1), (float)z / (size.y - 1));
            }
        }

        // Create triangles
        int t = 0;
        for (int z = 0; z < size.y - 1; z++)
        {
            for (int x = 0; x < size.x - 1; x++)
            {
                int topLeft = z * size.x + x;
                int topRight = topLeft + 1;
                int bottomLeft = topLeft + size.x;
                int bottomRight = bottomLeft + 1;

                triangles[t++] = topLeft;
                triangles[t++] = bottomLeft;
                triangles[t++] = topRight;

                triangles[t++] = topRight;
                triangles[t++] = bottomLeft;
                triangles[t++] = bottomRight;
            }
        }

        // Assign to mesh
        mesh.vertices = vertices;
        baseVertices = vertices;
        mesh.uv = uvs;
        mesh.triangles = triangles;
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();

        GetComponent<MeshFilter>().mesh = mesh;
    }

    void Update()
    {
        Vector3[] newVertices = new Vector3[baseVertices.Length];

        for (int z = 0; z < size.y; z++)
        {
            for (int x = 0; x < size.x; x++)
            {
                int index = z * size.x + x;
                Vector3 baseVertex = baseVertices[index];
                Vector3 worldPos = transform.TransformPoint(baseVertex);

                float distanceToCamera = Vector3.Distance(cameraTransform.position + new Vector3(0, 0, offset), worldPos);
                float extraRingDistance = Mathf.Abs(heightRingDistance - distanceToCamera);

                float height =
                    Mathf.Clamp(waveAmplitude - distanceToCamera / dropoffSpeed, 0, waveAmplitude) *
                    Mathf.Pow(Mathf.Sin(((worldPos.x - cameraTransform.position.x)/ distanceToHills) ), 2) +
                    Mathf.Clamp(heightRingHeight - extraRingDistance / dropoffSpeed, 0, heightRingHeight);

                newVertices[index] = new Vector3(baseVertex.x, baseVertex.y + height, baseVertex.z);
            }
        }

        mesh.vertices = newVertices;
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();
    }
}