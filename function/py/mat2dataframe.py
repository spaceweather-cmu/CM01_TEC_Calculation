from scipy.io import loadmat
import numpy as np
import pandas as pd

def mat2dataframe(matfile):
    matfile = loadmat(matfile)
    # [SOD,sys,PRN,STEC,VTEC,ROTI]

    data = matfile['CM01'][0,0]
    fdata = data.dtype.names

    date = data['GPS'][0,0]['date'][0]

    year = date[0]
    mth = date[1]
    dt = date[2]

    # T_list = [None]*(len(fdata)-1)
    T_list = {}

    for i, sys in enumerate(fdata[:-1]):
        # print(sys)
        subdata = data[sys].ravel()[0]
        # print(subdata.dtype.names)
        time = subdata['ind'].ravel()
        nanmask = np.isfinite(time)
        SOD = sorted(list(set(time[nanmask]-1)))  # MATLAB is 1-based; convert to 0-based
        SOD = np.array(SOD).astype(int)
        stec = pd.DataFrame({f'stec_{i+1}': subdata['stec'][SOD,i] for i in range(subdata['stec'].shape[1])})
        vtec = pd.DataFrame({f'vtec_{i+1}': subdata['vtec'][SOD,i] for i in range(subdata['vtec'].shape[1])})
        roti = pd.DataFrame({f'roti_{i+1}': subdata['roti'][SOD,i] for i in range(subdata['roti'].shape[1])})
        ipplat = pd.DataFrame({f'ipplat_{i+1}': subdata['ipplat'][SOD,i] for i in range(subdata['ipplat'].shape[1])})
        ipplon = pd.DataFrame({f'ipplon_{i+1}': subdata['ipplon'][SOD,i] for i in range(subdata['ipplon'].shape[1])})
        nPRN = pd.DataFrame({'nPRN': np.ones(len(SOD),dtype=int) * stec.shape[1]})
        
        system = pd.DataFrame({'system': [sys]*SOD.shape[0]})

        SOD = pd.DataFrame({'SOD':SOD+1}) # Convert back to 1-based for output consistency
        T_list[sys] = pd.concat([system, SOD, nPRN, vtec, stec, roti, ipplat, ipplon], axis=1)
        # print(T_list[sys].head()) # inspect the first few rows of the DataFrame
        print(sys, type(sys))
    return T_list, fdata[:-1] # return DataFrames of all systems

if __name__ == "__main__":
    mat_dir = '../Results/matfile/2025/305/'# 'Mat_files/'
    station = 'CM013160'
    matfilename = f'{mat_dir}{station}.mat'

    T_list = mat2dataframe(matfilename)
