#!/usr/bin/env python2
# -*- coding: utf-8 
"""
Created on Tue Dec 10 19:09:17 2019

@author: radeonthe1st
"""
import matplotlib.pyplot as plt
import time
import xmltodict
import glob
import numpy as np
import Stemmer
from sklearn.feature_extraction.text import TfidfVectorizer, CountVectorizer, TfidfTransformer
from sklearn.model_selection import train_test_split
import sklearn.naive_bayes
import sklearn.neighbors
import sklearn.cluster
from sklearn.svm import LinearSVC
import sklearn.metrics
import copy
import re
import sklearn.externals
import sklearn.decomposition.truncated_svd



time_i=time.time()

token_extract = re.compile(r'\b\w\w+\b')

TFIDF = TfidfVectorizer(strip_accents='unicode', lowercase = True)
files = glob.glob("./tarea/efe*.xml")
categlist=list()
docnos = list()
docnos2 = list()
doccats = []
categs=['CEE','CIENCIA','CULTURA','DEPORTES','ECONOMIA','PARTIDOS','POLITICA','SUCESOS','TRIBUNALES']
categ_array=np.asarray(categs)

clf_BernNB1 = sklearn.naive_bayes.BernoulliNB(alpha=1.0)
clf_BernNB01 = sklearn.naive_bayes.BernoulliNB(alpha=0.1)
clf_BernNB001 = sklearn.naive_bayes.BernoulliNB(alpha=0.01)
clf_BernNB0001 = sklearn.naive_bayes.BernoulliNB(alpha=0.001)
clf_MultNB = sklearn.naive_bayes.MultinomialNB()
clf_Rocchio = sklearn.neighbors.NearestCentroid()
clf_kNN = sklearn.neighbors.KNeighborsClassifier(n_neighbors=3)
clf_SVM = LinearSVC()

clu_k6 = sklearn.cluster.KMeans(n_clusters=6,random_state=420)
clu_agg6 = sklearn.cluster.AgglomerativeClustering(n_clusters=6)

clu_k7 = sklearn.cluster.KMeans(n_clusters=7,random_state=420)
clu_agg7 = sklearn.cluster.AgglomerativeClustering(n_clusters=7)

clu_k8 = sklearn.cluster.KMeans(n_clusters=8,random_state=420)
clu_agg8 = sklearn.cluster.AgglomerativeClustering(n_clusters=8)

clu_k9 = sklearn.cluster.KMeans(n_clusters=9,random_state=420)
clu_agg9 = sklearn.cluster.AgglomerativeClustering(n_clusters=9)

clu_k10 = sklearn.cluster.KMeans(n_clusters=10,random_state=420)
clu_agg10 = sklearn.cluster.AgglomerativeClustering(n_clusters=10)

pvacias=open('./stop/vacias.txt')
vacias=pvacias.read().replace('\n', ' ')
vacias=unicode(vacias,'utf-8')
vacias=vacias.split()

#with open('/Users/radeonthe1st/Dropbox (Botana USC)/Máster Sistemas Inteligentes/Recuperación Avanzada/Trabajo/vacias.txt') as f:
#  vacias = f.read().splitlines()


def tokenizer_snowballer(text):
  stemmer = Stemmer.Stemmer('spanish')
  return [stemmer.stemWord(t) for t in token_extract.findall(text.lower()) if t not in vacias]


TFIDF2= TfidfVectorizer(tokenizer = tokenizer_snowballer)
freq_vectorizer= CountVectorizer(tokenizer = tokenizer_snowballer)

def text_stream_ori(files):
  """Devuelve texto de los documentos XML, campos TITLE + TEXT"""
  global docnos, doccats
  for f in sorted(files):
    print(f)
    with open(f) as ff:
      efe  = xmltodict.parse(ff.read())
      docs = efe['EFE']['DOC']         ## list de nodos-hijo "DOC"
      for doc in docs:
        if doc['CATEGORY'] in categs:
            docnos.append(doc['DOCNO'])
            doccats.append(doc['CATEGORY']) 
            title = "" if doc['TITLE'] is None else doc['TITLE']
            text  = "" if doc['TEXT']  is None else doc['TEXT']
            yield title + " " + text
            
def text_stream_mute(files):
  """Devuelve texto de los documentos XML, campos TITLE + TEXT"""
  global docnos, doccats
  for f in sorted(files):
#    print(f)
    with open(f) as ff:
      efe  = xmltodict.parse(ff.read())
      docs = efe['EFE']['DOC']         ## list de nodos-hijo "DOC"
      for doc in docs:
        if doc['CATEGORY'] in categs:
