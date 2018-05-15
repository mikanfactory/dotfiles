import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt


# matplotlib
def figsize(sizex, sizey):
    mpl.rcParams['figure.figsize'] = (sizex, sizey)


plt.style.use('seaborn-colorblind')
plt.style.use('seaborn-whitegrid')


# pandas
def max_row(n):
    pd.options.display.max_rows = n


pd.options.display.width = 100
