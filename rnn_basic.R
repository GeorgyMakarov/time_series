library(dplyr)
library(fpp2)
library(keras)

y_train <- elecequip[1:183]
y_test  <- elecequip[184:195]


# Create an empty matrix to fill the sequencies of data
ml  <- 12                         ## memory
m   <- (length(y_train) - ml - 1) ## observations
exm <- matrix(0, nrow = m, ncol = ml + 1)
for (i in 1:m){exm[i,] <- y_train[i:(i + ml)]; rm(i)}


# Separate input from output
x_train <- exm[, -ncol(exm)]
y_train <- exm[, ncol(exm)]


# Shape of input should be (m, ml, n_x)
x_train <- array_reshape(x_train, dim = c(m, ml, 1))
dim(x_train)


# Make keras model
model <- keras_model_sequential()
model %>% 
  layer_dense(input_shape = dim(x_train)[-1], units = ml) %>% 
  layer_simple_rnn(units = 16) %>% 
  layer_dense(units = 1)
summary(model)

model %>% compile(loss = "mse", optimizer = "adam", metric = "mae")
history <- model %>% fit(x_train, y_train, epochs = 50, batch_size = 32, validation_split = 0.1)
save_model_hdf5(model, "rnn_model.h5")

rnn_model <- load_model_hdf5("rnn_model.h5")

data <- elecequip
m2   <- length(data) - ml - 1
exm2 <- matrix(0, nrow = m2, ncol = ml + 1)
for (i in 1:m){exm2[i,] <- data[i:(i + ml)]; rm(i)}

x_train2 <- exm2[, -ncol(exm2)]
y_train2 <- exm2[, ncol(exm2)]

x_train2 <- array_reshape(x_train2, dim = c(m2, ml, 1))
dim(x_train2)

pred <- rnn_model %>% predict(x_train2)
