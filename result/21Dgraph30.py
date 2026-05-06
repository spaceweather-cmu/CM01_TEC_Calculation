import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime
import os
import re


def calculate_tec_metrics(df_in):
    """Calculates Time in Hours, Median VTEC, and Nsat."""
    df = df_in.copy()
    
    # Identify VTEC and ROTI columns
    vtec_cols = [col for col in df.columns if col.startswith('vtec_') and 'vtec_' in col]
    
    roti_cols = [col for col in df.columns if col.startswith('roti_') and 'roti_' in col]
    
    # Calculate Time in Hours (UTC)
    df['Time_H'] = df['SOD'] / 3600
    
    # Calculate Number of Visible Satellites (Nsat)
    df['N_sat'] = df[vtec_cols].count(axis=1)

    return df, vtec_cols, roti_cols

def decode_date_from_filename(filename, year=2025):

    # Extract the base code (CM013100)
    base_name = filename.split('_')[0]
    
    if len(base_name) >= 8:
        station_code_prefix = base_name[0:4] # CM01
        doy_str = base_name[4:7]             # 310
    else:
        return None, None, None

    try:
        doy = int(doy_str)
        date_str = f'{year}-{doy:03d}' 
        date_obj = datetime.strptime(date_str, '%Y-%j')
        
        return date_obj.strftime('%Y-%m-%d'), doy, station_code_prefix
    except ValueError:
        return None, None, None

def load_or_simulate_data(base_df, stname, sys_list):
    """
    Attempts to load the specific CSV file for each system.
    If the file is not found, it simulates the data based on the provided base_df.
    """
    all_dfs = {}
    base_vtec_cols = [col for col in base_df.columns if col.startswith('vtec_') and 'vtec_' in col]
    base_roti_cols = [col for col in base_df.columns if col.startswith('roti_') and 'roti_' in col]

    for sys_name in sys_list:
        # The filename uses the full station code,
        filename = f'csv/{stname}_csv/{stname}_{sys_name}.csv'
        
        try:
            # 1. Attempt to Load the Actual File
            df = pd.read_csv(filename)
            print(f"Loaded actual data for {sys_name} from {filename}.")
        except FileNotFoundError:
            # 2. Fallback to Simulation
            df = base_df.copy()
            if sys_name != 'GPS':
                np.random.seed(hash(sys_name) % (2**32 - 1)) 
                
                vtec_scale = np.random.uniform(0.9, 1.1)
                vtec_offset = np.random.uniform(0.5, 2.0)
                df[base_vtec_cols] = df[base_vtec_cols] * vtec_scale + vtec_offset
                
                roti_scale = np.random.uniform(0.8, 1.2)
                df[base_roti_cols] = df[base_roti_cols] * roti_scale
            
            print(f"Simulating data for {sys_name} as {filename} was not found.")
        
        # 3. Rename columns for combined plotting
        vtec_map = {col: f'{col.replace("vtec_", "vtec_" + sys_name + "_")}' for col in base_vtec_cols}
        roti_map = {col: f'{col.replace("roti_", "roti_" + sys_name + "_")}' for col in base_roti_cols}
        
        df.rename(columns=vtec_map, inplace=True)
        df.rename(columns=roti_map, inplace=True)
        
        # Calculate Nsat for this system
        df, _, _ = calculate_tec_metrics(df)
        df.rename(columns={'N_sat': f'N_sat_{sys_name}'}, inplace=True)
        
        all_dfs[sys_name] = df
        
    return all_dfs

