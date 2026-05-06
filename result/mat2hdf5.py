import numpy as np
import pandas as pd

import h5py
from hdf5plugin import Zstd, Blosc
# h5compression = Zstd(clevel=22)
# h5compression = Blosc(clevel=9, shuffle=Blosc.SHUFFLE, cname='zstd')
h5compression = None

# import importlib.util
import sys
from os import makedirs, path
sys.path.insert(0, "../function/py")
from mat2dataframe import mat2dataframe

mat_dir = 'matfile/2025/305/'# 'Mat_files/'
station = 'CM013050'
matfile = f'{mat_dir}{station}.mat'

T_list, fdata = mat2dataframe(matfile)
# [SOD,sys,PRN,STEC,VTEC,ROTI]



with h5py.File(f'../result/{station}.h5', 'w') as h5save:
    for T,satname in zip(T_list,fdata):
        grp = h5save.create_group(satname)
        rotigrp = grp.create_group("roti")
        for key, val in [(col, T[col]) for col in T.columns if col.startswith('roti_')]:
            rotigrp.create_dataset(key, data=val.to_numpy(), compression=h5compression)
        vtecgrp = grp.create_group("vtec")
        for key, val in [(col, T[col]) for col in T.columns if col.startswith('vtec_')]:
            vtecgrp.create_dataset(key, data=val.to_numpy(), compression=h5compression)

# for T,satname in zip(T_list,fdata):
#     print(type(satname))


# if __name__ == "__main__":
#     from nexusformat.nexus import nxload

#     f = nxload('CM013050.h5')
#     print(f.tree)