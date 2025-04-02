
#' Title
#'
#' @param forest GRF forest object of type causal_forest, a causal forest estimate
#'
#' @return A table with two columns, variable names and values of variables importance
#' @export
#'
#' @examples
#' my_table<-vip(my_forest)
#'

vip <- function(forest) {
  amazing_matrix<-forest%>%
    variable_importance()%>%
    as.data.frame()%>%
    mutate(variable=colnames(forest$X.orig))%>%
    mutate(V1=round(V1,digits=3))%>%
    group_by(variable)%>%
    summarize(vip=sum(V1))%>%
    arrange(desc(vip))

  return(amazing_matrix)
}
