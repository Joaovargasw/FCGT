#version 330 core

// Atributos de fragmentos recebidos como entrada ("in") pelo Fragment Shader.
// Neste exemplo, este atributo foi gerado pelo rasterizador como a
// interpolação da posição global e a normal de cada vértice, definidas em
// "shader_vertex.glsl" e "main.cpp".
in vec4 position_world;
in vec4 normal;

// Posição do vértice atual no sistema de coordenadas local do modelo.
in vec4 position_model;

// Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
in vec2 texcoords;

// Matrizes computadas no código C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// Identificador que define qual objeto está sendo desenhado no momento

#define SPHERE 0
#define BUNNY  1
#define PLANE  2
#define BAT    3
#define PLANEC 4
#define TIRO  5
#define PEAOM 6
#define SKY 7

uniform int object_id;
uniform int shading_model;

// Parâmetros da axis-aligned bounding box (AABB) do modelo
uniform vec4 bbox_min;
uniform vec4 bbox_max;

// Variáveis para acesso das imagens de textura
uniform sampler2D TextureImage0;
uniform sampler2D TextureImage1;
uniform sampler2D TextureImage2;
uniform sampler2D TextureImage3;
uniform sampler2D TextureImage4;
uniform sampler2D TextureImage5;
uniform sampler2D TextureImage6;


//Lambert + Blinn-Phong  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%MARCAÇÃO SHADER BLINN - PHONG
uniform vec4 light_position_world;
uniform vec3 light_intensity;
uniform vec3 Ks;
uniform float shininess;
uniform vec4 view_position_world;
in vec3 gouraud_color;


// O valor de saída ("out") de um Fragment Shader é a cor final do fragmento.
out vec4 color;

// Constantes
#define M_PI   3.14159265358979323846
#define M_PI_2 1.57079632679489661923

