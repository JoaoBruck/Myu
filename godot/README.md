# MYU — Godot Pixel Art Build

Agora o Godot usa a direção visual real de MYU, não o blockout geométrico.

- Lume Café convertido para 256×144 e escalado 2× com nearest-neighbor;
- viewport lógico 512×288;
- protagonista 32×56;
- quatro direções reais da arte: frente, direita, costas e esquerda;
- movimento em 8 direções;
- analógico virtual no celular;
- chuva separada;
- assets visuais carregados em runtime a partir de WebP embutido em base64 para manter o build reprodutível no GitHub Pages.

A próxima etapa visual é separar os 4/6 frames da prancha de animação para AnimatedSprite2D.
