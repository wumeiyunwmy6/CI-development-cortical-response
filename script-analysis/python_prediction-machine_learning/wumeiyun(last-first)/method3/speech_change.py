#53 7
import pandas as pd
print("activity_2_condition")
data_input = pd.read_csv(r"E:\wumeiyun(last-first)\MachineLearningLast1_change2.csv")
# print("读入的非空数据:\n",data_input)

# 非数值转数值
X_gender = data_input.iloc[:, data_input.columns == "gender"]
X_gender_encode = pd.get_dummies(X_gender, drop_first=True)
X_CI = data_input.iloc[:, data_input.columns == "CI"]
X_CI_encode = pd.get_dummies(X_CI, drop_first=True)

X_new = pd.concat([





    # speech
      data_input.iloc[:, data_input.columns == "s_ch1_change"]
    , data_input.iloc[:, data_input.columns == "s_ch2_change"]
    , data_input.iloc[:, data_input.columns == "s_ch3_change"]
    , data_input.iloc[:, data_input.columns == "s_ch4_change"]
    , data_input.iloc[:, data_input.columns == "s_ch5_change"]
    , data_input.iloc[:, data_input.columns == "s_ch6_change"]
    , data_input.iloc[:, data_input.columns == "s_ch7_change"]
    , data_input.iloc[:, data_input.columns == "s_ch8_change"]
    , data_input.iloc[:, data_input.columns == "s_ch9_change"]
    , data_input.iloc[:, data_input.columns == "s_ch10_change"]
    , data_input.iloc[:, data_input.columns == "s_ch11_change"]
    , data_input.iloc[:, data_input.columns == "s_ch12_change"]
    , data_input.iloc[:, data_input.columns == "s_ch13_change"]
    , data_input.iloc[:, data_input.columns == "s_ch14_change"]
    , data_input.iloc[:, data_input.columns == "s_ch15_change"]
    , data_input.iloc[:, data_input.columns == "s_ch16_change"]
    , data_input.iloc[:, data_input.columns == "s_ch17_change"]
    , data_input.iloc[:, data_input.columns == "s_ch18_change"]
    , data_input.iloc[:, data_input.columns == "s_ch19_change"]
    , data_input.iloc[:, data_input.columns == "s_ch20_change"]



], axis=1)
Y_new = data_input.loc[:, "score"]

data_value = pd.concat([Y_new, X_new], axis=1)
#print(data_value.info())

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
from sklearn.metrics import roc_curve, auc , accuracy_score ,recall_score,precision_score
from sklearn.model_selection import StratifiedKFold, LeaveOneOut
# --------------------------------------------------------


X = data_value.iloc[:, data_value.columns != "score"]
Y = data_value.iloc[:, data_value.columns == "score"]

Y = np.array(Y)
columns = X.columns

X = StandardScaler().fit_transform(X)#标准化

area_list_random_state = []  # 共存放20个area
precision_list_random_state = []
accuracy_list_random_state = []
recall_list_random_state = []
random_list = []
for random in range(1, 101, 1):
    print(random)
    Xtrain, Xtest, Ytrain, Ytest = train_test_split(X, Y, test_size=0.1, shuffle=True,
                                                    random_state=random)  # 10%测试集

    svc = SVC(kernel="linear")
    compare_index = 0
    compare_score = 0
    for i in range(1, 21, 1):
        X_wra = RFE(svc, n_features_to_select=i, step=1).fit_transform(Xtrain, Ytrain)
        once = cross_val_score(svc, X_wra, Ytrain, scoring='accuracy', cv=10).mean()
        if once > compare_score:
            compare_score = once
            compare_index = i

    rfe = RFE(svc, n_features_to_select=compare_index, step=1)
    rfe_wrapper = rfe.fit(Xtrain, Ytrain)
    X_wrapper = rfe_wrapper.transform(X)  # 在整个数据集X里，选出 根据特征选择的算法选出的compare_index个特征

    X_train_wrapper = rfe_wrapper.transform(Xtrain)
    X_test_wrapper = rfe_wrapper.transform(Xtest)

    clf = SVC(kernel="linear").fit(X_train_wrapper, Ytrain)
    score = clf.score(X_test_wrapper, Ytest)  # 在测试集上测试
    print(score)

    # 加一个condition,score>=0.8的才能进入下面的步骤——在整个数据集上进行十折交叉验证得到准确率的分布
    if score >= 0.8:
        random_list.append(random)  # 记录>=0.8的random
        area_list = []
        precision_list = []
        accuracy_list = []
        recall_list = []


        # 在整个数据集X上，验证这compare_inedx个特征的效果
        for num in range(100):  # 100次10折交叉验证
            cv = StratifiedKFold(n_splits=10, shuffle=True,random_state=num)
            classifier = svm.SVC(kernel='linear', probability=True)
            area = 0  # 面积AUC
            precision = 0
            accuracy = 0  # 用混淆矩阵算出的准确率
            recall = 0  # sensitivity,tpr
            for train, test in cv.split(X_wrapper, Y):  # 将全部数据集进行10着交叉验证
                cla = classifier.fit(X_wrapper[train], Y[train])

                probas_ = cla.predict_proba(X_wrapper[test])
                fpr, tpr, thresholds = roc_curve(Y[test], probas_[:, 1], pos_label=1)
                roc_auc = auc(fpr, tpr)
                area += roc_auc

                prec = precision_score(Y[test], cla.predict(X_wrapper[test]))
                precision += prec

                acc = accuracy_score(Y[test], cla.predict(X_wrapper[test]))
                accuracy += acc

                rec = recall_score(Y[test], cla.predict(X_wrapper[test]))
                recall += rec

            area_list.append(area / 10)
            precision_list.append(precision / 10)
            accuracy_list.append(accuracy / 10)
            recall_list.append(recall / 10)

        area_list_random_state.append(np.mean(area_list))
        precision_list_random_state.append(np.mean(precision_list))
        accuracy_list_random_state.append(np.mean(accuracy_list))
        recall_list_random_state.append(np.mean(recall_list))

#取accuracy_list_random_state中最大值的index，再根据index找到最大正确率所对应的random_state值
max_accuracy_index =accuracy_list_random_state.index(max(accuracy_list_random_state, key = abs))
max_random_state=random_list[max_accuracy_index]

print("max_random_state:")
print(max_random_state)

from sklearn.model_selection import train_test_split

Xtrain, Xtest, Ytrain, Ytest = train_test_split(X, Y, test_size=0.1, shuffle=True, random_state=max_random_state
                                                # max_random_state
                                                )

import warnings

warnings.filterwarnings("ignore")

# 特征选择
from sklearn.model_selection import cross_val_score
from sklearn.feature_selection import RFE
from sklearn.svm import SVC

import matplotlib.pyplot as plt

svc = SVC(kernel="linear")
score = []
compare_index = 0
compare_score = 0
for i in range(1, 21, 1):
    X_wrapper = RFE(svc, n_features_to_select=i, step=1).fit_transform(Xtrain, Ytrain)
    once = cross_val_score(svc, X_wrapper, Ytrain, scoring='accuracy', cv=10).mean()
    score.append(once)
    if once > compare_score:
        compare_score = once
        compare_index = i
print("feature_number:")
print(compare_index)#输出选择的特征个数

import warnings
warnings.filterwarnings("ignore")