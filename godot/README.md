# MYU — Lume Café

Godot **4.7.2**, arte original de **1536 × 864**, viewport de **1024 × 576**. Abra `project.godot` e pressione F5.

| Ação | Teclado | Celular |
| --- | --- | --- |
| Caminhar | WASD / setas | Analógico |
| Colisões visíveis (depuração) | F3 | — |

**17:40 é a identidade visual**, não um horário exibido ou selecionável. O cenário mantém um entardecer frio, com azul nas sombras e âmbar localizado nas janelas e luminárias. Não há relógio nem botões de horário ou chuva. A dica de movimento desaparece após a abertura.

A chuva varia automaticamente entre garoa, chuva moderada e pausas, com transições suaves. Poças e reflexos permanecem durante a secagem; as ondulações acompanham a intensidade da chuva. A paleta não alterna entre manhã, dia e noite.

## Movimento e profundidade

CharacterBody2D flutuante, move_and_slide, aceleração, frenagem e diagonal normalizada. A cápsula de colisão fica nos pés. A fase dos passos acompanha a distância realmente percorrida, inclusive ao deslizar junto a obstáculos, e continua ao mudar de direção. Encostar em uma parede interrompe a caminhada. O analógico também controla a cadência.

O importador registra as poses em pivôs medidos no quadril, com uma escala fixa por direção. Os perfis laterais compartilham a mesma cabeça, preservando o desenho original para evitar que o rosto e o cabelo mudem durante cada passo. Um pequeno rig de recortes articula as duas pernas entre contato, passagem e contato oposto; a parada lateral usa uma pose própria com os dois pés apoiados. Não há espelhamento da personagem. A parada mantém a direção.

As bases de colisão e silhuetas visuais em `data/lume_geometry.gd` são independentes. Y-sort organiza a profundidade. Barras de grades preservam os vãos. A sombra tem contato no chão e projeção da pose atual, influenciada pelas luminárias próximas.

O cenário é uma ilustração plana. Colisões e recortes foram traçados manualmente; a projeção de sombra é uma aproximação 2D.

## Validação e arte

Os originais estão em `source_art/`. Seu conteúdo é JPEG. O importador gera PNGs válidos e atlas de 32 × 56, preservando a roupa escura e removendo o fundo conectado à borda.

```sh
godot --headless --path godot --script res://tools/import_art.gd
godot --headless --path godot --editor --quit
godot --headless --path godot --script res://tests/test_lume.gd
mkdir -p /tmp/myu-web
godot --headless --path godot --export-release Web /tmp/myu-web/index.html
godot --headless --main-pack /tmp/myu-web/index.pck --quit-after 30
```

O CI testa física e entrada reais, continuidade dos passos, clima automático, permanência da umidade e remoção dos controles antigos. O renderizador captura o cenário, a profundidade e uma sequência em movimento para revisão da caminhada lateral. A publicação abre também o PCK exportado para detectar recursos ausentes.

## Documentação consultada

- [Movimento 2D](https://docs.godotengine.org/en/stable/tutorials/2d/2d_movement.html)
- [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html)
- [AnimatedSprite2D e continuidade de quadros](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html#class-animatedsprite2d-method-set-frame-and-progress)
- [Y-sort](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html#class-canvasitem-property-y-sort-enabled)
- [Luzes e sombras 2D](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html)
