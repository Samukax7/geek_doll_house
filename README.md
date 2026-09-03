# GEEK GIRL DOLLHOUSE

Jogo cozy de casinha de boneca e decoração para Web mobile, criado com Godot 4.

## Estado atual

Vertical slice offline com mapa-casa:

- viewport retrato `720 x 1280`;
- casa inteira como mapa, com zoom suave por cômodo;
- três cômodos navegáveis: quarto, sala e estúdio;
- duas peças placeholder por cômodo, arrastáveis e colorizáveis;
- posicionamento de peças;
- desfazer até dez ações;
- autosave local versionado no navegador.
- boneca modular com 3 cabeças, braços, pernas, troncos e cabelos, além de 4 olhos em camadas;
- identidade corporal confirmada uma vez e guarda-roupa editável depois;
- pipeline de PNGs em escala de cinza para coloração no jogo.

## Executar

Abra `project.godot` na Godot 4 e execute o projeto.

O mapa, o avatar e as peças desenham placeholders automaticamente enquanto os PNGs finais não existem. Use [`assets/ASSET_GUIDE.md`](assets/ASSET_GUIDE.md) para exportar do Krita com os nomes, tamanhos e camadas esperados.

Próximas etapas: interações dos móveis, animação procedural da boneca, festa assíncrona e sincronização por código.
