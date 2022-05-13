library(reticulate)
use_virtualenv('myenv')
library(keras)
library(tfdatasets)
library(dplyr)

# Load data
bh <- dataset_boston_housing()
c(train_data, train_labels) %<-% bh$train
c(test_data, test_labels)   %<-% bh$test

class(train_data)
dim(train_data)

cn <- c('crim', 'zn', 'indus', 'chas', 'nox', 'rm', 'age', 
        'dis', 'rad', 'tax', 'ptratio', 'b', 'lstat')
cn <- toupper(cn)

train_df <- 
  train_data %>% 
  as_tibble(.name_repair = 'minimal') %>% 
  setNames(cn) %>% 
  mutate(label = train_labels)

test_df <- 
  test_data %>% 
  as_tibble(.name_repair = 'minimal') %>% 
  setNames(cn) %>% 
  mutate(label = test_labels)

# Normalize features
spec <- 
  feature_spec(train_df, label ~ .) %>% 
  step_numeric_column(all_numeric(), normalizer_fn = scaler_standard()) %>% 
  fit()
spec

layer <- layer_dense_features(feature_columns = dense_features(spec),
                              dtype           = tf$float32)
layer(train_df)


input  <- layer_input_from_dataset(train_df %>% select(-label))
output <- 
  input %>% 
  layer_dense_features(dense_features(spec)) %>% 
  layer_dense(units = 64, activation = 'relu') %>% 
  layer_dense(units = 64, activation = 'relu') %>% 
  layer_dense(units = 1)
model <- keras_model(input, output)
summary(model)

model %>% compile(loss      = 'mse',
                  optimizer = optimizer_rmsprop(),
                  metrics   = list('mean_absolute_error'))

build_model