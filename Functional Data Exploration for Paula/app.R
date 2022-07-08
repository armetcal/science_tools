library(shiny)
library(tidyverse)
library(readxl)

# Define UI for application that draws a histogram
ui <- fluidPage(
    theme = bslib::bs_theme(bootswatch = "sketchy"),
    
    # Application title
    titlePanel("Functional Data Exploration, Version 2.0!"),

    # Sidebar ----
    sidebarLayout(
        # Panel ----
        sidebarPanel(
            h5(em("Now takes multiple files!")),
            br(),
            fileInput("file1", "1. Upload Functional Table(s)",
                      multiple = T,
                      accept = c(".xlsx")),
            
            selectInput("choose_level", '2. Include items from:',
                        c('Function','Subsystem Level 3','Subsystem Level 2','Subsystem Level 1'), 
                        selected = 'Function',
                        multiple = F),
            
            conditionalPanel(
                condition = "input.choose_level == 'Function'",
                '3. Choose Functional item(s):',
                uiOutput('choose.F')
            ),
            conditionalPanel(
                condition = "input.choose_level == 'Subsystem Level 3'",
                '3. Choose Level 3 item(s):',
                uiOutput('choose.L3')
            ),
            conditionalPanel(
                condition = "input.choose_level == 'Subsystem Level 2'",
                '3. Choose Level 2 item(s):',
                uiOutput('choose.L2')
            ),
            conditionalPanel(
                condition = "input.choose_level == 'Subsystem Level 1'",
                '3. Choose Level 1 item(s):',
                uiOutput('choose.L1')
            ),
            
            
            textInput("ylab", "4. Provide y axis label (Optional):", 
                      value = '')
            
        ),
        # Main ----
        mainPanel(
            # Tabs ----
            tabsetPanel(type = "tabs",
                        id = "all_tabs",
                        tabPanel("Plots",
                                     br(),
                                     plotOutput("print_plot1"),
                                     br(),
                                     br(),
                                     br(),
                                     br(),
                                     br(),
                                     br(),
                                     plotOutput("print_plot2")
                        ),
                        tabPanel('Plot Data',
                                 br(),
                                 downloadButton("download_table", "Download output as .csv"),
                                 br(),
                                 br(),
                                 fluidRow(column(9,dataTableOutput("table")))
                                 )
            )
            #----
        )
    )
)

