# MYU — Lume Café

Godot **4.7.2**, arte original de **1536 × 864**, viewport de **1024 × 576**. Abra `project.godot` e pressione F5.

| Ação | Teclado | Celular |
| --- | --- | --- |
| Caminhar | WASD / setas | Analógico |
| Sentar na cadeira externa | E, perto da cadeira | Botão Sentar ou toque na cadeira |
| Revelar a fala inteira | Espaço | Toque no balão |
| Levantar | E, Esc ou movimento | Botão Levantar ou analógico |
| Colisões visíveis (depuração) | F3 | — |

**17:40 é a identidade visual**, não um horário exibido ou selecionável. O cenário mantém um entardecer frio, com azul nas sombras e âmbar localizado nas janelas e luminárias. Não há relógio nem botões de horário ou chuva. A dica de movimento desaparece após a abertura.

A chuva varia automaticamente entre garoa, chuva moderada e pausas, com transições suaves. Poças e reflexos permanecem durante a secagem; as ondulações acompanham a intensidade da chuva. A paleta não alterna entre manhã, dia e noite.

## Movimento e profundidade

CharacterBody2D flutuante, move_and_slide, aceleração, frenagem e diagonal normalizada. A cápsula de colisão fica nos pés. A fase dos passos acompanha a distância realmente percorrida, inclusive ao deslizar junto a obstáculos, e continua ao mudar de direção. Encostar em uma parede interrompe a caminhada. O analógico também controla a cadência.

O importador registra as poses em pivôs medidos no quadril, com uma escala fixa por direção. Os perfis laterais compartilham a mesma cabeça, preservando o desenho original para evitar que o rosto e o cabelo mudem durante cada passo. Um pequeno rig de recortes articula as duas pernas entre contato, passagem e contato oposto; a parada lateral usa uma pose própria com os dois pés apoiados. Não há espelhamento da personagem. A parada mantém a direção.

As bases de colisão e silhuetas visuais em `data/lume_geometry.gd` são independentes. Y-sort organiza a profundidade. Barras de grades preservam os vãos. A sombra tem contato no chão e projeção da pose atual, influenciada pelas luminárias próximas.

Os postes da rua têm silhuetas separadas. Um objeto que cobre a personagem torna seu recorte de primeiro plano parcialmente transparente e volta à opacidade normal quando ela sai de trás dele. As letras da lousa e das placas são redesenhadas com Tiny5, incluindo os acentos, nas duas camadas de profundidade.

## Pausa no café

A cadeira à esquerda da mesa externa pode ser usada ao se aproximar pela calçada. A personagem ganha uma pose sentada original e um retrato novo no balão: “Quando será que sai a continuação daquele livro?”. O texto aparece aos poucos e pode ser revelado imediatamente. Ao levantar, a física verifica um ponto livre na calçada; perder o foco da janela não desfaz a pose nem deixa o analógico preso.

O cenário é uma ilustração plana. Colisões e recortes foram traçados manualmente; a projeção de sombra é uma aproximação 2D.

## Validação e arte

Os originais estão em `source_art/`. O importador original converte os JPEGs recebidos em PNGs válidos e atlas de 32 × 56, preservando a roupa escura e removendo o fundo conectado à borda. A pose sentada e o retrato são PNGs transparentes novos, gerados com image_gen e preparados com `tools/import_seated.gd`; a arte antiga serviu apenas como referência visual. Prompts e proveniência constam em `source_art/generated_assets.json`. A fonte Tiny5 inclui sua licença OFL em `art/fonts/`.

```sh
godot --headless --path godot --script res://tools/import_art.gd
godot --headless --path godot --script res://tools/import_seated.gd
godot --headless --path godot --editor --quit
godot --headless --path godot --script res://tests/test_lume.gd
mkdir -p /tmp/myu-web
godot --headless --path godot --export-release Web /tmp/myu-web/index.html
godot --headless --main-pack /tmp/myu-web/index.pck --quit-after 30
```

O CI testa física e entrada reais, continuidade dos passos, clima automático, permanência da umidade, interação com a cadeira, diálogo e profundidade. O renderizador captura também a pose sentada, a interface de toque e os pontos de oclusão relatados, além de uma sequência em movimento para revisão da caminhada lateral. A publicação abre também o PCK exportado para detectar recursos ausentes.

## Documentação consultada

- [Movimento 2D](https://docs.godotengine.org/en/stable/tutorials/2d/2d_movement.html)
- [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html)
- [AnimatedSprite2D e continuidade de quadros](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html#class-animatedsprite2d-method-set-frame-and-progress)
- [Y-sort](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html#class-canvasitem-property-y-sort-enabled)
- [Luzes e sombras 2D](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html)
- [Modulação de cor e alfa no shader 2D](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html)
- [Tiny5](https://fonts.google.com/specimen/Tiny5)
