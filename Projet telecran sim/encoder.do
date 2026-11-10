# --- Script de compilation et de simulation pour ModelSim / QuestaSim ---

# 1. Créer la bibliothèque de travail "work"
vlib work

# 2. Compiler les fichiers VHDL
vcom -93 encoder.vhd
vcom -93 encoder_tb.vhd

# 3. Lancer la simulation
vsim -voptargs=+acc work.encoder_tb

# 4. Ajouter les signaux pertinents à la fenêtre Wave
add wave -radix decimal /encoder_tb/clk
add wave -radix decimal /encoder_tb/reset

# Signaux de l'encodeur Gauche
add wave -color yellow /encoder_tb/A_left
add wave -color orange /encoder_tb/B_left

# Signaux de l'encodeur Droit
add wave -color cyan /encoder_tb/A_right
add wave -color pink /encoder_tb/B_right

# Sorties calculées
add wave -radix decimal /encoder_tb/o_x
add wave -radix decimal /encoder_tb/o_y
add wave -radix hexadecimal /encoder_tb/o_leds

# 5. Exécuter la simulation pour une durée suffisante
run 10 us

# Ajuster le zoom de la fenêtre wave
wave zoom full