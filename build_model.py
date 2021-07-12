"""
Keras MNIST example from: https://keras.io/examples/vision/mnist_convnet/
Adapted to add mlflow logging
"""

import mlflow
import mlflow.keras
import numpy as np
from tensorflow import keras
from tensorflow.keras import layers
from mlflow.models.signature import infer_signature
import mlflow.tensorflow

mlflow.set_experiment("/Users/price.joshuad@gmail.com/MLOpsDemo")

# Model / data parameters
num_classes = 10
input_shape = (28, 28, 1)

# the data, split between train and test sets
(x_train, y_train), (x_test, y_test) = keras.datasets.mnist.load_data()

# Scale images to the [0, 1] range
x_train = x_train.astype("float32") / 255
x_test = x_test.astype("float32") / 255

# Make sure images have shape (28, 28, 1)
x_train = np.expand_dims(x_train, -1)
x_test = np.expand_dims(x_test, -1)

# Convert class vectors to binary class matrices
y_train = keras.utils.to_categorical(y_train, num_classes)
y_test = keras.utils.to_categorical(y_test, num_classes)

# Build the model
model = keras.Sequential(
    [
        layers.InputLayer(input_shape=input_shape),
        layers.Conv2D(32, kernel_size=(3, 3), activation="relu"),
        layers.MaxPooling2D(pool_size=(2, 2)),
        layers.Conv2D(64, kernel_size=(3, 3), activation="relu"),
        layers.MaxPooling2D(pool_size=(2, 2)),
        layers.Flatten(),
        layers.Dropout(0.4),
        layers.Dense(num_classes, activation="softmax"),
    ]
)
model.compile(loss="categorical_crossentropy", optimizer="adam", metrics=["accuracy"])

# Enable magic mlflow logging
mlflow.tensorflow.autolog()

# Train model
model.fit(x_train, y_train, batch_size=128, epochs=16, validation_split=0.1)

test_loss, test_accuracy = model.evaluate(x_test, y_test)
if test_accuracy < 0.99:
    raise Exception("Model performance did not meet minimum requirement")

signature = infer_signature(x_train, model.predict(x_train))
mlflow.keras.log_model(model, "MNIST", signature=signature)