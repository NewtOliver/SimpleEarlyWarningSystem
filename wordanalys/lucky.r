#################################################################
setwd("D:/09Limited_buffer/earlywarningbyci/gui")
csv <- read.csv("filter.csv",header=T, stringsAsFactors=F)
mystopwords<- unlist (read.table("D:/09Limited_buffer/earlywarningbyci/classification/chinese_stopword.txt",stringsAsFactors=F))
library(tm)
################################���ķִʣ�Ҳ���Կ���ʹ��rmmseg4j��rsmartcn
library("stringr")
sample.word<-iconv(csv$content,"utf-8","gbk")
tag<-str_extract(sample.word,"#.+?#")  
tag<-na.omit(tag)  #ȥ��NA
tag<-unique(tag)    #ȥ��
tag<-gsub("^#|#$","",tag)
removeNumbers = function(x) { ret = gsub("[0-9��������������������]","",x) }
wordsegment<- function(x) {
segmentCN(x)
}
removeStopWords = function(x,words) {
ret = character(0)
index <- 1
it_max <- length(x)
while (index <= it_max) {
if (length(words[words==x[index]]) <1) ret <- c(ret,x[index])
index <- index +1
}
ret
}
sample.words <- lapply(sample.word, removeNumbers)
sample.words<-gsub(pattern="http:[a-zA-Z\\/\\.0-9]+","",sample.words)

library("rJava")
library("Rwordseg")
#��ӱ�ǩ��
textwords=tag
insertWords(textwords)
sample.words <- lapply(sample.words, wordsegment)
corpus = Corpus(VectorSource(sample.words))
############################################### ��������-�ĵ�����(TDM)
control=list(removePunctuation=T,minDocFreq=5,wordLengths = c(2, Inf),weighting = weightTfIdf)
doc.tdm=TermDocumentMatrix(corpus,control)
length(doc.tdm$dimnames$Terms)
tdm_removed=removeSparseTerms(doc.tdm, 0.9998) # 1-ȥ���˵��� 99.98% ��ϡ����Ŀ��
length(tdm_removed$dimnames$Terms)
############################################### ��ξ���
dist_tdm_removed <- dissimilarity(tdm_removed, method = 'cosine')
hc <- hclust(dist_tdm_removed, method = 'mcquitty')
cutNum = 7 #���÷ָ�������Ŀ
ct = cutree(hc,k=cutNum) #�������зָ�
sink(file="result.txt")
for(i in 1:cutNum){
  print(paste("��",i,"�ࣺ ",sum(ct==i),"��"));
  print("----------------");
  print(attr(ct[ct==i],"names"));
#   print(doc[as.integer(names(ct[ct==i]))])
  print("----------------")
}
sink()
################################################################����
csv$clustertag<-as.character(ct)#csv$clustertag<-as.integer(ct)
################################################################����
library(Rcpp)
library(RColorBrewer)
library(wordcloud)
sample.tdm <- TermDocumentMatrix(corpus, control = list(wordLengths = c(2, Inf)))#�ʳ�������Ϊ2
tdm_matrix <- as.matrix(sample.tdm)
meta(corpus,"cluster") <- csv$clustertag
unique_type <- unique(csv$clustertag)
n <- nrow(csv)
zz1 <- 1:n
cluster_matrix<-sapply(unique_type,function(type){apply(as.matrix(tdm_matrix[,zz1[csv$clustertag==type]]),1,sum)})
#�����άת��ά
png(paste("sample_cluster_comparison",".png", sep = ""), width = 500, height = 500 )
comparison.cloud(cluster_matrix)
title(main = "sample cluster comparision")
dev.off()
comparison.cloud(cluster_matrix)
#######################################################��ξ������ͼ
#�������Ŀ�϶࣬����غϿ��������ʹ�����з�������������ͼ��
png("test.png",width=3500,height=3000) #������豸��Ϊpng�����ؾ����ܵĴ󣬵�����ĵĹ������׳������⡣

#cexΪ��ǩ�Ĵ�С,ͬʱ������ʹ��cex.axis�������ı�����ϵ�����ֵĴ�С��ʹ��cex.lab�ı�����������ֵĴ�С

#ʹ��cex.main�ı��Ϸ�����Ĵ�С��ʹ��cex.sub�ı��·����෽�����ƵĴ�С��lwd��ͼ�����ߵĿ�ȣ���ʱͼ�ν����ڹ���Ŀ¼�п���
plot(hc,cex=2,cex.axis=3,cex.lab=3,cex.main=3,cex.sub=3,lwd=1.5)
rect.hclust(hc,k=15, border="red")#�Ծ������ı�ʶ
dev.off()

###################################��ʱ�̹۲��¼�ͼ(��������
meta(corpus,"cluster") <- csv$created
unique_type <- unique(csv$created)
cluster_matrix<-sapply(unique_type,function(type){apply(as.matrix(tdm_matrix[,zz1[csv$created==type]]),1,sum)})
png(paste("sample_ cluster_comparison",".png", sep = ""), width = 800, height = 800 )
comparison.cloud(cluster_matrix)
title(main = "sample cluster comparision")
dev.off()
