import numpy as np
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt


# matplotlib
default_figsize = [6, 4]
default_font_size = 10
default_tick_size = 10  # 'medium'


def figsize():
    return mpl.rcParams['figure.figsize']


def update_figsize(sizex, sizey):
    mpl.rcParams['figure.figsize'] = (sizex, sizey)
    return mpl.rcParams['figure.figsize']


def fontsize():
    return plt.rcParams['font.size']


def update_fontsize(size):
    plt.rcParams['font.size'] = size


def update_mpl_setting():
    update_figsize(*np.array(default_figsize) * 1.3)
    plt.rcParams['font.family'] = 'IPAexGothic'
    plt.rcParams['font.size'] = 14
    plt.rcParams['xtick.labelsize'] = 12
    plt.rcParams['ytick.labelsize'] = 12


plt.style.use('seaborn-colorblind')
plt.style.use('seaborn-whitegrid')


# pandas
def max_row(n):
    pd.options.display.max_rows = n


pd.options.display.width = 100
