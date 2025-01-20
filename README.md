# Hardware1
The project for the university course "Hardware Digital systems at low logic levels 1".


### Arch linux - iverilog and gtkwave
Packages installation:
```bash
sudo pacman -S iverilog gtkwave
```
Example code compilation/execution:
```bash
# Compilation
iverilog calc.v calc_tb.v -o out

# Execution
./out 
# or
vvp out
# produces the dump.vcd file
```
Example waveform simulation:
```bash
gtkwave dump.vcd
```

### Questa Setup
Include the license file and the binary folder of Questa inside PATH.
```bash 
export LM_LICENSE_FILE=/path/to/licensing/file.dat
export PATH=$PATH:/path/to/questa/bin
```

Open Questa:
```bash
# Run Software
vsim
# Open a certain project
vsim project_name.mpf
```