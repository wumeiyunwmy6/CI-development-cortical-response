import pandas as pd
import random
print("activity_2_condition_permutation")
data_input = pd.read_csv(r"E:\wumeiyun(last-first)\MachineLearningLast1_change2.csv")
# print("读入的非空数据:\n",data_input)

# 非数值转数值
X_gender = data_input.iloc[:, data_input.columns == "gender"]
X_gender_encode = pd.get_dummies(X_gender, drop_first=True)
X_CI = data_input.iloc[:, data_input.columns == "CI"]
X_CI_encode = pd.get_dummies(X_CI, drop_first=True)
#random_state=63
X_new = pd.concat([

    # babble
    #      data_input.iloc[:, data_input.columns == "b_ch1_change"]
    #     ,data_input.iloc[:, data_input.columns == "b_ch2_change"]
    #     ,data_input.iloc[:, data_input.columns == "b_ch3_change"]
    #     ,data_input.iloc[:, data_input.columns == "b_ch4_change"]
           data_input.iloc[:, data_input.columns == "b_ch5_change"]
    #     ,data_input.iloc[:, data_input.columns == "b_ch6_change"]
    #     , data_input.iloc[:, data_input.columns == "b_ch7_change"]
    #     ,data_input.iloc[:, data_input.columns == "b_ch8_change"]
    #     ,data_input.iloc[:, data_input.columns == "b_ch9_change"]
    #     ,data_input.iloc[:, data_input.columns == "b_ch10_change"]
         , data_input.iloc[:, data_input.columns == "b_ch11_change"]
    #     ,data_input.iloc[:, data_input.columns == "b_ch12_change"]
    #     ,data_input.iloc[:, data_input.columns == "b_ch13_change"]
         ,data_input.iloc[:, data_input.columns == "b_ch14_change"]
    #     ,data_input.iloc[:, data_input.columns == "b_ch15_change"]
         ,data_input.iloc[:, data_input.columns == "b_ch16_change"]
    #     ,data_input.iloc[:, data_input.columns == "b_ch17_change"]
         , data_input.iloc[:, data_input.columns == "b_ch18_change"]
    #     , data_input.iloc[:, data_input.columns == "b_ch19_change"]
         , data_input.iloc[:, data_input.columns == "b_ch20_change"]



    # speech
    #      , data_input.iloc[:, data_input.columns == "s_ch1_change"]
    #     , data_input.iloc[:, data_input.columns == "s_ch2_change"]
          , data_input.iloc[:, data_input.columns == "s_ch3_change"]
    #     , data_input.iloc[:, data_input.columns == "s_ch4_change"]
          , data_input.iloc[:, data_input.columns == "s_ch5_change"]
    #     , data_input.iloc[:, data_input.columns == "s_ch6_change"]
         , data_input.iloc[:, data_input.columns == "s_ch7_change"]
    #      , data_input.iloc[:, data_input.columns == "s_ch8_change"]
    #     ,data_input.iloc[:, data_input.columns == "s_ch9_change"]
    #     ,data_input.iloc[:, data_input.columns == "s_ch10_change"]
    #     ,data_input.iloc[:, data_input.columns == "s_ch11_change"]
          , data_input.iloc[:, data_input.columns == "s_ch12_change"]
    #     ,data_input.iloc[:, data_input.columns == "s_ch13_change"]
    #     ,data_input.iloc[:, data_input.columns == "s_ch14_change"]
    #     ,data_input.iloc[:, data_input.columns == "s_ch15_change"]
         ,data_input.iloc[:, data_input.columns == "s_ch16_change"]
    #     ,data_input.iloc[:, data_input.columns == "s_ch17_change"]
    #     ,data_input.iloc[:, data_input.columns == "s_ch18_change"]
    #     ,data_input.iloc[:, data_input.columns == "s_ch19_change"]
    #     ,data_input.iloc[:, data_input.columns == "s_ch20_change"]

], axis=1)
Y_new = data_input.loc[:, "score"]

data_value = pd.concat([Y_new, X_new], axis=1)
# print(data_value.info())

# --------------------------------------------------------

import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
import warnings

warnings.filterwarnings("ignore")
from sklearn.model_selection import cross_val_score
from sklearn.feature_selection import RFE
from sklearn.svm import SVC

from sklearn import svm
from sklearn.metrics import roc_curve, auc, accuracy_score, recall_score, precision_score
from sklearn.model_selection import StratifiedKFold, LeaveOneOut

# --------------------------------------------------------


X = data_value.iloc[:, data_value.columns != "score"]
Y = data_value.iloc[:, data_value.columns == "score"]

Y = np.array(Y)
columns = X.columns

X = StandardScaler().fit_transform(X)  # 标准化

from sklearn.model_selection import train_test_split
import numpy as np
from sklearn.svm import SVC

area_list_per = []
precision_list_per = []
accuracy_list_per = []
recall_list_per = []


for i in range(1, 101, 1):  # 将label打乱100次
    print(i)
    Y = np.random.permutation(Y)  # Y permutation
    Y = np.array(Y)

    area_list = []  # 每个num循环的值都存放在里面，共有100个值
    precision_list = []
    accuracy_list = []
    recall_list = []

    for num in range(10000):

        cv = StratifiedKFold(n_splits=10, shuffle=True,random_state=num)
        classifier = svm.SVC(kernel='linear', probability=True)
        area = 0  # 面积AUC
        precision = 0
        accuracy = 0  # 用混淆矩阵算出的准确率
        recall = 0  # sensitivity,tpr
        for train, test in cv.split(X, Y):
            cla = classifier.fit(X[train], Y[train])
            probas_ = cla.predict_proba(X[test])
            fpr, tpr, thresholds = roc_curve(Y[test], probas_[:, 1], pos_label=1)
            roc_auc = auc(fpr, tpr)
            area += roc_auc

            prec = precision_score(Y[test], cla.predict(X[test]))
            precision += prec

            acc = accuracy_score(Y[test], cla.predict(X[test]))
            accuracy += acc

            rec = recall_score(Y[test], cla.predict(X[test]))
            recall += rec

        area_list.append(area / 10)
        precision_list.append(precision / 10)
        accuracy_list.append(accuracy / 10)
        recall_list.append(recall / 10)

    area_list_per.append(area_list)
    precision_list_per.append(precision_list)
    accuracy_list_per.append(accuracy_list)
    recall_list_per.append(recall_list)
    # print("---------------------------------------------------------")

print("ok")

pd.DataFrame(accuracy_list_per).to_csv("E:\\wumeiyun(last-first)\\method3\\speech+babble_change_permutation.csv")
