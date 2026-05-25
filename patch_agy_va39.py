#!/usr/bin/env python3
import hashlib, shutil, struct, sys
from pathlib import Path
src=Path(sys.argv[1] if len(sys.argv)>1 else str(Path.home()/".local/bin/agy"))
dst=Path(str(src)+".va39")
shutil.copyfile(src,dst)
data=bytearray(dst.read_bytes())
def g(o): return struct.unpack_from("<I",data,o)[0]
def p(o,w): struct.pack_into("<I",data,o,w)
uc=lc=mc=mmc=fc=0
for o in range(0,len(data),4):
    w=g(o)
    if (w&0x7F800000)==0x53000000:
        immr=(w>>16)&0x3F; imms=(w>>10)&0x3F
        if immr==42 and imms==44:
            p(o,(w&~((0x3F<<16)|(0x3F<<10)))|(35<<16)|(37<<10)); uc+=1
        elif immr==22 and imms==21:
            p(o,(w&~((0x3F<<16)|(0x3F<<10)))|(29<<16)|(28<<10)); lc+=1
for o in range(0,len(data)-4,4):
    if g(o)==0x92D3800A and g(o+4)==0xF2E0000A:
        p(o,0x9280000A); p(o+4,0xD35DFD4A); mc+=1
for o in range(0,len(data),4):
    if g(o)==0xF2E00029:
        p(o,0xD3596129); mmc+=1
rw={0xD2C20009:0xD2C00409,0xD2C2000A:0xD2C0040A,0xF2C20008:0xF2DFF408,0xF2C20009:0xF2DFF409,0xD2C10009:0xD2C00209,0xD2C1000A:0xD2C0020A,0xF2C38008:0xF2DFF708,0xF2C38009:0xF2DFF709,0x92560A6C:0x925D0A6C,0x92560A6A:0x925D0A6A,0xD2C3000D:0xD2C0060D,0xD2C3000C:0xD2C0060C,0xD2C08008:0xD2C00108}
for o in range(0,len(data),4):
    w=g(o)
    if w in rw: p(o,rw[w])
for o in range(0,len(data)-12,4):
    if g(o)==0xAA1F03E5 and g(o+4)==0xAA1F03E6 and g(o+8)==0xD28036E0 and (g(o+12)&0xFC000000)==0x94000000:
        p(o+8,0xD2800600); fc+=1
dst.write_bytes(data)
dst.chmod(0o755)
print("patched:",dst)
print("ubfx",uc,"lsl",lc,"mask",mc,"mmap",mmc,"faccessat",fc)
