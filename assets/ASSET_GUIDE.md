# Guia de assets — Geek Girl Dollhouse

Todos os PNGs devem ser exportados em escala de cinza, com fundo transparente e perfil sRGB. O jogo multiplica a imagem pela cor escolhida no editor: branco recebe a cor, cinza cria sombra e preto permanece escuro.

## Avatar

- Canvas obrigatório: `256 x 256 px` para **todas** as peças.
- Fundo transparente.
- Personagem centralizado e com o mesmo pivô em todos os arquivos.
- Não corte partes nas bordas. Não mude o tamanho do canvas entre opções.
- As camadas dos olhos ficam separadas para permitir olhar, piscar e expressões.
- Cabelos usam duas camadas: `back` atrás do corpo e `front` sobre a cabeça.

O jogo procura exatamente estes arquivos:

```text
assets/avatar/
├── heads/head_01.png ... head_03.png
├── arms/arms_01.png ... arms_03.png
├── legs/legs_01.png ... legs_03.png
├── torsos/torso_01.png ... torso_03.png
├── eyes/
│   ├── eye_01/sclera.png, iris.png, pupil.png
│   ├── eye_02/sclera.png, iris.png, pupil.png
│   ├── eye_03/sclera.png, iris.png, pupil.png
│   └── eye_04/sclera.png, iris.png, pupil.png
├── hair/hair_01_back.png + hair_01_front.png (até 03)
└── clothing/
    ├── blouses/blouse_01.png ... blouse_03.png
    ├── pants/pant_01.png ... pant_03.png
    ├── dresses/dress_01.png ... dress_03.png
    ├── shoes/shoe_01.png ... shoe_03.png
    ├── skirts/skirt_01.png ... skirt_03.png
    └── shorts/short_01.png ... short_03.png
```

Cabeça, braços, pernas, tronco, olhos, cabelo e suas cores são permanentes após a confirmação. Roupas, sapatos e cor da roupa continuam editáveis.

## Casa

- `assets/house/house_shell.png`: `720 x 1000 px`, transparente.
- Desenhe apenas telhado, paredes, divisórias, escadas, portas e detalhes estruturais.
- As áreas internas precisam permanecer transparentes para a cor dos cômodos aparecer por baixo.

Áreas atuais no canvas:

| Cômodo | x | y | largura | altura |
|---|---:|---:|---:|---:|
| Quarto | 60 | 120 | 600 | 245 |
| Sala | 60 | 395 | 600 | 245 |
| Estúdio | 60 | 670 | 600 | 245 |

Se a arquitetura final mudar, atualize `ROOM_RECTS` em `scripts/world/house_view.gd`.

## Peças dos cômodos

- Canvas recomendado: `128 x 128 px`, fundo transparente.
- Duas peças por ambiente no primeiro passe.
- Mantenha sombra e contorno em cinza; o editor aplica a cor.

```text
assets/rooms/bedroom/item_01.png e item_02.png
assets/rooms/living_room/item_01.png e item_02.png
assets/rooms/studio/item_01.png e item_02.png
```

Enquanto um arquivo ainda não existir, o jogo desenha automaticamente um placeholder cinza com o nome da peça.
