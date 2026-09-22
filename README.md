# MYU

## Build estável
https://joaobruck.github.io/Myu/

## Godot 4.7.2 — versão jogável Web
https://joaobruck.github.io/Myu/godot/

No celular, jogue em modo paisagem e use o analógico virtual no canto inferior esquerdo.

## Outdoor Engine Lab v3 — Phaser 4
https://joaobruck.github.io/Myu/phaser/

Rota alternativa:
https://joaobruck.github.io/Myu/streetlab/

### Godot
- viewport lógico: **512×288**;
- movimento em 8 direções;
- teclado no desktop e analógico por toque no celular;
- hitbox concentrada nos pés;
- chuva e reflexos separados;
- export Web sem threads para maior compatibilidade mobile;
- build validado pelo Godot 4.7.2 antes do deploy.

### Phaser v3
- velocidade máxima: **50 px/s**;
- prédio com corpos estáticos Matter contínuos;
- colisão determinística adicional antes do deslocamento;
- personagem não pode sair do polígono caminhável;
- fallback `lastSafe` impede desaparecer do mapa;
- hitbox concentrada nos pés;
- obstáculos visíveis sólidos.
