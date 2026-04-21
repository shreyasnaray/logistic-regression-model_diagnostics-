library(performance)
library(car)
library(ISLR)
library(pROC)
library(ROCR)
library(dplyr)
library(ggplot2)
df <- read.csv('Heart.csv')
# predict presence of heart disease
df$ChestPain <- factor(df$ChestPain, levels = c(
  'typical', 'nontypical', 'nonanginal', 'asymptomatic'
), labels = c('Typical', 'Atypical', 'Non-Anginal', 'Asymptomatic'))

df$Thal <- factor(df$Thal, levels = c('fixed', 'normal', 'reversable'))
df$AHD <- factor(df$AHD, levels = c('Yes', 'No'), labels = c(1, 0))

df <- na.omit(df)

model <- glm(AHD ~ Age + Sex + ChestPain + 
      RestBP + Chol + Fbs + RestECG + MaxHR +
      ExAng + Oldpeak + Slope + Ca + Thal, data = df, family = binomial)

# these are log-odds not odds raatios
summary(model)
# odds-ratios
exp(coef(model))
# confidence intervals
exp(confint(model))

final_results <- exp(cbind(OR = coef(model),
                           confint(model)))
final_results

check_collinearity(model)
vif(model)

# Select only numeric predictor variables
cor_matrix <- cor(df[, c('Age', 'Sex', 'RestBP',
                         'Chol', 'Fbs', 'RestECG',
                         'MaxHR', 'ExAng', 'Oldpeak',
                         'Slope', 'Ca')])
cor_matrix

df$pred_prob <- predict(model, type = 'response')
df$pred_class <- ifelse(df$pred_prob > 0.5,
                        'No', 
                        'Yes')
df
table(Predicted = df$pred_class, Actual = df$AHD)

new_data <- data.frame(
  Age = 60,
  Sex = 1,
  ChestPain = 'Typical',
  RestBP = 150,
  Chol = 250,
  Fbs = 1,
  RestECG = 2,
  MaxHR = 150,
  ExAng = 1,
  Oldpeak = 2.1,
  Slope = 2, 
  Ca = 0,
  Thal = 'reversable'
)
predicted_vals <- predict(model, newdata = new_data, type = 'response')
length(df$AHD)
df$pred_class <- as.integer(df$pred_class == 'Yes')
df$pred_class
heart_disease_roc <- roc(df$AHD, df$pred_class)
plot(heart_disease_roc, main = 'ROC Curve', col = 'blue', lwd = 2)
# AUC 
auc_score <- auc(heart_disease_roc)
print(auc_score) # Output: Area under the curve


pred <- prediction(df$pred_class, df$AHD)
perf <- performance(pred, 'tpr', 'fpr')
plot(perf, main = 'ROCR ROC Curve', colorize = TRUE)

auc <- performance(pred, measure = 'auc')
auc <- auc@y.values[1]
print(auc)

df$bin <- cut(df$pred_prob, breaks = seq(0, 1, by = 0.1), include.lowest = TRUE)
df$AHD <- factor(df$AHD)
df <- df %>% mutate(AHD = as.numeric(AHD) - 1)
df
calibration_df <- df %>%
  group_by(bin) %>%
  summarise(
    mean_pred = mean(pred_prob),
    observed = mean(AHD)
  )
calibration_df
ggplot(calibration_df, aes(x = mean_pred, y =
                             observed)) + 
  geom_point() +
  geom_line() +
  geom_abline(slope = 1, intercept = 0, linetype = 'dashed') +
  labs(
    title = 'Calibration Plot',
    x = 'Predicted Probability',
    y = 'Observed Proportion'
  ) +
  theme_minimal()
  
brier_score <- mean((df$pred_prob - df$AHD)^2)
brier_score

# find the calibration intercept and slope
cal_model <- glm(AHD ~ pred_prob, family = binomial, data = df)
summary(cal_model)

# Adding interaction terms to compare models
# used sex and age because risk factors progress differently for men and women as they age
model_int1 <- glm(AHD ~ Age * Sex + ChestPain + 
               RestBP + Chol + Fbs + RestECG + MaxHR +
               ExAng + Oldpeak + Slope + Ca + Thal, data = df, family = binomial)
model_int1

anova(model, model_int1, test = 'Chisq')
AIC(model, model_int1)

ggplot(df, aes(x = Age, y = AHD, color = Sex)) +
  geom_smooth(method = 'glm', method.args = list(family = 'binomial'),
              se = FALSE) +
  labs(title = 'Interaction Check: MaxHR and Sex',
       y = 'Probability of Heart Disease',
       x = 'Max Heart Rate') +
  theme_minimal()







