void main()
{
    // Obtemos a posição da câmera utilizando a inversa da matriz que define o
    // sistema de coordenadas da câmera.
    vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 camera_position = inverse(view) * origin;

    // O fragmento atual é coberto por um ponto que percente à superfície de um
    // dos objetos virtuais da cena. Este ponto, p, possui uma posição no
    // sistema de coordenadas global (World coordinates). Esta posição é obtida
    // através da interpolação, feita pelo rasterizador, da posição de cada
    // vértice.
    vec4 p = position_world;

    // Normal do fragmento atual, interpolada pelo rasterizador a partir das
    // normais de cada vértice.
    vec4 n = normalize(normal);

    // Vetor que define o sentido da fonte de luz em relação ao ponto atual.
    vec4 l = normalize(vec4(1.0,1.0,0.0,0.0));

    // Vetor que define o sentido da câmera em relação ao ponto atual.
    vec4 v = normalize(camera_position - p);

    // Coordenadas de textura U e V
    float U = 0.0;
    float V = 0.0;

    if ( object_id == SPHERE )
    {
          // Calcula o centro da esfera pelo bounding box
    vec4 bbox_center = (bbox_min + bbox_max) / 2.0;
    vec4 p = position_model - bbox_center;

    float radius = max(length(p), 0.0001); // evita divisão por zero
    float theta = atan(p.z, p.x);          // [-pi, pi]
    float phi   = asin(p.y / radius);      // [-pi/2, pi/2]

    U =  1 + (theta + M_PI) / (2.0 * M_PI);           // [0,1]
    V = (phi + (M_PI/2.0)) / M_PI;               // [0,1]

    color.rgb = texture(TextureImage2, vec2(U, V)).rgb;
    color.a = 1.0;
    return;
    }
   else if (object_id == BUNNY)
{
    float minx = bbox_min.x;
    float maxx = bbox_max.x;
    float miny = bbox_min.y;
    float maxy = bbox_max.y;
    float scaleU = 0.75;
    float scaleV = 0.6;
    float offsetU = 0.1;
    float offsetV = 0.25;
    float offset = 0.3;

    // Mapeamento planar em XY do modelo, normalizando para [0,1]
    float U = (1 - (0.5 + (position_model.x - minx) / (maxx - minx))) * scaleU + offsetU;
    float V = (((position_model.y - miny) / (maxy - miny)) - offset) * scaleV + offsetV;

    vec3 tex_color = texture(TextureImage2, vec2(U, V)).rgb;

    if (shading_model == 0) // Gouraud
    {
        color.rgb = gouraud_color * tex_color;
        color.a = 1.0;
        return;
    }
    else // Phong por fragmento
    {
        vec3 N = normalize(normal.xyz);
        vec3 L = normalize(light_position_world.xyz - position_world.xyz);
        vec3 Vv = normalize(view_position_world.xyz - position_world.xyz);
        vec3 R = reflect(-L, N);

        float diff = max(dot(N, L), 0.0);
        float spec = 0.0;
        if (diff > 0.0)
            spec = pow(max(dot(R, Vv), 0.0), shininess);

        vec3 ambient = 0.2 * light_intensity;
        vec3 diffuse = diff * light_intensity;
        vec3 specular = spec * Ks;

        color.rgb = (ambient + diffuse + specular) * tex_color;
        color.a = 1.0;
        return;
    }
}


   else if ( object_id == PLANE )
    {
        // Coordenadas de textura do plano, obtidas do arquivo OBJ.
        U = texcoords.x;
        V = texcoords.y;
    }

    // Obtemos a refletância difusa a partir da leitura da imagem TextureImage0
  
   vec3 Kd0;

if (object_id == BAT) {
    U = texcoords.x;
    V = texcoords.y;
    vec3 base_color = texture(TextureImage0, vec2(U, V)).rgb; // Cor base da textura

    // Vetor normalizado da normal
    vec3 n = normalize(normal.xyz);

    // Vetor da luz (da posição do fragmento para a luz)
    vec3 l = normalize(light_position_world.xyz - position_world.xyz);

    // Vetor da câmera
    vec3 v = normalize(view_position_world.xyz - position_world.xyz);

    // Vetor halfway para Blinn-Phong
    vec3 h = normalize(l + v);

    // Lambert (difuso)
    float n_dot_l = max(0.0, dot(n, l));
    vec3 I_difusa = light_intensity * base_color * n_dot_l;

    // Especular Blinn-Phong
    float n_dot_h = max(0.0, dot(n, h));
    float especular = pow(n_dot_h, shininess);
    vec3 I_especular = light_intensity * Ks * especular;

    // Ambiente simples (opcional)
    vec3 I_ambiente = 0.15 * base_color;

    color.rgb = I_ambiente + I_difusa + I_especular;
    color.a = 1.0;
    return;
}


  if (object_id == PLANEC) {
    U = texcoords.x;
    V = texcoords.y;
    vec3 planec_color = texture(TextureImage1, vec2(U, V)).rgb; // TextureImage1 = planec.jpg
    color.rgb = planec_color;
    color.a = 1.0;
    return;
} if (object_id == TIRO) {

    // Calcula centro da esfera e posição local como antes
    vec4 bbox_center = (bbox_min + bbox_max) / 2.0;
    vec4 p = position_model - bbox_center;

    float radius = max(length(p), 0.0001);

    // Coordenadas UV esféricas (opcional)
    float theta = atan(p.z, p.x);
    float phi   = asin(p.y / radius);

    float U = (theta + M_PI) / (2.0 * M_PI);
    float V = (phi + (M_PI/2.0)) / M_PI;

    // Bola colorida: gradiente do centro para as bordas (usando a posição normalizada)
    float dist = length(p.xyz) / (0.5 * length(bbox_max.xyz - bbox_min.xyz));
    // dist ≈ 0 no centro, ≈ 1 na borda

    // Defina uma cor: aqui, vermelha no centro, azul nas bordas
    vec3 cor_centro = vec3(1.0, 0.2, 0.2); // vermelho claro
    vec3 cor_borda  = vec3(0.1, 0.1, 1.0); // azul
    
    color.rgb = vec3(1.0, 1.0, 0.2); // amarelo forte
    color.a = 1.0;
    return;
}
if (object_id == PEAOM) {
    // Cor cinza escuro (R=0.2, G=0.2, B=0.2)
    vec3 object_color = vec3(0.2, 0.2, 0.2);

    // Vetores para iluminação
    vec3 N = normalize(normal.xyz);                          // Normal
    vec3 L = normalize(light_position_world.xyz - position_world.xyz); // Direção da luz
    vec3 V = normalize(view_position_world.xyz - position_world.xyz);  // Direção da câmera
    vec3 H = normalize(L + V);                               // Vetor "halfway" (Blinn-Phong)

    // Componentes de iluminação
    float ambient = 0.1;                                     // Luz ambiente mínima
    float diffuse = max(dot(N, L), 0.0);                     // Iluminação difusa
    float specular = pow(max(dot(N, H), 0.0), shininess);    // Brilho especular

    // Combinação final
    color.rgb = (ambient + diffuse) * object_color + specular * vec3(0.5); // Brilho branco suave
    color.a = 1.0; // Opacidade total
    return;
}else {
    Kd0 = vec3(0.7, 0.7, 0.7); // cor neutra se faltar textura
   } 

//                                                                                    LOGO ABAIXO HAVERÁ O BACKGROUND QUE FALEI QUE TENTARIA NA APRESENTAÇÃO  
/*
if (object_id == SKY)
{
     // Cálculo UV esférico
    vec4 bbox_center = (bbox_min + bbox_max) / 2.0;
    vec4 p = position_model - bbox_center;
    float radius = max(length(p), 0.0001);
    float theta = atan(p.z, p.x);
    float phi   = asin(p.y / radius);

    float U = (theta + M_PI) / (2.0 * M_PI);
    float V = (phi + (M_PI/2.0)) / M_PI;

    vec3 sky_color = texture(TextureImage7, vec2(U, V)).rgb;
    color = vec4(sky_color, 1.0);
    return; 
}*/



   

    // Equação de Iluminação
    float lambert = max(0,dot(n,l));

    color.rgb = Kd0 * (lambert + 0.01);

    // NOTE: Se você quiser fazer o rendering de objetos transparentes, é
    // necessário:
    // 1) Habilitar a operação de "blending" de OpenGL logo antes de realizar o
    //    desenho dos objetos transparentes, com os comandos abaixo no código C++:
    //      glEnable(GL_BLEND);
    //      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    // 2) Realizar o desenho de todos objetos transparentes *após* ter desenhado
    //    todos os objetos opacos; e
    // 3) Realizar o desenho de objetos transparentes ordenados de acordo com
    //    suas distâncias para a câmera (desenhando primeiro objetos
    //    transparentes que estão mais longe da câmera).
    // Alpha default = 1 = 100% opaco = 0% transparente
    color.a = 1;
    

    // Cor final com correção gamma, considerando monitor sRGB.
    // Veja https://en.wikipedia.org/w/index.php?title=Gamma_correction&oldid=751281772#Windows.2C_Mac.2C_sRGB_and_TV.2Fvideo_standard_gammas
    color.rgb = pow(color.rgb, vec3(1.0,1.0,1.0)/2.2);
} 