server <- function(input, output, session) {
    
    df <- reactive({
        req(input$file1)
        upload <- read_xlsx(input$file1[[1,'datapath']])
        L = length(input$file1$datapath)
        if(L>1){
            for (i in 2:L) {
                temp <- read_xlsx(input$file1[[i,'datapath']])
                upload <- rbind(upload, temp)
            }
        }
        return(upload)
    })
    
    meta <- reactive({
        req(input$file1)
        upload <- data.frame(`Sample ID` = c("CON_1_D0","CON_2_D0","CON_3_D0","CON_4_D0","CON_5_D0",
                                             "CON_6_D0","CON_7_D0","CON_8_D0","CON_9_D0","CON_10_D0",
                                             "LM_1_D0","LM_2_D0","LM_3_D0","LM_4_D0","LM_5_D0","LM_6_D0",
                                             "LM_7_D0","LM_8_D0","LM_9_D0","LM_10_D0","CON_1_D28",
                                             "CON_2_D28","CON_3_D28","CON_4_D28","CON_5_D28",
                                             "CON_6_D28","CON_7_D28","CON_8_D28","CON_9_D28","CON_10_D28",
                                             "LM_1_D28","LM_2_D28","LM_3_D28","LM_4_D28",
                                             "LM_5_D28","LM_6_D28","LM_7_D28","LM_8_D28","LM_9_D28",
                                             "LM_10_D28"),
                             Day = c("Day 0","Day 0","Day 0","Day 0","Day 0","Day 0","Day 0","Day 0",
                                     "Day 0","Day 0","Day 0","Day 0","Day 0","Day 0","Day 0","Day 0",
                                     "Day 0","Day 0","Day 0","Day 0","Day 28","Day 28","Day 28",
                                     "Day 28","Day 28","Day 28","Day 28","Day 28","Day 28","Day 28",
                                     "Day 28","Day 28","Day 28","Day 28","Day 28","Day 28","Day 28",
                                     "Day 28","Day 28","Day 28"),
                             Diet = c("CON","CON","CON","CON","CON","CON","CON","CON","CON","CON",
                                      "LM","LM","LM","LM","LM","LM","LM","LM","LM","LM",
                                      "CON","CON","CON","CON","CON","CON","CON","CON","CON","CON",
                                      "LM","LM","LM","LM","LM","LM","LM","LM","LM","LM"))
        names(upload)[1] = 'Sample ID'
        return(upload)
    })
    
    output$choose.F <- renderUI({
        selectizeInput(
            'choicef', label = NULL, choices = NULL,
            options = list(), multiple = T
        )
    })
    # Make loading the options faster
    observe({
        temp=df()
        temp=temp$Function %>% unique() %>% sort()
        updateSelectizeInput(session, 'choicef', 
                         choices = temp, 
                         server = TRUE)})
    
    output$choose.L3 <- renderUI({
        df <- df()
        df_s <- unique(df$`Subsystem Level 3`) %>% sort()
        
        selectizeInput(
            'choice3', label = NULL, choices = df_s,
            options = list(), multiple = T
        )
    })
    
    output$choose.L2 <- renderUI({
        df <- df()
        df_s <- unique(df$`Subsystem Level 2`) %>% sort()

        selectizeInput(
            'choice2', label = NULL, choices = df_s,
            options = list(), multiple = T
        )
    })
    output$choose.L1 <- renderUI({
        df <- df()
        df_s <- unique(df$`Subsystem Level 1`) %>% sort()

        selectizeInput(
            'choice1', label = NULL, choices = df_s,
            options = list(), multiple = T
        )
    })
    
    choice = reactive({
        req(input$file1)
        c = c()
        if(input$choose_level == 'Function'){ c = c(c,input$choicef)}
        if(input$choose_level == 'Subsystem Level 1'){ c = c(c,input$choice1)}
        if(input$choose_level == 'Subsystem Level 2'){ c = c(c,input$choice2)}
        if(input$choose_level == 'Subsystem Level 3'){ c = c(c,input$choice3)}
        return(c)
    })
    
    df_formatted <- reactive({
        
        req(input$file1)
        temp = df()
        metadata = meta()
        level = input$choose_level
        var = c(choice())
        
        w = which(names(temp) == level)
        names(temp)[w] = 'test_level'
        temp = temp %>% filter(test_level %in% var)
        temp = temp[,c(5:ncol(temp))]
        temp = t(temp) %>% as.data.frame()
        temp = temp %>% rownames_to_column('Sample ID')
        if(ncol(temp)>2){
            temp$test = rowSums(temp[,c(2:ncol(temp))])
        } else {
            temp$test = temp$V1
        }
        temp = temp %>% select(`Sample ID`, test) %>%
            right_join(metadata) %>% 
            select(`Sample ID`, Day, Diet, test)
        
        return(temp)
    })

    output$table <- renderDataTable({
        req(choice())
        df = df_formatted() %>% arrange(Diet) %>% arrange(Day) %>% 
            rename('Function (/100%)' = test)
        return(df)
    })
    output$download_table <- downloadHandler(
        filename = 'datatable.csv',
        content = function(filename) {
            df = df_formatted() %>% arrange(Diet) %>% arrange(Day) %>% 
                rename('Function (/100%)' = test)
            write.csv(df, filename, row.names = F)
        }
    )
    
    y_axis_label <- reactive({
        req(choice())
        y = input$ylab
        if(y==''){
            y = choice()
            y = y[1]
            y = paste(y,' (% Ab.)',sep='')
        }
        y = str_replace_all(y,'_',' ')
        
        if(str_length(y)<26){
            y = str_replace_all(y,' ',' ')
        } else if(str_length(y)<70 & str_detect(y,' ')){
            cut_point = ceiling(str_count(y,' ')/2)
            w = (unlist(gregexpr(' ', y)))[cut_point]
            y = paste(str_sub(y,1,w),'\n',str_sub(y,w+1),sep='')
        } else if(str_detect(y,' ')){
            cut_point_1 = ceiling(str_count(y,' ')/3)
            cut_point_2 = ceiling(str_count(y,' ')/1.5)
            w1 = (unlist(gregexpr(' ', y)))[cut_point_1]
            w2 = (unlist(gregexpr(' ', y)))[cut_point_2]
            y = paste(str_sub(y,1,w1),'\n',str_sub(y,w1+1,w2),'\n',str_sub(y,w2+1),sep='')
        }
        
        return(y)
    })
    
    plot1 <- reactive({
        req(df_formatted())
        temp = df_formatted()
        y = y_axis_label()
        
        min = min(temp$test,na.rm=T)
        max = max(temp$test,na.rm=T)
        comp_1 = list( c("Day 0", "Day 28"))
        cols = c('CON' = '#FC746E','LM' = '#01BEC3')
        
        t = temp %>% ggplot(aes(Day, test)) +
            geom_boxplot(outlier.shape = NA, aes(fill = Diet)) +
            scale_fill_manual(values = cols) +
            geom_jitter(height = 0, width = 0.2) +
            theme_classic(base_size = 20) + 
            ggpubr::stat_compare_means(comparisons = comp_1, label = 'p.format', size = 5)+
            ylim(0.95*min,1.15*max) +
            ylab(y) + xlab('') + facet_wrap('Diet')
        if(str_length(y)>26){
            t = t + theme_classic(base_size = 18)
        }
        
        return(t)
    })
    
    plot2 <- reactive({
        req(df_formatted())
        temp = df_formatted()
        y = y_axis_label()
        
        min = min(temp$test,na.rm=T)
        max = max(temp$test,na.rm=T)
        comp_2 = list( c("CON", "LM"))
        cols = c('CON' = '#FC746E','LM' = '#01BEC3')
        
        t2 = temp %>% filter(Day == 'Day 28') %>% 
            ggplot(aes(Diet, test)) +
            geom_boxplot(outlier.shape = NA, aes(fill = Diet)) +
            scale_fill_manual(values = cols) +
            geom_jitter(height = 0, width = 0.2) +
            theme_classic(base_size = 20) + 
            ggpubr::stat_compare_means(comparisons = comp_2, label = 'p.format', size = 5)+
            ylim(0.95*min,1.15*max) + xlab('')+ ylab(y)
        if(str_length(y)>26){
            t2 = t2 + theme_classic(base_size = 18)
        }
        return(t2)
    })
    
    output$print_plot1 <- renderPlot({
        req(plot1())
        p = plot1()
        p
    }, height = 500, width = 800, res = 100)
    output$print_plot2 <- renderPlot({
        req(plot2())
        p = plot2()
        p
    }, height = 500, width = 600, res = 100)
}

# Run the application 
shinyApp(ui = ui, server = server)
