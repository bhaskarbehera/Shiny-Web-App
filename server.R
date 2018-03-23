library(shiny)
library(SnowballC)
library(RColorBrewer)
library(wordcloud)
library(NLP)
library(tm)
library(stringi)
library(twitteR)
library(ggplot2)
library(plotly)
library(dplyr)
library(sentimentr)
#enter your api_key,api_secret_key,access_token,access_token_secret
api_key<- '#######'
api_secret_key <- '######'
access_token <- '######'
access_token_secret <- '######'

setup_twitter_oauth(api_key,api_secret_key,access_token,access_token_secret)
shinyServer(function(input,output){
  data <- reactive({
    p <- input$search
    q <- input$i
    list <- searchTwitter(p,n=q, lang="en") 
    tweets.df6 <- twListToDF(list)
  })
  twitter_data <- reactive({
    input$update
    isolate({
      withProgress({
        setProgress(message = "Loading...")
        
        tweets.df6 <- data()
        tweets.df6$text <- gsub("rt", "",tweets.df6$text)
        tweets.df6$text <- gsub("@\\w+", "",tweets.df6$text)
        tweets.df6$text <- gsub("[[:punct:]]", "",tweets.df6$text)
        tweets.df6$text <- gsub("[[:digit:]]", "",tweets.df6$text)
        tweets.df6$text <- gsub("http\\w+", "",tweets.df6$text)
        tweets.df6$text <- gsub("[ |\t]{2,}", "",tweets.df6$text)
        tweets.df6$text <- gsub("^ ", "",tweets.df6$text)
        RemoveUnicode <- function(tweet){
          iconv(tweet, "UTF-8", "ASCII")
        }
        tweets.df6$text<- RemoveUnicode(tweets.df6$text)
        
      })
    })
  })
  
  
  wc_data <- reactive({
    input$update2
    isolate({
      withProgress({
        setProgress(message = "Processing Corpus...")
        
        wc_text <-twitter_data()
        corpus2 <- sapply(wc_text, function(x) iconv(enc2utf8(x), sub = "byte"))
        corpus1 <- Corpus(VectorSource(corpus2))
        clean_corpus1 <- tm_map(corpus1, content_transformer(tolower))
        clean_corpus1 <- tm_map(clean_corpus1,removeNumbers)
        #clean_corpus1 <- tm_map(clean_corpus1,removePunctuation)
        #clean_corpus1 <- tm_map(clean_corpus1,stripWhitespace)
        clean_corpus1 <- tm_map(clean_corpus1,removeWords,stopwords(kind = "en"))
        clean_corpus1 <- tm_map(clean_corpus1,stemDocument)
      })
    })
  })
  wordcloud_rep <- repeatable(wordcloud)
  output$wordcloud2<- renderPlot({
    wc_color <- brewer.pal(8,"Set2")
    if(input$color== "Accent")
      wc_color <- brewer.pal(8,"Accent")
    else
      wc_color <- brewer.pal(8,"Dark2")
    clean_corpus2 <- wc_data()
    wordcloud(clean_corpus2,min.freq = input$freq,colors = wc_color,random.order =input$rand,rot.per = .3)
    
  })
  
  sentiment_rep <- repeatable(sentiment_by)
  emotion_tweets <-reactive({
    clean_data <- twitter_data()
    emotion <- sentiment_by(clean_data)
  })
  output$trend <- renderPlot({
    clean_data <- twitter_data()
    emotion <- sentiment_by(clean_data)
    trend<- emotion$ave_sentiment
    num <- emotion$element_id
    plot(num,trend,ylab = "Sentiment Score",col="red")
  })
  
  output$sent_plot <- renderPlotly({
    clean_data <- twitter_data()
    emotion <- sentiment_by(clean_data)
    emotion$type <- emotion$ave_sentiment
    for(i in 1:length(emotion$type)){
      if(emotion$type[i]< 0)
        emotion$type[i] =-1
      else
        emotion$type[i] = 1
    }
    pos<-sum(emotion$type==1)
    neg<- sum(emotion$type==-1)
    no<- c(pos,neg)
    type_of <- c("Positive Tweets","Negative Tweets")
    df=data.frame(type_of,no)
    plot_ly(df,labels=~type_of,values=no,type = "pie")%>%
      layout(title="Pie-Chart of Twitter Data")
    
  })
  
  
  
  output$table1 <- renderTable({
    tweet <- data()
    clean_data <- twitter_data()
    emotion <- sentiment_by(clean_data)
    tweet$types <- emotion$ave_sentiment
    x <- subset(tweet,tweet$types < 0)
    x
  })
  output$table2 <- renderTable({
    tweet <- data()
    clean_data <- twitter_data()
    emotion <- sentiment_by(clean_data)
    tweet$types <- emotion$ave_sentiment
    y <- subset(tweet,tweet$types ==0 || tweet$types > 0)
    y
  })
  
})
