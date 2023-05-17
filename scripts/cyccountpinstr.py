import subprocess
import sys
import time


FOUT_DIR = 'scripts/fout/'

SIM_DIR = 'processor/sail-core/simulation/'
VERILOG_DIR= 'processor/sail-core/verilog/'

VCDOUT_DIR = 'scripts/vcdout/'

EXEOUT_DIR = 'scripts/exeout/'


FNAME = sys.argv[1].split('.')[0]
DEPENDENCIES = sys.argv[2:]

with open(f"{FOUT_DIR}{FNAME}.txt", 'w') as f:
    cmdl = ['iverilog',
         '-o',
         f'{FNAME}',
         f'{SIM_DIR}{FNAME}_sim.v',]
    
    cmdl += ([f'{VERILOG_DIR}{FNAME}.v'] + [f'{VERILOG_DIR}{g.split(".")[0]}.v' for g in DEPENDENCIES])

    process = subprocess.Popen(
        cmdl,
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True
    )

    for line in process.stdout:
        sys.stdout.write(line)
        f.write(line)
    
    process = subprocess.Popen([f'./{FNAME}'])

    time.sleep(1)

    process = subprocess.Popen([
        'rm', f'{FNAME}'
    ])
    
    process = subprocess.Popen([
        'mv', f'{FNAME}.vcd', f'{VCDOUT_DIR}'
    ])

    
                               
    process.wait()



