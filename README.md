# 🖥️ FPGA 2A — Prise en main Quartus Prime, VHDL & projet Télécran

Dépôt du module **FPGA** (2ᵉ année, 2026-2027). Il regroupe :

- les travaux pratiques de prise en main de **Intel Quartus Prime Lite** et du **VHDL** (LED, clignotement, chenillard) ;
- le **projet Télécran** : deux encodeurs rotatifs pilotent un point qui dessine sur un écran **HDMI**, le dessin étant mémorisé dans une **RAM double port** et effaçable par un bouton.

---

## 📑 Sommaire

- [Matériel et prérequis](#-matériel-et-prérequis)
- [Structure du dépôt](#-structure-du-dépôt)
- [Démarrage rapide](#-démarrage-rapide)
- [TP1 : prise en main de Quartus](#-tp1--prise-en-main-de-quartus)
- [Projet Télécran](#-projet-télécran)
- [Simulation](#-simulation)
- [Conclusion](#-conclusion)
- [Auteurs](#-auteurs)

---

## 🔌 Matériel et prérequis

### Logiciels

| Outil | Version | Usage |
|-------|---------|-------|
| Intel Quartus Prime Lite | 24.1 | Synthèse, placement-routage, programmation |
| ModelSim / QuestaSim | — | Simulation |

Quartus Prime Lite est gratuit et disponible sous Windows et Linux.

### Carte et périphériques

- **Carte :** **DE10-Nano** — FPGA cible Cyclone V `5CSEBA6U23I7`
  > ⚠️ Bien sélectionner cette référence et non les variantes **L** ou **S**.
- **Programmation :** port USB dédié **USB Blaster II** (côté alimentation et HDMI).
- **Projet Télécran :** sortie **HDMI** de la carte et carte mezzanine **TELECRAN** (2 encodeurs rotatifs avec bouton poussoir intégré).
- **Visualisation HDMI en salle de TP :** adaptateur HDMI → USB et logiciel **VLC** (*Média → Ouvrir un périphérique de capture*).

---

## 📂 Structure du dépôt

```
.
├── TP/                        # encoder.vhd (version du TP)
├── TP1/                       # TP1 : LED, clignotement, chenillard
│   └── Capture/               #   schémas théoriques et RTL (images du README)
├── Projet telecran sim/       # Simulation ModelSim de l'encodeur (encoder_tb.vhd, encoder.do)
├── Capture simulation/        # Chronogramme de simulation + photo de l'image de test HDMI
├── telecran/                  # ✅ Projet Quartus du Télécran (version complète)
├── Projet_telecran/telecran/  # Version antérieure du projet (sans hdmi_controler.vhd)
└── README.md
```

### Fichiers du projet Télécran (`telecran/`)

| Fichier | Rôle |
|---------|------|
| `telecran.vhd` | Entité principale : relie PLL, HDMI, encodeurs, RAM et effacement |
| `encoder.vhd` | Décodage de deux encodeurs en quadrature → coordonnées X et Y |
| `hdmi_controler.vhd` | Génération des signaux de synchronisation HDMI et des coordonnées de pixel |
| `dpram.vhd` | Mémoire double port 720 × 480 × 8 bits (mémoire d'image) |
| `i2c/` | Configuration I2C du transmetteur HDMI (`I2C_HDMI_Config.v`, …) |
| `pll/` | PLL générant l'horloge pixel de 27 MHz à partir de l'horloge 50 MHz |
| `telecran.qsf` / `.sdc` | Affectation des broches et contraintes de timing |

---

## 🚀 Démarrage rapide

1. Cloner le dépôt :
   ```bash
   git clone https://github.com/neku89123/2627_2A_FPGA_MALEPART_M-TIR.git
   ```
2. Ouvrir dans **Quartus Prime Lite 24.1** le projet voulu :
   - Télécran : `telecran/telecran.qpf`
   - TP1 : `TP1/TP1_tuto_FPGA.qpf`
3. Compiler (**Processing → Start Compilation**).
4. Brancher la carte sur le port **USB Blaster II**.
5. Programmer via **Tools → Programmer** avec le fichier `.sof` généré.

---

## 🧪 TP1 : prise en main de Quartus

Objectifs : configurer l'environnement, affecter les broches I/O, programmer la cible, puis passer de la logique combinatoire à la logique séquentielle.

### Exercice 1 : contrôle combinatoire (`TP1_tuto_FPGA.vhd`)

Une LED s'allume tant que le bouton poussoir est maintenu :

```vhdl
led0 <= pushl;
```

Les entrées et sorties sont affectées aux broches de la carte dans le **Pin Planner**, puis le projet est compilé et implémenté.

### Exercice 2 : division d'horloge (`led_blink.vhd`)

Une première version, sans division d'horloge, compile mais la LED **ne clignote pas de façon visible** : la fréquence est trop élevée pour l'œil. On ajoute donc un compteur qui génère un signal d'autorisation (`r_led_enable`) à fréquence réduite ; la LED change d'état à chaque impulsion.

```vhdl
process(i_clk, i_rst_n)
    variable counter : natural range 0 to 5000000 := 0;
begin
    if (i_rst_n = '0') then
        counter := 0;
        r_led_enable <= '0';
    elsif (rising_edge(i_clk)) then
        if (counter = 5000000) then
            counter := 0;
            r_led_enable <= '1';
        else
            counter := counter + 1;
            r_led_enable <= '0';
        end if;
    end if;
end process;
```

Il faut aussi assigner les broches d'**horloge** et de **reset** dans le Pin Planner.

**Version sans division d'horloge** : on réalise d'abord un schéma théorique, puis on regarde le schéma RTL généré par Quartus. La LED ne clignote pas visiblement.

| Schéma théorique | Schéma RTL |
|:---:|:---:|
| ![Schéma théorique sans division d'horloge](TP1/Capture/schema1.png) | ![Schéma RTL, clignotement invisible](TP1/Capture/clignotement_led_invisible.png) |

**Version avec compteur (division d'horloge)** : le clignotement devient visible.

| Schéma théorique | Schéma RTL |
|:---:|:---:|
| ![Schéma théorique avec compteur](TP1/Capture/schema2.jpeg) | ![Schéma RTL, clignotement visible](TP1/Capture/clignotement_led.png) |

### Exercice 3 : chenillard

La LED unique (`std_logic`) devient un vecteur de 10 LEDs (`std_logic_vector(9 downto 0)`). À chaque impulsion de `r_led_enable`, le bit allumé se décale d'un cran :

```vhdl
r_leds <= r_leds(8 downto 0) & r_leds(9);
```

Schéma bloc obtenu :

![Schéma bloc du chenillard](TP1/Capture/chenillard.png)

**Affectation des broches des LEDs :**

| Nom  | GPIO  | FPGA |
|------|-------|------|
| LED0 | J1:5  | AG28 |
| LED1 | J1:7  | AE25 |
| LED2 | J1:9  | AG26 |
| LED3 | J1:13 | AG25 |
| LED4 | J1:17 | AG23 |
| LED5 | J1:21 | AH21 |
| LED6 | J1:25 | AF22 |
| LED7 | J1:27 | AG20 |
| LED8 | J1:33 | AG18 |
| LED9 | J1:37 | AG15 |

---

## 🎨 Projet Télécran

### Principe

```
 Encodeur gauche ─┐                                   ┌─► Port B (lecture, 27 MHz) ─► HDMI
                  ├─► encoder ─► (x, y) ─► dpram ─────┘
 Encodeur droit  ─┘     │          Port A (écriture, 50 MHz)
                        └─► LEDs             ▲
 Bouton rst ─► balayage d'effacement ────────┘
```

- L'**encodeur gauche** fait varier **X**, l'**encodeur droit** fait varier **Y**.
- À chaque position, un pixel blanc (`0xFF`) est écrit dans la mémoire : le tracé **reste affiché**.
- Le contrôleur HDMI lit en permanence la mémoire pour afficher l'image en niveaux de gris (la valeur 8 bits est répétée sur les canaux R, G et B).

### 1. Contrôleur HDMI (`hdmi_controler.vhd`)

Résolution **720 × 480**, horloge pixel **27 MHz** fournie par la PLL. Le contrôleur génère `hs`, `vs`, `de` ainsi que les coordonnées `x`, `y` et l'adresse du pixel courant (`y × 720 + x`).

| Paramètre | Horizontal | Vertical |
|-----------|-----------|----------|
| Zone active | 720 | 480 |
| Synchro | 61 | 5 |
| Front porch | 58 | 30 |
| Back porch | 18 | 9 |

Le transmetteur HDMI de la carte est configuré par I2C au démarrage (`I2C_HDMI_Config`). Les signaux d'horloge et de reset viennent de la PLL (`s_clk_27`, `s_rst_n`).

Pour valider le contrôleur, une image de test a d'abord été générée à partir des coordonnées :

```vhdl
o_hdmi_tx_d(23 downto 16) <= std_logic_vector(to_unsigned(s_x_counter, 8)); -- rouge
o_hdmi_tx_d(15 downto 8)  <= std_logic_vector(to_unsigned(s_y_counter, 8)); -- vert
o_hdmi_tx_d(7 downto 0)   <= (others => '0');                               -- bleu
```

Résultat sur l'écran : la composante rouge croît avec X et la verte avec Y. Les valeurs étant tronquées sur 8 bits, le dégradé se répète (≈ 3 fois horizontalement et 2 fois verticalement) :

![Image de test HDMI : dégradé rouge/vert issu des compteurs x et y](<Capture%20simulation/Capture%20d'%C3%A9cran%202026-11-05%20111251.png>)

### 2. Lecture des encodeurs (`encoder.vhd`)

- Les signaux A et B de chaque encodeur sont **échantillonnés à 1 kHz** (prescaler de 50 000 sur l'horloge 50 MHz) : cela filtre les rebonds.
- Les fronts de A et B sont détectés, et le **sens de rotation** est déduit de l'état de l'autre voie (décodage en quadrature).
- Chaque encodeur incrémente ou décrémente un compteur 10 bits : `o_x` (gauche) et `o_y` (droit).
- Les 4 bits de poids faible de chaque compteur sont recopiés sur 8 LEDs (`o_leds`) pour le débogage.

Condition de comptage (par encodeur) :

| Action | Condition |
|--------|-----------|
| Incrément | front montant de A avec B bas, **ou** front descendant de A avec B haut |
| Décrément | front montant de B avec A bas, **ou** front descendant de B avec A haut |

> ℹ️ L'écriture en mémoire n'a lieu que si `x < 720` et `y < 480`. En dehors de l'écran, le point n'est pas tracé.

### 3. Mémorisation (`dpram.vhd`)

La mémoire **Dual-Port** de 720 × 480 mots de 8 bits possède deux ports indépendants, chacun avec sa propre horloge :

| Port | Horloge | Rôle |
|------|---------|------|
| A | 50 MHz | Écriture du pixel dessiné (ou de l'effacement) |
| B | 27 MHz | Lecture par le contrôleur HDMI pour l'affichage |

Elle est instanciée dans `telecran.vhd` et la sortie du port B alimente `o_hdmi_tx_d`.

### 4. Effacement

Le bouton poussoir de l'**encodeur droit** (`RIGHT_PB`, signal `rst`, actif à l'état bas) lance un **balayage de toute la mémoire** : l'adresse est incrémentée à chaque cycle d'horloge et la valeur `0x00` est écrite partout. Un multiplexeur donne la priorité à l'effacement sur le dessin tant que le balayage est en cours (≈ 345 600 cycles). Le même balayage est exécuté au démarrage.

### 5. Broches principales

| Signal VHDL | Nom carte | Broche FPGA |
|-------------|-----------|-------------|
| `i_clk_50` | Horloge 50 MHz | PIN_V11 |
| `i_rst_n` | Reset | PIN_AH17 |
| `i_left_ch_a` | LEFT_A (J1:8) | PIN_AF27 |
| `i_left_ch_b` | LEFT_B (J1:6) | PIN_AF28 |
| `i_left_pb` | LEFT_PB (J1:10) | PIN_AH27 |
| `i_right_ch_a` | RIGHT_A (J2:38) | PIN_AA26 |
| `i_right_ch_b` | RIGHT_B (J2:39) | PIN_AA13 |
| `rst` (effacement) | RIGHT_PB (J2:40) | PIN_AA11 |

Les LEDs de la carte mezzanine utilisent les mêmes broches que dans le tableau du TP1. J2 correspond à GPIO0 et J1 à GPIO1.

> 🚧 *À compléter : photos du résultat sur la carte (déplacement du pixel, tracé mémorisé, effacement).*

---

## 🔬 Simulation

Le dossier `Projet telecran sim/` contient la simulation de l'encodeur sous ModelSim :

```tcl
# Depuis ModelSim, dans le dossier "Projet telecran sim"
do encoder.do
```

Le script ([`encoder.do`](Projet%20telecran%20sim/encoder.do)) compile [`encoder.vhd`](Projet%20telecran%20sim/encoder.vhd) et le banc de test [`encoder_tb.vhd`](Projet%20telecran%20sim/encoder_tb.vhd). Il crée la bibliothèque `work`, lance la simulation, affiche les signaux des deux encodeurs ainsi que `o_x`, `o_y` et `o_leds`, puis exécute 10 µs.

![Chronogramme de simulation de l'encodeur](Capture%20simulation/simulation%20encoder.png)

Lecture du chronogramme :

- La séquence sur `A_left` / `B_left` fait **incrémenter** `o_x` : 0 → 1 → 2.
- La séquence sur `B_right` / `A_right` fait **décrémenter** `o_y` : 0 → 1023 → 1022. Le compteur 10 bits **repasse par 1023** en passant sous zéro.
- `o_leds` regroupe les 4 bits de poids faible de chaque compteur (`o_y` puis `o_x`) : `01`, `02`, `F2`, `E2`.

---

## 📚 Ressources

- Énoncé du TP (ENSEA) : [fpga_tp.md](https://github.com/lfiack/ENSEA_2A_FPGA_Public/blob/main/mineure/3-tp/fpga_tp.md)
- Principe du télécran : [Écran magique (Wikipédia)](https://fr.wikipedia.org/wiki/%C3%89cran_magique)

---

## ✅ Conclusion

Ces travaux ont permis de prendre en main Quartus Prime (analyse, affectation des broches, compilation, programmation, vérification sur la carte), puis de réaliser un système complet : lecture de capteurs, affichage HDMI, mémorisation d'image et effacement.

---

## 👥 Auteurs

Projet réalisé dans le cadre du module FPGA, 2ᵉ année (2026-2027).
