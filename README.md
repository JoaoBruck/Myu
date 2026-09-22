# MYU

O repositório mantém duas bases:

## Build estável atual
https://joaobruck.github.io/Myu/

## Phaser Rebuild v1
https://joaobruck.github.io/Myu/phaser/

A reconstrução em JavaScript + Phaser 3 é deliberadamente enxuta neste primeiro marco:
- rua e café;
- personagem jogável em escala maior;
- Arcade Physics para objetos;
- regiões caminháveis explícitas;
- câmera com dead zone;
- joystick mobile e botão A;
- transição rua ↔ café;
- depth sorting pelo eixo Y;
- foreground overlays para postes, placas, mesas, balcão e estante;
- modo de debug com `?debug=1`.

O NPC e o áudio da build antiga não foram migrados ainda. Primeiro a base de movimento, colisão e profundidade será validada.
