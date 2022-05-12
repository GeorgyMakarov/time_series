## How to install keras and tensorflow in Rstudio

This explains how to install `keras` and `tensorflow` libraries in **Rstudio**.
It shows you how to avoid `miniconda` pitfall if you want to use your custom
virtual environment. The guide applies to `Ubuntu 20.04` machines.

You may have `miniconda` installed. Library `keras` default installation goes to
`miniconda` environment. This can be unwanted. You can remove `miniconda`
environments by running the below command in the terminal:

```
ls -l -a | grep miniconda
rm -r remove ~/<miniconda>/
```

Here you replace `<miniconda>` with the name of the folder containing your
`miniconda` installation.

You need `reticulate` library to be able to use `keras` and `tensorflow` in
**Rstudio**. This library allows you to create and manage *virtual environment*
where `tensorflow` lives.

```
library(reticulate)
use_virtualenv(<myenv>)
install.packages('keras')
library(keras)
install_keras()
```