#            docnos.append(doc['DOCNO'])
#            doccats.append(doc['CATEGORY']) 
            title = "" if doc['TITLE'] is None else doc['TITLE']
            text  = "" if doc['TEXT']  is None else doc['TEXT']
            yield title + " " + text

print '----Inicializando algoritmo TF-IDF----'
X = TFIDF2.fit_transform(text_stream_ori(files))
print '----Ajustando para Multinomial...----'
init_freqx = freq_vectorizer.fit_transform(text_stream_mute(files))
transf = TfidfTransformer().fit(init_freqx)
X_freq = transf.transform(init_freqx)
Y = copy.copy(doccats)

X_train, X_test, Y_train, Y_test = train_test_split(X,Y,stratify=Y)

XF_train,XF_test,YF_train,YF_test = train_test_split(X_freq,Y,stratify=Y)

##====================================================================
##====================================================================
##====================================================================
#clf_kNN2 = sklearn.neighbors.KNeighborsClassifier(n_neighbors=2)
#clf_kNN2.fit(X_train,Y_train)
#y_pred_knn2 = clf_kNN2.predict(X_test)
#acc_knn2 = sklearn.metrics.accuracy_score(Y_test,y_pred_knn2)
#
#clf_kNN5 = sklearn.neighbors.KNeighborsClassifier(n_neighbors=5)
#clf_kNN5.fit(X_train,Y_train)
#y_pred_knn5 = clf_kNN5.predict(X_test)
#acc_knn5 = sklearn.metrics.accuracy_score(Y_test,y_pred_knn5)
#----OPTIMO----
#clf_kNN10 = sklearn.neighbors.KNeighborsClassifier(n_neighbors=10)
#clf_kNN10.fit(X_train,Y_train)
#y_pred_knn10 = clf_kNN10.predict(X_test)
#acc_knn10 = sklearn.metrics.accuracy_score(Y_test,y_pred_knn10)
#----OPTIMO----
#clf_kNN15 = sklearn.neighbors.KNeighborsClassifier(n_neighbors=15)
#clf_kNN15.fit(X_train,Y_train)
#y_pred_knn15 = clf_kNN15.predict(X_test)
#acc_knn15 = sklearn.metrics.accuracy_score(Y_test,y_pred_knn15)
#
#clf_kNN20 = sklearn.neighbors.KNeighborsClassifier(n_neighbors=20)
#clf_kNN20.fit(X_train,Y_train)
#y_pred_knn20 = clf_kNN20.predict(X_test)
#acc_knn20 = sklearn.metrics.accuracy_score(Y_test,y_pred_knn20)
#
#print 'Precision para kNN (neighbours=2): ', acc_knn2
#print 'Precision para kNN (neighbours=5): ', acc_knn5
#print 'Precision para kNN (neighbours=10): ', acc_knn10
#print 'Precision para kNN (neighbours=15): ', acc_knn15
#print 'Precision para kNN (neighbours=20): ', acc_knn20
##====================================================================
##====================================================================
##====================================================================

clf_kNN=clf_kNN10 = sklearn.neighbors.KNeighborsClassifier(n_neighbors=10)

print 'Entrenando modelos...'
print 'Entrenando BernoulliNB...'
clf_BernNB1.fit(X_train,Y_train)
clf_BernNB01.fit(X_train,Y_train)
clf_BernNB001.fit(X_train,Y_train)
clf_BernNB0001.fit(X_train,Y_train)
print 'Entrenando MultiNB...'
clf_MultNB.fit(XF_train,YF_train)
print 'Entrenando kNN...'
clf_kNN.fit(X_train,Y_train)
print 'Entrenando Rocchio...'
clf_Rocchio.fit(X_train,Y_train)
print 'Entrenando SVM...'
clf_SVM.fit(X_train,Y_train)

print 'Entreno finalizado.'

y_pred_bern1 = clf_BernNB1.predict(X_test)
y_pred_bern01 = clf_BernNB01.predict(X_test)
y_pred_bern001 = clf_BernNB001.predict(X_test)
y_pred_bern0001 = clf_BernNB0001.predict(X_test)
y_pred_multi = clf_MultNB.predict(XF_test)
y_pred_knn = clf_kNN.predict(X_test)
y_pred_rocchio = clf_Rocchio.predict(X_test)
y_pred_SVM = clf_SVM.predict(X_test)

acc_bern1 = sklearn.metrics.accuracy_score(Y_test,y_pred_bern1)
acc_bern01 = sklearn.metrics.accuracy_score(Y_test,y_pred_bern01)
acc_bern001 = sklearn.metrics.accuracy_score(Y_test,y_pred_bern001)
acc_bern0001 = sklearn.metrics.accuracy_score(Y_test,y_pred_bern0001)
acc_multi = sklearn.metrics.accuracy_score(YF_test,y_pred_multi)
acc_knn = sklearn.metrics.accuracy_score(Y_test,y_pred_knn)
acc_rocchio = sklearn.metrics.accuracy_score(Y_test,y_pred_rocchio)
acc_svm = sklearn.metrics.accuracy_score(Y_test,y_pred_SVM)

