# MYU — 17:40 playable prototype

Protótipo mobile-first do jogo de Myu.

## O que já funciona

- movimentação com aceleração, desaceleração e colisão física;
- cenário externo 17:40 com cafeteria, rua, calçada, mobiliário e limites reais;
- entrada e saída da cafeteria;
- cenário interno com mesas, balcão e colisões;
- controles de toque para celular (analógico + botão A);
- WASD/setas e E/espaço no desktop;
- câmera suave e pixel-art procedural sem dependências externas;
- PWA/offline básico via service worker.

## Jogar

Se o GitHub Pages estiver habilitado para este repositório, o protótipo fica em:

https://joaobruck.github.io/Myu/

No celular, abra em navegador moderno. Funciona em retrato, mas a composição fica melhor em paisagem.

## Controles

- Celular: analógico virtual à esquerda; botão A à direita para interagir.
- Desktop: WASD/setas para mover; E, Espaço ou Enter para interagir.

## Direção

Este é um vertical slice técnico para provar que o visual pixel-art de Myu pode funcionar como cenário explorável de verdade. A arte atual é procedural/provisória; a intenção é substituir progressivamente por sprites e tiles finais mantendo a mesma física e estrutura.
