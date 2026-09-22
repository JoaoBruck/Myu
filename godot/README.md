# MYU — Godot Outdoor Lab

Primeira base do rebuild em **Godot 4.7.2 Standard + GDScript**.

## Fonte visual utilizada

Esta implementação foi construída olhando diretamente os arquivos oficiais do projeto no Google Drive:

- `MYU_Cenario_17h40_TopDown_Base.png` — fonte principal de perspectiva, massas, fluxo do passeio, café, rio, guarda-corpo e rua;
- `MYU_Cenario_17h40_Referencia.png` — referência complementar de atmosfera, profundidade, clima e linguagem visual;
- `MYU_Protagonista_Referencia.png` — escala, silhueta e landmarks da protagonista.

Os arquivos originais continuam no Drive e **não foram copiados para o repositório público**. O jogo não usa uma imagem única como cenário final.

## Decisões congeladas aplicadas

- viewport lógico: **512×288**;
- grid-base: **16×16**;
- câmera 3/4 top-down;
- movimento físico em 8 direções;
- protagonista: **56 px** de altura visual nesta etapa;
- colisão concentrada nos pés;
- `y_sort_enabled` no grupo de personagens;
- cenário estruturado em ground, architecture, props, collision, characters, foreground, lights/occluders, weather e reflections;
- frio global + calor localizado;
- chuva e reflexos como sistemas separados.

## Estado desta etapa

A arte em `world_art.gd` é uma **blockout autoral em resolução nativa**, construída a partir da composição oficial do Drive. Ela existe para validar:

1. escala;
2. perspectiva;
3. rota caminhável;
4. colisões;
5. profundidade;
6. relação personagem/cenário.

Não é arte final e não deve virar uma pintura única de fundo.

## Executar

Abra a pasta `godot/` no Godot 4.7.2 e rode `scenes/main.tscn`.

Controles: WASD ou setas.
