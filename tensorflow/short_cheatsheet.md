## Tensorflow cheatsheet

### Summary

This cheatsheet shows steps and settings required to train neural net using
`TF` package. The steps include data preparation and model build and train.
The settings include hyper parameter tuning steps.

### Steps and settings

This workflow allows to prepare data, build a model and train it. There are
steps in the workflow. This workflow applies to regression and time series
forecasting problems.

1. clean the data from *NA* values;  
2. clean the data from non-sense values;  
3. convert text / factor data to one-hot encoding;  
4. identify outliers and eliminate them;  
    * remove outliers;  
    * replace outliers;  
5. feature engineering;  
    * features must have sense to a model;  
    * replace timestamps with seasonality;  
    * use *Fourier* to identify complex seasonalities;  
6. split the data into training, test and validation sets;  
7. normalize the data;  
    * use simple mean or moving average;  
    * use normalization layer for regression;  
8. split features from labels;  
9. explore the data -- return to item 5 if something is not right;  
10. create model specific objects -- see below;  

### Conclusion
