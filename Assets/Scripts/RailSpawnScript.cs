using UnityEngine;

public class RailSpawnScript : MonoBehaviour
{
    [SerializeField] GameObject railPillarPrefab;
    [SerializeField] int railCount = 100;
    void Start()
    {
        for (int i = 0; i < railCount; i++)
        {
            float zPosition = (transform.position.y - transform.localScale.y) + i * (2 * transform.localScale.y / railCount);
            Instantiate(railPillarPrefab, new Vector3(transform.position.x, transform.position.y - 0.75f, zPosition) , Quaternion.identity);
        }
    }
}
