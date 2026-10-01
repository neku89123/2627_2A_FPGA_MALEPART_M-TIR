# 2627_2A_FPGA_MALEPART_M-TIR
# 🛠️ Tutoriel Prise en Main FPGA — Quartus Prime & VHDL

Ce dépôt contient le code source VHDL, la configuration des broches (Pin Planner) et les instructions pas à pas pour la prise en main du logiciel **Intel Quartus Prime Lite** et le ciblage d'une carte FPGA Intel / Altera Cyclone V.

---

## 📌 Présentation du TP

L'objectif de ce TP est de se familiariser avec le flux de conception FPGA :
1. Configuration de l'environnement sous **Quartus Prime Lite v24.1**.
2. Synthèse et affectation des broches I/O (*Pin Planner*).
3. Programmation de la cible via le programmateur **USB Blaster II**.
4. Implémentation d'un composant combinatoire simple (allumage d'une LED par bouton poussoir).
5. Conception séquentielle : division de fréquence d'horloge pour le clignotement d'une LED.
6. **Projet autonome :** Conception et programmation d'un **chenillard**.

---

## 🔌 Matériel & Prérequis

### Logiciels
- **Quartus Prime Lite Edition v24.1** (gratuit, disponible sur Windows et Linux).
- *(Simulation préalable : ModelSim)*.

### Carte FPGA & Composants
- **FPGA cible :** Cyclone V — `5CSEBA6U23I7`
- **Programmation :** Port USB dédié **USB BLASTER II** (situé côté alimentation & HDMI).
- **Alimentation :** Bloc secteur externe requis (le port USB seul ne suffit pas).

---

## 🚀 Étapes de Configuration du Projet

<details>
<summary><b>1. Création du projet Quartus</b></summary>

1. Ouvrir Quartus Prime : `File` > `New Project Wizard`.
2. Indiquer le chemin et le nom du projet (ex: `tuto_fpga`).
   > ⚠️ **Attention :** Ne pas utiliser d'espaces ni de caractères spéciaux/accentués dans les chemins et noms de fichiers !
3. Sélectionner `Empty project`.
4. À l'étape du choix de composant, sélectionner le FPGA **`5CSEBA6U23I7`** *(attention à ne pas choisir les variantes L ou S)*.
5. Finaliser l'assistant (`Finish`).
</details>

<details>
<summary><b>2. Affectation des broches (Pin Planner)</b></summary>

Après avoir rédigé l'entity et lancé une **Analysis & Synthesis**, ouvrir `Assignments` > `Pin Planner` pour associer les signaux de l'entity aux broches physiques :

| Signal VHDL | Type | Broche FPGA | Description |
| :--- | :--- | :--- | :--- |
| `pushl` | Entrada (`in`) | `PIN_AH27` | Bouton poussoir (encodeur gauche) |
| `led0` | Saída (`out`) | `PIN_AG28` | LED 0 |
| `KEY0` | Entrada (`in`) | `PIN_AH17` | Bouton poussoir de Reset (`i_rst_n`) |
| `FPGA_CLK1_50` | Entrada (`in`) | *Voir Manuel* | Horloge principale 50 MHz |

</details>

<details>
<summary><b>3. Compilation et Programmation</b></summary>

1. Lancer la compilation complète : double-cliquer sur **Compile Design**.
2. Connecter et alimenter la carte FPGA sur le port **USB BLASTER II**.
3. Ouvrir l'outil de programmation : `Tools` > `Programmer`.
4. Cliquer sur **Auto Detect** puis sélectionner la puce `5CSEBA6`.
5. Charger le fichier `.sof` : `Clic-droit sur la puce` > `Edit` > `Change File` > sélectionner le fichier dans `/output_files/`.
6. Coucher la case **Program/Configure** et cliquer sur **Start**.
</details>

---

## 💻 Structure du Code & Exercices

### Conventions de Nommage
Pour garantir un code propre et lisible, la convention suivante est adoptée :
- `i_` : Signaux d'entrée (*inputs*)
- `o_` : Signaux de sortie (*outputs*)
- `r_` : Registres
- `s_` : Signaux internes
- `_n` : Signal actif à l'état bas (*Active Low*, ex: `i_rst_n`)

---

### Exercice 1 : Contrôle Combinatoire Simple (`tuto_fpga.vhd`)

Raccordement direct d'un bouton poussoir vers une LED (inversion logique appliquée pour allumer la LED à l'appui).

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity tuto_fpga is
    port (
        pushl : in  std_logic;
        led0  : out std_logic
    );
end entity tuto_fpga;

architecture rtl of tuto_fpga is
begin
    -- Inversion car le bouton poussoir est actif à l'état bas (0 quand appuyé)
    led0 <= not pushl;
end architecture rtl;
