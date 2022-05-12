library(reticulate)
use_virtualenv('myenv')
library(keras)

# Prepare data
mnist         <- dataset_mnist()
mnist$train$x <- mnist$train$x / 255
mnist$test$x  <- mnist$test$x / 255

# Build a model
model <- 
  keras_model_sequential() %>% 
  layer_flatten(input_shape = c(28, 28)) %>% 
  layer_dense(units = 128, activation = 'relu') %>% 
  layer_dropout(0.2) %>% 
  layer_dense(10, activation = 'softmax')

summary(model)

# Compile the model
model %>% compile(loss      = 'sparse_categorical_crossentropy',
                  optimizer = 'adam',
                  metrics   = 'accuracy')

# Train the model
model %>% fit(x = mnist$train$x,
              y = mnist$train$y,
              epochs  = 5,
              verbose = 2,
              validation_split = 0.3)

# Predict
preds <- predict(model, mnist$test$x)
head(preds, 2)

model %>% evaluate(mnist$test$x, mnist$test$y, verbose = 0)

# Save model for future use
save_model_tf(object = model, filepath = "mnist_model")

re_load <- load_model_tf("mnist_model")
all.equal(preds, predict(re_load, mnist$test$x))
