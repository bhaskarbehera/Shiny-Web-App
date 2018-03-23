library(shiny)
library(shinydashboard)
library(SnowballC)
library(NLP)
library(tm)
library(RColorBrewer)
library(wordcloud)
library(ggplot2)
library(plotly)
shinyUI(
  dashboardPage(title="Twitter Data",
                skin = "blue"
                ,
                dashboardHeader(title = "Sentiment Analysis"
                ),
                dashboardSidebar(
                  sidebarMenu(
                    menuItem("Dashboard",tabName = "dashboard",icon = icon("dashboard")),
                    textInput("search","Enter a search query",value="India"),
                    sliderInput("i","Number of tweets",1,200,50),
                    actionButton("update","Analysis"),
                    "Control For Wordcloud",
                    sliderInput("freq","Select minimum frequency",1,5,1),
                    checkboxInput("rand","Random Order?"),
                    radioButtons("color","Select Theme",c("Accent","Dark2"),selected = "Dark2"),
                    actionButton("update2","Create Wordcloud"),
                    menuItem("Twitter Data",tabName = "data")
                  )),
                dashboardBody(
                  tabItems(
                    tabItem(tabName = "dashboard",
                            fluidRow(
                              tabsetPanel(
                                tabPanel(title = "Wordcloud",status = "primary",solidHeader = T,plotOutput("wordcloud2")),
                                tabPanel(title ="Scatter Plot",status = "primary",solidHeader = T,background="aqua",plotOutput("trend")),
                                tabPanel(title="Pie-Chart",status = "primary",solidHeader = T,background="aqua",plotlyOutput("sent_plot"))
                                
                                
                                
                              )
                            )),
                    tabItem(tabName = "data",
                            fluidRow(
                              tabsetPanel(
                                tabPanel(title = "Negative Tweets",status = "primary",solidHeader = T,tableOutput("table1")),
                                tabPanel(title = "Positive Tweets",status = "primary",solidHeader = T,tableOutput("table2"))
                                
                              )
                            )
                    )
                  )
                )
  )
)