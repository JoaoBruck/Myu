# MYU — Lume Café

Godot **4.7.2**, arte original de **1536 × 864**, viewport de **1024 × 576**. Abra `project.godot` e pressione F5.

| Ação | Teclado | Celular |
| --- | --- | --- |
| Caminhar | WASD / setas | Analógico |
| Horário | T | Botão de horário |
| Chuva | R | Botão de chuva |
| Colisões visíveis | F3 | — |

O jogo abre nas **17:40**, com tons frios e âmbar localizado nas janelas e luminárias. Há manhã (08:00), dia (13:00) e noite (21:00). A manhã é um perfil aplicado à arte diurna; não foi fornecida uma imagem exclusiva para ela. A noite usa a imagem noturna original.

## Movimento e profundidade

CharacterBody2D flutuante, move_and_slide, aceleração, frenagem e diagonal normalizada. A cápsula de colisão fica nos pés e a posição não é corrigida manualmente após a física. A animação usa deslocamento real, para ao encostar em paredes e mantém a direção. A folha fornecida tem quatro poses de parada frontal e seis de caminhada por direção; paradas laterais e de costas usam uma pose da própria folha.

As bases de colisão e silhuetas visuais em `data/lume_geometry.gd` são independentes. Y-sort organiza a profundidade. Barras de grades preservam os vãos. A sombra tem contato no chão e projeção da pose atual, influenciada pelo horário e pelas luminárias próximas.

O cenário é uma ilustração plana. Colisões e recortes foram traçados manualmente; a projeção de sombra é uma aproximação 2D.

## Validação e arte

Os originais estão em `source_art/`. Apesar da extensão dos anexos, seu conteúdo era JPEG. O importador gera PNGs válidos e atlas de 32 × 56, preservando a roupa escura e removendo o fundo conectado à borda.

```sh
godot --headless --path godot --script res://tools/import_art.gd
godot --headless --path godot --editor --quit
godot --headless --path godot --script res://tests/test_lume.gd
mkdir -p /tmp/myu-web
godot --headless --path godot --export-release Web /tmp/myu-web/index.html
godot --headless --main-pack /tmp/myu-web/index.pck --quit-after 30
```

O CI testa a física e entrada reais, renderiza os quatro horários e verifica a profundidade. A publicação abre também o PCK exportado para detectar recursos ausentes.

## Documentação consultada

- [Movimento 2D](https://docs.godotengine.org/en/stable/tutorials/2d/2d_movement.html)
- [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html)
- [Y-sort](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html#class-canvasitem-property-y-sort-enabled)
- [Luzes e sombras 2D](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html)