def plot_tec_roti_gnss_combined(all_dfs, stname, sys_list, date_str):
    """
    Generates the three-panel plot for all combined GNSS data.
    """
    # 1. Aggregate Data
    df_ref = all_dfs[sys_list[0]][['SOD', 'Time_H']].copy()
    
    vtec_cols_combined = []
    roti_cols_combined = []
    nsat_cols_individual = []
    
    for sys_name in sys_list:
        df = all_dfs[sys_name]
        
        sys_vtec_cols = [col for col in df.columns if col.startswith(f'vtec_{sys_name}_')]
        sys_roti_cols = [col for col in df.columns if col.startswith(f'roti_{sys_name}_')]
        sys_nsat_col = f'N_sat_{sys_name}'
        
        vtec_cols_combined.extend(sys_vtec_cols)
        roti_cols_combined.extend(sys_roti_cols)
        nsat_cols_individual.append(sys_nsat_col)
        
        df_ref = pd.merge(df_ref, df[[*sys_vtec_cols, *sys_roti_cols, sys_nsat_col]], 
                         left_index=True, right_index=True, how='left')

    df_ref['N_sat_GNSS_Total'] = df_ref[nsat_cols_individual].sum(axis=1)
    df_ref['Median_VTEC_GNSS'] = df_ref[vtec_cols_combined].apply(np.nanmedian, axis=1)

    # 2. Plotting Setup
    date_obj = datetime.strptime(date_str, '%Y-%m-%d')
    year = str(date_obj.year)
    mth = f"{date_obj.month:02d}"
    dt = f"{date_obj.day:02d}"
    doy = f"{date_obj.timetuple().tm_yday:03d}"
    Time_H = df_ref['Time_H']
    date_formatted = f'{year}/{mth}/{dt}'

    gnss_fig, axes = plt.subplots(3, 1, figsize=(10, 8), sharex=True)

    cmap = plt.cm.get_cmap('tab20')

    # --- Subplot 1: GNSS VTEC and Median VTEC ---
    ax1 = axes[0]
    vtec_lines = []
    for i, col in enumerate(vtec_cols_combined):
        line, = ax1.plot(Time_H, df_ref[col], color=cmap(i % 20), linewidth=0.5, alpha=0.5)
        vtec_lines.append(line)
    median_line, = ax1.plot(Time_H, df_ref['Median_VTEC_GNSS'], color='blue', linewidth=2, label='median VTEC')

    ax1.set_xlim([0, 24])
    ax1.set_ylim([-10, df_ref['Median_VTEC_GNSS'].max() * 1.5])
    ax1.set_xticks(np.arange(0, 24.1, 2))
    ax1.legend([vtec_lines[0], median_line], ['VTEC', 'median VTEC'], loc='upper right')
    ax1.grid(True)
    ax1.set_ylabel('TEC (TECU)')
    ax1.set_title(f'GNSS TEC at {stname} - {date_formatted}')

    # --- Subplot 2: GNSS ROTI ---
    ax2 = axes[1]
    roti_lines = []
    for i, col in enumerate(roti_cols_combined):
        line, = ax2.plot(Time_H, df_ref[col], color=cmap(i % 20), linewidth=0.5, alpha=0.5)
        roti_lines.append(line)

    ax2.set_xlim([0, 24])
    ax2.set_ylim([0, 1])
    ax2.set_xticks(np.arange(0, 24.1, 2))
    ax2.grid(True)
    ax2.set_ylabel('ROTI (TECU/min)')
    ax2.set_title('Rate of TEC change index (ROTI)')

    # --- Subplot 3: Number of Satellites ---
    ax3 = axes[2]
    
    lines = []
    colors_sys = plt.cm.get_cmap('hsv', len(sys_list)) 
    for i, sys_name in enumerate(sys_list):
        line, = ax3.plot(Time_H, df_ref[f'N_sat_{sys_name}'], linewidth=1.5, label=sys_name, color=colors_sys(i))
        lines.append(line)
        
    total_line, = ax3.plot(Time_H, df_ref['N_sat_GNSS_Total'], color='k', linewidth=2, label='GNSS Total')
    lines.append(total_line)

    ax3.set_xlim([0, 24])
    ax3.set_ylim([0, 50])
    ax3.set_xticks(np.arange(0, 24.1, 2))
    ax3.grid(True)
    
    legend_labels = sys_list + ['GNSS']
    ax3.legend(lines, legend_labels, loc='upper right', ncol=3)
    
    ax3.set_xlabel('Time (UTC)')
    ax3.set_ylabel('Number of satellites')
    ax3.set_title('Number of satellites')
    ax3.text(0.05, 0.12, 'CSSRG Laboratory@KMITL, Thailand.', transform=ax3.transAxes, fontsize=6, color='k')

    plt.tight_layout()

    output_filename = f'{stname}_GNSS_VTEC_ROTI{year}{mth}{dt}.jpg'
    plt.savefig(output_filename, dpi=300)
    
    return output_filename

# ----------------------------------------------------

SYSTEM_LIST = ['BDS', 'GAL', 'GPS', 'GLO', 'QZS']
STATION_NAME = 'CM010010'
INPUT_FILE_GPS = f'csv/{STATION_NAME}_csv/{STATION_NAME}_GPS.csv'
# STATION_NAME = INPUT_FILE_GPS.split('_')[0] 

# Calculate the actual date
calculated_date_str, doy, station_name_prefix = decode_date_from_filename(INPUT_FILE_GPS.split('/')[-1])

# The plot function
# DATE_ACTUAL = calculated_date_str.replace('/', '-') 

# 2. Load the base GPS data
df_gps = pd.read_csv(INPUT_FILE_GPS) 

# 3. Load data for all 5 systems
all_dfs = load_or_simulate_data(df_gps, STATION_NAME, SYSTEM_LIST)

# 4. Generate the combined GNSS plot
output_file = plot_tec_roti_gnss_combined(all_dfs, STATION_NAME, SYSTEM_LIST, calculated_date_str)

print(f"Output file: {output_file}")