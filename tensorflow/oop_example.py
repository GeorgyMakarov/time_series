import pandas as pd
import numpy  as np
import tensorflow as tf

# Define new class
class window_generator():
  def __init__(self, inp_wd, lbl_wd, shift, tr_df, vl_df, te_df, lbl_col = None):
    
    # Store the raw data
    self.tr_df = tr_df
    self.vl_df = vl_df
    self.te_df = te_df
    
    # Work out the label column indices
    self.lbl_col = lbl_col
    if lbl_col is not None:
      self.lbl_col_idx = {name: i for i, name in enumerate(lbl_col)}
    self.col_idx = {name: i for i, name in enumerate(tr_df.columns)}
    
    # Create window parameters
    self.inp_wd   = inp_wd
    self.lbl_wd   = lbl_wd
    self.shift    = shift
    self.total_wd = inp_wd + shift
    self.inp_slc  = slice(0, inp_wd)
    self.inp_idx  = np.arange(self.total_wd)[self.inp_slc]
    
    self.lbl_start = self.total_wd - self.lbl_wd
    self.lbl_slc   = slice(self.lbl_start, None)
    self.lbl_idx   = np.arange(self.total_wd)[self.lbl_slc]
    
  def __repr__(self):
    return '\n'.join([f'Total window size: {self.total_wd}',
                      f'Input indices: {self.inp_idx}',
                      f'Label indices: {self.lbl_idx}',
                      f'Label column names: {self.lbl_col}'])


# Split -- given a list of consecutive inputs, we convert them to a window of
# inputs and a window of labels
def split_window(self, features):
  
  inp = features[:, self.inp_slc, :]
  lbl = features[:, self.lbl_slc, :]
  
  if self.lbl_col is not None:
    lbl = tf.stack([lbl[:, :, self.col_idx[name]] for name in self.lbl_col], axis=-1)
    
  inp.set_shape([None, self.inp_wd, None])
  lbl.set_shape([None, self.lbl_wd, None])
  
  return inp, lbl

window_generator.split_window = split_window


# Create custom function to convert time series data frame to tensorflow
# dataset.
def make_dataset(self, data):
  data = np.array(data, dtype = np.float32)
  ds   = tf.keras.utils.timeseries_dataset_from_array(
    data            = data,
    targets         = None,
    sequence_length = self.total_wd,
    sequence_stride = 1,
    shuffle         = T,
    batch_size      = 32,
  )
  
  ds = ds.map(self.split_window)
  
  return ds

window_generator.make_dataset = make_dataset


# Add properties to be able to access the parameters of the datasets generated
# by make_dataset

# Create data frames
mu, sg = 0, 0.1
df1 = pd.DataFrame(dict(col1     = np.random.normal(mu, sg, 80),
                        col2     = np.random.normal(mu, sg, 80),
                        test_col = np.random.normal(mu, sg, 80)),
                   columns = ['col1', 'col2', 'test_col'])
df2 = pd.DataFrame(dict(col1     = np.random.normal(mu, sg, 10),
                        col2     = np.random.normal(mu, sg, 10),
                        test_col = np.random.normal(mu, sg, 10)),
                   columns = ['col1', 'col2', 'test_col'])
df3 = pd.DataFrame(dict(col1     = np.random.normal(mu, sg, 10),
                        col2     = np.random.normal(mu, sg, 10),
                        test_col = np.random.normal(mu, sg, 10)),
                   columns = ['col1', 'col2', 'test_col'])


# Test new class
w_test = window_generator(
  inp_wd  = 10,
  lbl_wd  = 1,
  shift   = 1,
  tr_df   = df1,
  vl_df   = df2,
  te_df   = df3,
  lbl_col = ['test_col']
)


# Test split window
example_window = tf.stack([np.array(df1[:w_test.total_wd]),
                           np.array(df1[40:40 + w_test.total_wd]),
                           np.array(df1[60:60 + w_test.total_wd])])

ex_inp, ex_lbl = w_test.split_window(example_window)

print(f'Window shape: {example_window.shape}')
print(f'Inputs shape: {ex_inp.shape}')
print(f'Labels shape: {ex_lbl.shape}')