print 'Precision para BernoulliNB (alpha=1): ', acc_bern1
print 'Precision para BernoulliNB (alpha=0.1): ', acc_bern01
print 'Precision para BernoulliNB (alpha=0.01): ', acc_bern001
print 'Precision para BernoulliNB (alpha=0.001): ', acc_bern0001
print 'Precision para MultinomialNB: ', acc_multi
print 'Precision para kNN: ', acc_knn
print 'Precision para Rocchio: ', acc_rocchio
print 'Precision para SVM: ', acc_svm

SVDecomp=sklearn.decomposition.TruncatedSVD(n_components=2,random_state=420)
X_cluster = SVDecomp.fit_transform(X)


print '-----Entrenando Clusters KMeans...-------'
clu_k_scores=[]
best_k_score=0
y_kmeans_plot=0

#=====Utilizar sólo si se quiere aplicar un único modelo en lugar de comparar
#clu_k.fit(X_cluster)
#sklearn.externals.joblib.dump(clu_k,'clu_k.pkl')
#print 'KMeans: Encontrado modelo de entreno previo, cargando...'
#clu_k = sklearn.externals.joblib.load('clu_k.pkl')
#y_kmeans = clu_k.predict(X_cluster)

for i in range(4,11):
    clu_k_iter = sklearn.cluster.KMeans(n_clusters=i,random_state=420)
    clu_k_iter.fit(X_cluster)
    y_kmeans_iter = clu_k_iter.predict(X_cluster)
    clu_k_silh_iter = sklearn.metrics.silhouette_score(X_cluster,y_kmeans_iter)
    clu_k_scores.append(clu_k_silh_iter)
    print 'KMeans en %d clusters: %f' % (i,clu_k_silh_iter)
    if i==9:
        plot_model = clu_k_iter
        y_kmeans_plot=y_kmeans_iter
    if clu_k_silh_iter > best_k_score:
        best_k_model = clu_k_iter
        y_kmeans = y_kmeans_iter
        best_k_score = clu_k_silh_iter
        

fig_k=plt.figure(1)
plt.scatter(X_cluster[:, 0], X_cluster[:, 1], c=y_kmeans_plot, s=25, cmap='viridis')
km_centers = plot_model.cluster_centers_
plt.scatter(km_centers[:, 0], km_centers[:, 1], c='black', s=200, alpha=0.5)
plt.title('KMeans para 9 clusters')
fig_k.savefig('fig_clu_k.png')
fig_k.show()

best_k_fig=plt.figure(2)
plt.scatter(X_cluster[:,0],X_cluster[:,1],c=y_kmeans,s=25,cmap='viridis')
km_centers = best_k_model.cluster_centers_
plt.scatter(km_centers[:, 0], km_centers[:, 1], c='black', s=200, alpha=0.5)
plt.title('Mejor Clustering KMeans')
best_k_fig.savefig('best_k_fig.png')
best_k_fig.show()


print '-----Entrenando Cluster Jerarquico Agregacional------'

clu_agg_scores=[]
best_agg_score=0
y_agg_plot=0
for i in range(4,11):
    clu_agg_iter = sklearn.cluster.AgglomerativeClustering(n_clusters=i)
    y_agg_iter = clu_agg_iter.fit_predict(X_cluster)
    clu_agg_silh_iter = sklearn.metrics.silhouette_score(X_cluster,y_agg_iter)
    clu_agg_scores.append(clu_agg_silh_iter)
    print 'Agregacional en %d vecinos: %f' % (i,clu_agg_silh_iter)
    if i==9:
        y_agg_plot=y_agg_iter
    if clu_agg_silh_iter > best_agg_score:
        best_agg_model = clu_k_iter
        y_agg = y_agg_iter
        best_agg_score = clu_agg_silh_iter

fig_agg = plt.figure(3)
plt.scatter(X_cluster[:, 0], X_cluster[:, 1], c=y_agg_plot, s=25, cmap='viridis')
plt.title('Jerarquico Agregacional para 9 clusters')
fig_agg.savefig('fig_clu_agg.png')
fig_agg.show()

best_fig_agg = plt.figure(4)
plt.scatter(X_cluster[:, 0], X_cluster[:, 1], c=y_agg, s=25, cmap='viridis')
plt.title('Mejor Clustering Jerarquico Agregacional')
best_fig_agg.savefig('best_clu_agg.png')
best_fig_agg.show()

time_f=time.time()

print 'Time Elapsed: ', time_f-time_i
