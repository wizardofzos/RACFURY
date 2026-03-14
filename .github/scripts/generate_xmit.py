import os
import sys
from pathlib import Path 
from xmi import create_xmi
import shutil


inputfile = Path('RACFURY.rexx')
outputfile = Path('RACFURY.XMIT')

tmppds = Path(sys.argv[1])

shutil.copy(inputfile, tmppds)
create_xmi(tmppds, output_file=outputfile, from_user="WIZARD", from_node="GITHUB")



