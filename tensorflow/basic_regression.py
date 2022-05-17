#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
import tensorflow as tf

from tensorflow import keras
from tensorflow.keras import layers

print(tf.__version__)

np.set_printoptions(precision = 3, suppress = True)

# Load dataset
url1 = 'http://archive.ics.uci.edu/ml/machine-learning-databases/'
url2 = 'auto-mpg/auto-mpg.data'
url = url1 + url2
column_names = ['MPG', 'Cylinders', 'Displacement', 'Horsepower', 'Weight',
                'Acceleration', 'Model Year', 'Origin']

raw_dataset = pd.read_csv(url, names = column_names,
                          na_values  = '?',
                          comment    = '\t',
                          sep        = ' ', 
                          skipinitialspace = True)

dataset = raw_dataset.copy()
dataset = dataset.dropna()

# One-hot encoding of categorical column
dataset['Origin'] = dataset['Origin'].map({1: 'USA', 2: 'Europe', 3: 'Japan'})
dataset           = pd.get_dummies(dataset,
                                   columns    = ['Origin'],
                                   prefix     = '',
                                   prefix_sep = '')

# Split the data into training and testing sets
train_dataset = dataset.sample(frac = 0.8, random_state = 0)
test_dataset  = dataset.drop(train_dataset.index)

sns.pairplot(train_dataset[['MPG', 'Cylinders', 'Weight']], diag_kind = 'kde')
train_dataset.describe().transpose()






