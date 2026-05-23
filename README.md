Project Title
Predicting Heart Disease Risk Using Clinical Features and Logistic Regression

Business Case
A healthcare analytics team wants to identify patients who may be at higher risk of heart disease using routinely collected clinical data such as age, cholesterol, resting blood pressure, chest pain type, maximum heart rate, exercise-induced angina, and thalassemia status.

The goal is not only to build a prediction model, but also to explain which clinical factors are associated with higher or lower heart disease risk.

This project uses logistic regression to estimate the probability of heart disease and evaluates the model using odds ratios, multicollinearity checks, classification performance, ROC/AUC, calibration, Brier score, and an interaction test.

Problem

Heart disease is a high-impact clinical outcome. Early identification of high-risk patients can help clinicians prioritize further testing, lifestyle interventions, medication review, or specialist referral.

The key business/statistical question is:

Can we use patient clinical characteristics to predict the probability of heart disease?

More specifically, this project asks:

Which patient features are associated with heart disease?
How well does the model distinguish patients with and without disease?
Are the predicted probabilities well-calibrated?
Does the relationship between age and heart disease differ by sex?
How should a healthcare team use this model in practice?

Dataset
The dataset is loaded from:

df <- read.csv("Heart.csv")

This is the commonly used Heart.csv dataset from the ISLR-style heart disease example.

Target Variable

The response variable is:
AHD
This represents whether a patient has heart disease.

Key Findings
Finding 1: Logistic regression gives interpretable risk drivers
The model estimates how each clinical feature is associated with heart disease risk.
Unlike black-box models, logistic regression provides odds ratios.
Business translation: This makes it useful in healthcare because stakeholders can understand the direction and size of each risk factor.

Finding 2: Some predictors likely carry stronger clinical signal than others
Commonly important predictors in this type of model include:
Predictor	Likely Interpretation
ChestPain	Certain chest pain types are more strongly associated with disease
MaxHR	Higher max heart rate may be associated with lower risk
ExAng	Exercise-induced angina may indicate higher risk
Oldpeak	Greater ST depression may indicate higher risk
Ca	More colored vessels may indicate higher risk
Thal	Abnormal thalassemia categories may indicate higher risk
Business translation: The model is not just predicting risk; it is identifying clinical factors that explain why a patient may be higher risk.

Finding 3: Calibration is critical for clinical usefulness
The calibration plot and Brier score help evaluate whether predicted probabilities are trustworthy.
A model that ranks patients well but gives poor probabilities may still be risky to use.
Business translation: In healthcare, it is not enough to know who is higher risk. We need to know whether the risk estimate itself is believable.

Finding 4: Age-by-sex interaction tests whether risk progression differs by group
The interaction model tests whether age affects heart disease risk differently by sex.
If the interaction improves AIC or is significant in the likelihood-ratio test, then the model should include it.
If not, the simpler model is easier to explain and may be preferred.
Business translation: Add complexity only when it improves decision-making.

Surprising Insights
Insight 1: The predicted probability is more valuable than the predicted class
A yes/no prediction is easy to understand, but it hides important risk information.
For example, two patients may both be classified as “No heart disease,” but one may have a predicted risk of 49% and the other may have a predicted risk of 5%.
Those are very different clinical situations.
Surprising takeaway: The probability score is often more useful than the final classification label.

Insight 2: A 0.5 threshold may not be appropriate in healthcare
Even after fixing the direction, a 0.5 cutoff may not be the best threshold.
In healthcare, missing a true heart disease case can be more costly than flagging someone for extra screening.
Surprising takeaway: The best threshold may be lower than 0.5 if the goal is to catch more high-risk patients.

Insight 3: A model can have a strong AUC and still be poorly calibrated
AUC measures ranking ability.
Calibration measures probability accuracy.
A model could correctly rank Patient A as riskier than Patient B but still overstate both risks.
Surprising takeaway: A model can be good at sorting patients but bad at estimating their true probability of disease.

Insight 4: Some “traditional” metrics may be less useful than decision-focused metrics
Accuracy may look good, but in healthcare, sensitivity, specificity, positive predictive value, and calibration may matter more.
Surprising takeaway: A model should be judged by whether it supports better decisions, not just whether it gets many rows correct.

Metric Story
Metric: Predicted Probability of Heart Disease
What metric changed?
The main metric is: pred_prob
This represents each patient’s estimated probability of heart disease.

Why did it change?
The predicted probability changes based on the patient’s clinical profile.
For example, a patient’s predicted risk may increase if they have:

More concerning chest pain type
Exercise-induced angina
Higher oldpeak value
More major vessels colored by fluoroscopy
Abnormal thalassemia result
Lower maximum heart rate

