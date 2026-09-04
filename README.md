# GEEK GIRL DOLLHOUSE

Jogo cozy de casinha de boneca e decoração para Web mobile, criado com Godot 4.

## Estado atual

Vertical slice offline com mapa-casa:

- viewport retrato `720 x 1280`;
- casa inteira como mapa, com zoom suave por cômodo;
- três cômodos navegáveis: quarto, sala e estúdio;
- casa vertical de três andares com coluna lateral de circulação e escadas;
- profundidade 2.5D simulada por paredes laterais e pisos trapezoidais;
- duas peças placeholder por cômodo, arrastáveis e colorizáveis;
- posicionamento de peças;
- desfazer até dez ações;
- autosave local versionado no navegador.
- boneca modular com 3 cabeças, braços, pernas, troncos e cabelos, além de 4 olhos em camadas;
- identidade corporal confirmada uma vez e guarda-roupa editável depois;
- pipeline de PNGs em escala de cinza para coloração no jogo.

## Assets de avatar importados

- uma base corporal recortada em cabeça, tronco, braços e pernas;
- quatro formatos de olhos com estados aberto, semiaberto e fechado;
- íris e pupilas em camadas independentes;
- três cabelos, cada um separado em camada traseira e frontal;
- uma boca fechada e uma camada de roupa de baixo;
- três conjuntos casuais completos no guarda-roupa;
- opções corporais 2 e 3 temporariamente duplicadas da opção 1 até receberem arte própria.

## Executar

Abra `project.godot` na Godot 4 e execute o projeto.

O mapa, o avatar e as peças desenham placeholders automaticamente enquanto os PNGs finais não existem. Use [`assets/ASSET_GUIDE.md`](assets/ASSET_GUIDE.md) para exportar do Krita com os nomes, tamanhos e camadas esperados.

Próximas etapas: interações dos móveis, animação procedural da boneca, festa assíncrona e sincronização por código.
