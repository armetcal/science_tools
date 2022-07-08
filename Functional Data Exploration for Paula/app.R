library(shiny)
library(tidyverse)
library(readxl)

# Define UI for application that draws a histogram
ui <- fluidPage(
    theme = bslib::bs_theme(bootswatch = "sketchy"),
    
    # Application title
    titlePanel("Functional Data Exploration!"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            
            fileInput("file1", "1. Upload Functional Table",
                      multiple = F,
                      accept = c(".xlsx")),
            
            fileInput("file2", "2. Upload Metadata",
                      multiple = F,
                      accept = c(".xlsx")),
            
            textInput("ylab", "Provide y axis label (Optional):", 
                      value = 'Function (% Abundance)'),
            
            h4('3. Include items from:'),
            
            selectInput("choose_level", NULL,
                        c('Function','Subsystem Level 3','Subsystem Level 2','Subsystem Level 1'), 
                        selected = 'Function',
                        multiple = F),
            
            conditionalPanel(
                condition = "input.choose_level == 'Function'",
                h5('Choose Functional item(s):'),
                uiOutput('choose.F')
            ),
            conditionalPanel(
                condition = "input.choose_level == 'Subsystem Level 3'",
                h5('Choose Level 3 item(s):'),
                uiOutput('choose.L3')
            ),
            conditionalPanel(
                condition = "input.choose_level == 'Subsystem Level 2'",
                h5('Choose Level 2 item(s):'),
                uiOutput('choose.L2')
            ),
            conditionalPanel(
                condition = "input.choose_level == 'Subsystem Level 1'",
                h5('Choose Level 1 item(s):'),
                uiOutput('choose.L1')
            ),
            
            
        ),

        mainPanel(
             br(),
             plotOutput("print_plot1"),
             br(),
             br(),
             br(),
             br(),
             plotOutput("print_plot2")
        )
    )
)

server <- function(input, output) {
    
    df <- reactive({
        req(input$file1)
        upload <- read_xlsx(input$file1$datapath)
        return(upload)
    })
    
    meta <- reactive({
        req(input$file2)
        upload <- read_xlsx(input$file2$datapath)
        return(upload)
    })
    
    output$choose.F <- renderUI({
        req(input$file1)
        df <- df()
        df_s <- unique(df$Function)

        selectizeInput(
            'choicef', label = NULL, choices = df_s,
            options = list(maxOptions = 5), multiple = T
        )
    })
    output$choose.L3 <- renderUI({
        req(input$file1)
        df <- df()
        df_s <- unique(df$`Subsystem Level 3`)

        selectizeInput(
            'choice3', label = NULL, choices = df_s,
            options = list(maxOptions = 5), multiple = T
        )
    })
    output$choose.L2 <- renderUI({
        req(input$file1)
        df <- df()
        df_s <- unique(df$`Subsystem Level 2`)

        selectizeInput(
            'choice2', label = NULL, choices = df_s,
            options = list(maxOptions = 5), multiple = T
        )
    })
    output$choose.L1 <- renderUI({
        req(input$file1)
        df <- df()
        df_s <- unique(df$`Subsystem Level 1`)

        selectizeInput(
            'choice1', label = NULL, choices = df_s,
            options = list(maxOptions = 5), multiple = T
        )
    })
    
    choice = reactive({
        req(input$file1)
        req(input$file2)
        c = c()
        if(input$choose_level == 'Function'){ c = c(c,input$choicef)}
        if(input$choose_level == 'Subsystem Level 1'){ c = c(c,input$choice1)}
        if(input$choose_level == 'Subsystem Level 2'){ c = c(c,input$choice2)}
        if(input$choose_level == 'Subsystem Level 3'){ c = c(c,input$choice3)}
        return(c)
    })
    
    df_formatted <- reactive({
        
        req(input$file1)
        req(input$file2)
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
            right_join(metadata)
        
        return(temp)
    })

    plot1 <- reactive({
        req(df_formatted())
        temp = df_formatted()
        y = input$ylab
        
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
            ylab(y) + ylim(0.95*min,1.15*max) +
            xlab('') + facet_wrap('Diet')
        
        return(t)
    })
    
    plot2 <- reactive({
        req(df_formatted())
        temp = df_formatted()
        y = input$ylab
        
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
            ylab(y) + ylim(0.95*min,1.15*max) + xlab('')
        
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
