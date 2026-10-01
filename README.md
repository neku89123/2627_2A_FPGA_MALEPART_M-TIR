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


---

## 🚀 Étapes de Configuration du Projet
Lors de la création du fichier on sélectionne le FPGA **`5CSEBA6U23I7`** *(on fait attention à ne pas choisir les variantes L ou S)*.
</details>


---


### Exercice 1 : Contrôle Combinatoire Simple (`tuto_fpga.vhd`)

On exécute le code fourni par le tp. Dans le cadre d'un tuto, l'objectif de ce code est de simplement allumé une LED lorsque le bouton poussoir est maintenu.
Pour faire allumer la LED, on se rend dans le PIN Planner afin d'assigner chaque sortie et entrée à une Pin de la carte. Une fois fait on compile le programme puis on l'implémente dans la carte.

---


### Exercice 2 : Logique séquentielle et division d'horloge (`led_blink.vhd`)

On exécute le code fourni par le tp.On remarque que la led ne clignote pas ! .
Pour faire allumer la LED, on se rend dans le PIN Planner afin d'assigner chaque sortie et entrée à une Pin de la carte. Une fois fait on compile le programme puis on l'implémente dans la carte.
