# 🤝 Contributing

* The Total Electron Content(TEC) calculation on MATLAB from RINEX 3.04
Calculate TEC based on dual-frequency receiver (GPS) 
* Original by **Napat Tongkasem, Somkit Sopan, Jirapoom Budtho, Nantavit Wongthodsarat**

Version 1.2 
| Date                  |            Activities                         |
| --------------------- | ----------------------------------------------|
|  15/02/2019           |                 Create the program            |
|  04/10/2022           |  Fix some bug (Outlinier correction, receiver position, ROTI , Ploting)           |
|  10/10/2022           |                Update Roti calculation           |
|  31/06/2023          |      Develop to RINEX 3.04 with PolarRx5(SEPT) and F9P(u-blox) |

The program need linux command. Cygwin must be installed
- install Cygwin-setup-x86_64.exe (64-bit ver.)
or download: http://cygwin.com/install.html

Main program is ProcessTECCalculation.m

KMILT laboratory website
- http://iono-gnss.kmitl.ac.th/

```text"
Advisor: Prof.Dr. Pornchai Supnithi
CSSRG Laboratory
School of Telecommunication Engineering
Faculty of Engineering
King Mongkut's Institute of Technology Ladkrabang
Bangkok, Thailand
```

# :chart_with_downwards_trend: Output: data 1 day 
```text
TEC.vertical    = Vertical Total Electron Content(VTEC)
TEC.slant       = Slant Total Electron Content(STEC)
TEC.withrcvbias = STEC with receiver DCB
TEC.withbias    = STEC with satellite and receiver DCB
TEC.STECp       = STEC calculated from code range
TEC.STECl       = STEC calculated from carrier phase
DCB.sat         = Satellite DCB
DCB.rcv         = Receiver DCB
prm.elevation   = elevation angle
ROTI            = Rate Of Change TEC Index
```

# :eyes:  Getting Started for contributors
-- If you want to work on the terminal or Visual Studio 
```bash id="c0v2r9"
git clone https://github.com/spaceweather-cmu/CM01_TEC_dev.git
cd CM01_TEC_dev
```
:exclamation: Please work on **dev** branch :exclamation:

-- To makes changes: switches to dev branch
```bash id="c0v2r9"
git checkout -b dev origin/dev
```
-- Make changes and upload to GitHub
```bash id="c0v2r9"
git add .
git commit -m "update feature"
git push origin dev
```
-- To pull latest updates
```bash id="c0v2r9"
git checkout -b dev origin/dev
git pull origin dev
```

# :zap: TEC_CMU
:triangular_flag_on_post: This example only runs one file for now—please wait for an update. :zzz: :sleeping::sleeping:

Here are the steps to read TEC data from MATLAB:

1. main program is "main_teccal_30.m" to get file.mat💡


👉 change outname (ex "CM013160"), stations, and p_path as your directory the you will get matfile in **Results** folder.

:boom::boom:  Don’t forget to change -- **p_path** -- to your work directory. :boom::boom:
  
👉 To test the program, please download the RINEX file from https://drive.google.com/drive/folders/13-18mmAL4U4alot1mx9xbqvDfGlgyGbc?usp=sharing to folder RINEX


2. "Run **mat2dataframe.p**y in the result folder to get file.csv. [-- MATLAB (**convertmat2csv.m**) also works!)]"
3. plot data from csv using 21Dgraph30.py (an example plot for CM013160 from P'Jumbo) :point_down::point_down:
## 
<img src="result/figure//Example_plot_from_JB_CM013160.jpg" width="600">


## 📜 License

© 2026 CM01 | Tatpicha n JumboAekawit
