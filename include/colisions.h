#ifndef COLISIONS_H
#define COLISIONS_H

#include <glm/glm.hpp>      // Para glm::vec4 e glm::dot
#include <glm/gtc/type_ptr.hpp>
#include <algorithm> 
#include <vector>

// Representa um tiro no jogo
struct Tiro {
    float x, y, z;
    float dx, dz;
    float speed;
    float tempoVivo;
    bool ativo;
};

// Representa um alvo com colisão esférica
struct Alvo {
    float x, y, z;
    float raio; // raio de colisão esférica
};

// Representa uma caixa delimitadora (Bounding Box) para colisão
struct BoundingBox {
    float cx, cy, cz;    // centro da caixa
    float width, height, depth;  // dimensões da caixa
};

// Função para detectar colisão esférica entre tiro e alvo
bool ColisaoEsferica(const Tiro& tiro, const Alvo& alvo);

// Função para detectar colisão entre esfera e cubo (bounding box)
bool sphereIntersectsCube(glm::vec4 sphereCenter, float sphereRadius, glm::vec4 cubeCenter, float cubeSize);

// Função para detectar colisão entre duas bounding boxes
bool caixasColidem(const BoundingBox& box1, const BoundingBox& box2);

#endif // COLISIONS_H

