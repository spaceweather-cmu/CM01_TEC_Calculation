import numpy as np
import pandas as pd

# import importlib.util
import sys
from os import makedirs, path
sys.path.insert(0, "../function/py")
from mat2dataframe import mat2dataframe

mat_dir = 'matfile/'# 'Mat_files/'
station = 'CM010010'
matfile = f'{mat_dir}{station}.mat'

T_list, fdata = mat2dataframe(matfile)
# [SOD,sys,PRN,STEC,VTEC,ROTI]


for T,sys in zip(T_list,fdata[:-1]):
    if not path.isdir(f'csv/{station}_csv'):
        makedirs(f'csv/{station}_csv')
    T.to_csv(f'csv/{station}_csv/{station}_{sys}.csv', index=False)