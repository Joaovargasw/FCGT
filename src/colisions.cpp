#include "colisions.h"
#include <cmath>

// Colisão esférica simples entre tiro e alvo
bool ColisaoEsferica(const Tiro& tiro, const Alvo& alvo)
{
    float dx = tiro.x - alvo.x;
    float dy = tiro.y - alvo.y;
    float dz = tiro.z - alvo.z;
    float distancia2 = dx*dx + dy*dy + dz*dz;
    float somaRaios = 0.3f + alvo.raio; // 0.2f é o raio do tiro
    float somaRaios2 = somaRaios * somaRaios;
    return distancia2 <= somaRaios2;
}
//##################################bat e colho
bool ColisaoEsfericaAlvo(const Alvo& alvo1, const Alvo& alvo2) {
    float dx = alvo1.x - alvo2.x;
    float dy = alvo1.y - alvo2.y;
    float dz = alvo1.z - alvo2.z;

    float distancia2 = dx*dx + dy*dy + dz*dz;
    float raioSoma = alvo1.raio + alvo2.raio;

    return distancia2 <= (raioSoma * raioSoma);
}

// Função para colisão entre esfera e cubo (bounding box) já definida em seu header (caso queira usar)
bool sphereIntersectsCube(glm::vec4 sphereCenter, float sphereRadius, glm::vec4 cubeCenter, float cubeSize)
{
    float x = std::max(0.0f, std::abs(sphereCenter.x - cubeCenter.x) - cubeSize/2);
    float y = std::max(0.0f, std::abs(sphereCenter.y - cubeCenter.y) - cubeSize/2);
    float z = std::max(0.0f, std::abs(sphereCenter.z - cubeCenter.z) - cubeSize/2);

    float distanceSquared = x*x + y*y + z*z;
    return distanceSquared <= sphereRadius * sphereRadius;
}

// Colisão entre duas bounding boxes AABB (Axis-Aligned Bounding Boxes)
bool caixasColidem(const BoundingBox& box1, const BoundingBox& box2)
{
    bool colideX = std::abs(box1.cx - box2.cx) <= (box1.width/2 + box2.width/2);
    bool colideY = std::abs(box1.cy - box2.cy) <= (box1.height/2 + box2.height/2);
    bool colideZ = std::abs(box1.cz - box2.cz) <= (box1.depth/2 + box2.depth/2);

    return (colideX && colideY && colideZ);
}