The model combines these factors into one risk estimate.

What caused it?
The change in predicted risk is caused by the weighted contribution of the model predictors.
In logistic regression, each variable contributes to the log-odds of heart disease.

What should we do?
The healthcare team should use predicted probability as a risk stratification tool, not just a binary yes/no answer.

Business Impact
Operational Impact
This model can help prioritize patients for additional review.
Instead of reviewing all patients equally, clinicians can focus attention on patients with higher predicted risk.
Potential benefits:
Earlier identification of high-risk patients.
More efficient use of clinical resources.
Better prioritization for diagnostic testing.
More transparent risk communication.
Support for preventive care decisions.

Clinical Decision Impact
The model can support but not replace clinician judgment.
It can be used as a decision-support tool:
The model flags risk. The clinician decides what to do.
This is important because logistic regression is based on observed patterns in the dataset. It does not prove causation.
For example, if Oldpeak is associated with higher heart disease risk, that does not mean changing Oldpeak directly causes risk to fall. It means Oldpeak is a useful risk marker.

Recommendations

Recommendation 1: Recode the outcome variable clearly
Use:
df$AHD_num <- ifelse(df$AHD == "Yes", 1, 0)
Then fit:
model <- glm(
  AHD_num ~ Age + Sex + ChestPain + RestBP + Chol + Fbs + RestECG +
    MaxHR + ExAng + Oldpeak + Slope + Ca + Thal,
  data = df,
  family = binomial
)
This avoids confusion about whether the model is predicting disease or no disease.

Recommendation 2: Use predicted probabilities for ROC/AUC
Use:
heart_disease_roc <- roc(df$AHD_num, df$pred_prob)
auc_score <- auc(heart_disease_roc)
Do not use predicted classes for ROC/AUC.
Predicted probabilities preserve more information.

Recommendation 3: Tune the classification threshold
Instead of automatically using 0.5, test several thresholds.
For example:
thresholds <- seq(0.1, 0.9, by = 0.05)
results <- data.frame(
  threshold = thresholds,
  sensitivity = NA,
  specificity = NA
)
In healthcare, a lower threshold may be better if the goal is to catch more true heart disease cases.

Recommendation 4: Report sensitivity, specificity, precision, and recall

Add these metrics:
table(Predicted = df$pred_class, Actual = df$AHD_num)
Then calculate:
Metric	Why It Matters
Sensitivity	How many true disease cases were caught
Specificity	How many non-disease cases were correctly ruled out
Precision	How many flagged patients truly had disease
Recall	Same as sensitivity
F1 score	Balance between precision and recall
For a healthcare screening model, sensitivity is especially important.

Recommendation 5: Keep calibration in the final analysis
The calibration plot and Brier score are very valuable.
Many beginner projects stop at accuracy or AUC.
My project goes further by asking:
Are the predicted probabilities actually trustworthy?
That is a stronger, more business-relevant analysis.

Recommendation 6: Interpret interaction terms carefully
The age-by-sex interaction is useful if the business question is about subgroup differences.
Use:
anova(model, model_int1, test = "Chisq")
AIC(model, model_int1)
If the interaction model does not improve fit, keep the simpler model.
A simpler model is often better for communication and deployment.

Executive Summary
This project built a logistic regression model to predict heart disease risk using clinical variables. The model estimates patient-level predicted probabilities and explains risk drivers using odds ratios and confidence intervals.
The strongest value of this project is not just classification. It is risk stratification. Predicted probabilities allow the healthcare team to separate low-risk, moderate-risk, and high-risk patients.
The project also evaluates model quality using ROC/AUC, calibration, Brier score, and interaction testing. This makes the analysis stronger than a basic logistic regression project.
The most important improvement is to cleanly recode the outcome variable so the model clearly predicts the probability of heart disease. The second major improvement is to use predicted probabilities, not predicted classes, when calculating ROC/AUC.

Final Recommendation
Use logistic regression as an interpretable clinical risk model, but report the output as a probability-based risk score rather than only a yes/no classification.
The recommended final model structure is:
model <- glm(
  AHD_num ~ Age + Sex + ChestPain + RestBP + Chol + Fbs + RestECG +
    MaxHR + ExAng + Oldpeak + Slope + Ca + Thal,
  data = df,
  family = binomial
)
Then evaluate it with:

df$pred_prob <- predict(model, type = "response")
roc(df$AHD_num, df$pred_prob)
brier_score <- mean((df$pred_prob - df$AHD_num)^2)

The final business message is:
The model can help identify higher-risk patients, explain which clinical factors are driving risk, and support better prioritization for follow-up care. However, it should be used as a decision-support tool, not as a replacement for clinical judgment.






































