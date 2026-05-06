import h5py
import pandas as pd
import numpy as np

# Open the file

# from nexusformat.nexus import nxload

# f = nxload('CM013050.h5')
# print(f.tree)

# with h5py.File('CM013050.h5', 'r') as f:
    # List all root keys to find your dataset name
    # print(list(f.keys()))
    
    # Access a specific dataset and convert to a NumPy array
    # data = f['BDS']
    # print(f.name)
    
#     # Create DataFrame
#     df = pd.DataFrame(data)

# print(df.head())
f = h5py.File('CM013050.h5', 'r')
data = f['BDS/roti/roti_1'][:]  # Adjust the path based on your dataset structure
f.close()

print(data)

# print(data.name)  # List all keys in the dataset

# for name,val in data.items():
#     print(name, val[:])