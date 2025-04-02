#Function that extract the variable importance in a data frame
#and produces a table with variable name and value,
# in a descending order by value
vip <- function(forest) {
  require(grf)
  amazing_matrix<-forest%>%
    variable_importance()%>%
    as.data.frame()%>%
    mutate(variable=colnames(forest$X.orig))%>%
    mutate(variable=gsub("[[:digit:]]$","",variable))%>% ## remove last number
    mutate(variable=gsub("[[:punct:]]$","",variable))%>% ## remove last number
    mutate(variable=gsub("[[:digit:]]$","",variable))%>% ## remove last number
    mutate(V1=round(V1,digits=3))%>%
    group_by(variable)%>%
    summarize(vip=sum(V1))%>%
    arrange(desc(vip))

  return(amazing_matrix)
}
