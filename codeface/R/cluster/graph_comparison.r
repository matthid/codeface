# This file is part of Codeface. Codeface is free software: you can
# redistribute it and/or modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation, version 2.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# Copyright 2013 by Siemens AG, Mitchell Joblin <johannes.ebke.ext@siemens.com>


## TODO: this should be changed to use the Tanimoto coefficient, a more theoriticaly
##       sound and established similairty measure for weighted graphs
vertex.edge.weight.difference <- function(g1, v1, g2, v2) {
  ##  -- To be used only on weighted graphs --
  ## computes the percent difference between two verteces from two different
  ## graphs. The percent difference is calculated based on the difference
  ## between the weights of common edges divided by the average edge weight
  ## -- Output --
  ## percent.difference: pertage DIFFERENCE for the matching edges
  
  g1.adjMat <- get.adjacency(g1)
  g2.adjMat <- get.adjacency(g2)
  
  in.v1  <- neighbors(g1, v1, mode="in")
  out.v1 <- neighbors(g1, v1, mode="out")
  in.v2  <- neighbors(g2, v2, mode="in")
  out.v2 <- neighbors(g2, v2, mode="out")
  
  in.union  = union(in.v1,in.v2)
  out.union = union(out.v1, out.v2)
  in.inter  = intersect(in.v1, in.v2)
  out.inter = intersect(out.v1,out.v2)
  
  if (is.weighted(g1) && is.weighted(g2)){
    
    out.percent.diff <- 0
    in.percent.diff  <- 0
    
    if (length(out.union) != 0){
      out.diff <- abs(g1.adjMat[v1, out.union] - g2.adjMat[v2, out.union])
      out.avg <- 0.5 * (g1.adjMat[v1, out.union] +
            g2.adjMat[v2, out.union])
      out.percent.diff <- mean(out.diff / out.avg)
    }
    if (length(in.union) != 0){
      in.diff <- abs(g1.adjMat[in.union, v1] - g2.adjMat[in.union, v2])
      in.avg  <- 0.5 * (g1.adjMat[in.union, v1]  +
            g2.adjMat[in.union, v2])
      in.percent.diff  <- mean(in.diff / in.avg)
    }
    percent.difference <- mean(c(in.percent.diff, out.percent.diff))
  }
  else{
    e <- simpleError("difference comparison not possible for unweighted
            graphs")
    stop(e)
  }
  
  return(percent.difference)
}


vertex.neighborhood.difference <- function(g1, v1, g2, v2, symmetric=FALSE) {
  ## Calculates the percent similarity using the Jaccard index concept from
  ## set theory. This considers the neighbour hoods of matching
  ## verteces from two different graphs and does not consider the edge weights
  ## rather only the existence of edges.
  ## -- Output --
  ## similarity: a percentage of how SIMILAR the neightboods are
  
  in.v1  <- neighbors(g1, v1, mode="in")
  out.v1 <- neighbors(g1, v1, mode="out")
  in.v2  <- neighbors(g2, v2, mode="in")
  out.v2 <- neighbors(g2, v2, mode="out")
  if (symmetric) {
    inout.v1 = union(in.v1,out.v1)
    inout.v2 = union(in.v2,out.v2)

    totalEdges = length(union(inout.v1,inout.v2))
    matchEdges = length(intersect(inout.v1,inout.v2))
  } else {
    totalEdges = length(union(in.v1,in.v2)) + length(union(out.v1,out.v2))
    matchEdges = length(intersect(in.v1,in.v2)) + length(intersect(out.v1,out.v2))
  }
  
  if (totalEdges != 0) {
    difference = 1 - (matchEdges / totalEdges)
  } else {
    difference = 0
  }

  return(difference)
}

graph.difference <- function(g1,g2, weighted=FALSE, symmetric=FALSE) {
  ## two graphs on the same vertex set can be compared by considering
  ## the percent at which the two graphs agree on an edge
  
  ## compares to graphs that have match indexing, meaning that vertex 1 in g1
  ## is the same person in as vertex 1 in g2. If the graph is weighted then
  ## a difference is considered by calculating a percent difference on matching
  ## edges. If the graph is not weigthed then only the existance of edges
  ## is used to calculated how different the two graphs are.
  
  vertexList1 <- V(g1)
  vertexList2 <- V(g2)
  
  if (!all(vertexList1 == vertexList2)) {
    e <- simpleError("graphs not compatible!")
    stop(e)
  } else {
    vertexList <- vertexList1
  }
  
  vert.diff <- numeric(length(vertexList))
  for (v in vertexList) {
    if (weighted){
      vert.diff[v] <- vertex.edge.weight.difference(g1, v, g2, v)
    } else {
      vert.diff[v] <- vertex.neighborhood.difference(g1, v, g2, v, symmetric=symmetric)
    }
  }
  return(vert.diff)
}


## Compare the results of the tag and non tag based graphs
graph.comparison <- function(g.1, g.2, weighted=FALSE, symmetric=FALSE) {
  ## Normalize graphs to have binary edge weight
  E(g.1)$weight <- ceiling( scale.data(E(g.1)$weight, 0, 1) )
  E(g.2)$weight <- ceiling( scale.data(E(g.2)$weight, 0, 1) )

  #graph.intersection(g.1, g.2, keep.all.vertices = F)
  intersectIds <- intersect(V(g.1)$name, V(g.2)$name)

  idx.1 <- match(intersectIds, V(g.1)$name)
  vertex.names <- V(g.1)$name[idx.1]
  idx.2 <- match(intersectIds, V(g.2)$name)

  ## Build adjacency matrix of interesecting ids
  adj.matrix.1.intersect <- g.1[idx.1, idx.1]
  adj.matrix.2.intersect <- g.2[idx.2, idx.2]

  ## Build igraph graph objects
  g.1.intersect <- graph.adjacency(adj.matrix.1.intersect, mode = "directed")
  g.2.intersect <- graph.adjacency(adj.matrix.2.intersect, mode = "directed")

  graph.diff <- graph.difference(g.1.intersect, g.2.intersect, weighted = weighted, symmetric = symmetric)

  return (data.frame(vertex.names=vertex.names, graph.diff=graph.diff))
}

# Get the raw graph data from the database (by range id)
get.graph.data.from.range <- function(con, range.id) {
  ## TODO: cluster method should not actually be required, we only need the main
  ##       graph, unfortunatley the database scheme currently marries the graph
  ##       to a clustering method
  cluster.method="Spin Glass Community"
  pid <- get.project.id.from.release.range.id(con, range.id)
  graph.data <- get.graph.data.local(con, pid, range.id, cluster.method)
  global.ids <- graph.data$v.global.ids
  node.labels <- sapply(global.ids, function(id)
      query.person.name(con, id))
  graph.data$node.labels <- node.labels
  return (graph.data)
}

# merges the given graph datas by developers and returns the igraph instances.
get.merged.igraphs <- function(graph.data.1, graph.data.2) {
  # get the raw edgelists with the ids from the database
  edgelist.1   <- graph.data.1$edgelist.db
  edgelist.2   <- graph.data.2$edgelist.db
  node.label.1   <- graph.data.1$node.labels
  node.label.2   <- graph.data.2$node.labels
  global.ids.1 <- graph.data.1$v.global.ids
  global.ids.2 <- graph.data.2$v.global.ids

  # Create two dataframes to be merged by developer name
  temp.vertex.df.1 <- data.frame(id1=global.ids.1, name=node.label.1)
  temp.vertex.df.2 <- data.frame(id2=global.ids.2, name=node.label.2)

  # Merge the graphs by developers and create a mapping to local ids
  temp.merged <- merge (temp.vertex.df.1, temp.vertex.df.2, all=T, by="name")
  merged.vertex <- data.frame(id=1:nrow(temp.merged), name=temp.merged$name, id1=temp.merged$id1, id2=temp.merged$id2)

  get.index.map <- function(ids, col.1, col.2) {
    N        <- nrow(ids)
    map      <- new.env(size=N)
    for(i in 1:N) {
      map[[as.character(ids[[col.1]][i])]] <- ids[[col.2]][i]
    }
    return(map)
  }
  map1 <- get.index.map(merged.vertex, "id1", "id")
  map2 <- get.index.map(merged.vertex, "id2", "id")

  # Use the mappings to create a local edge and vertex list for graph1.
  local.ids.1 <- map.ids(global.ids.1, map1)
  edgelist.local.1 <- data.frame(from=map.ids(edgelist.1$fromId, map1),
                                 to=map.ids(edgelist.1$toId, map1),
                                 weight=edgelist.1$weight)
  vertex.df.1 <- data.frame(id1=local.ids.1, name=node.label.1)

  # Use the mappings to create a local edge and vertex list for graph2.
  local.ids.2 <- map.ids(global.ids.2, map2)
  edgelist.local.2 <- data.frame(from=map.ids(edgelist.2$fromId, map2),
                                 to=map.ids(edgelist.2$toId, map2),
                                 weight=edgelist.2$weight)
  vertex.df.2 <- data.frame(id2=local.ids.2, name=node.label.2)

  directed <- T
  ## create graph instances and run the graph comparison.

  # A graph with no weights and only the local vertices
  unmerged.g.1 <- graph.data.frame(
    data.frame(from=edgelist.local.1$from, to=edgelist.local.1$to),
    vertices=vertex.df.1, directed=directed)
  unmerged.g.2 <- graph.data.frame(
    data.frame(from=edgelist.local.2$from, to=edgelist.local.2$to),
    vertices=vertex.df.2, directed=directed)

  # A graph with weights and all vertices
  g.1 <- graph.data.frame(edgelist.local.1, vertices=merged.vertex, directed=directed)
  g.2 <- graph.data.frame(edgelist.local.2, vertices=merged.vertex, directed=directed)

  return (list(g.1=g.1,g.2=g.2,unmerged.g.1=unmerged.g.1,unmerged.g.2=unmerged.g.2))
}

################################################################################
## High Level Functions
################################################################################
run.graph.comparison <- function(igraphs, weighted=FALSE, symmetric=FALSE) {
  g.1 <- igraphs$g.1
  g.2 <- igraphs$g.2
  
  unmerged.g.1 <- igraphs$unmerged.g.1
  unmerged.g.2 <- igraphs$unmerged.g.2
  # vertex.diff describes how different the edges are, we now calculate how different the graphs are
  unmerged.vertex.diff <-
    graph.comparison(unmerged.g.1, unmerged.g.2,
                     weighted = weighted, symmetric = symmetric)

  # vertex.diff describes how different the edges are, we now calculate how different the graphs are
  vertex.diff <- graph.comparison(g.1, g.2, weighted = weighted, symmetric = symmetric)

  nodes.diff <- 1 - (length(intersect(V(unmerged.g.1), V(unmerged.g.2))) / length(V(g.1)))

  # collect all vertex diffs
  total.weight <- 0
  total.weighted.diff <- 0
  total <- 0
  total.diff <- 0
  for (v in 1:nrow(vertex.diff)) {
    current.name <- as.character(vertex.diff$vertex.names[v])
    weight.g.1 <- sum(E(g.1)[incident(g.1, V(g.1)[current.name])]$weight)
    weight.g.2 <- sum(E(g.2)[incident(g.2, V(g.2)[current.name])]$weight)
    weight <- weight.g.1 + weight.g.2
    total.weighted.diff <- total.weighted.diff + (vertex.diff$graph.diff[v] * weight)
    total.weight <- total.weight + weight

    total.diff <- total.diff + vertex.diff$graph.diff[v]
    total <- total + 1
  }
  vertex.weighted.diff <- total.weighted.diff / total.weight
  vertex.total.diff <- total.diff / total

  # The same for the unmerged graph
  if (nrow(unmerged.vertex.diff) > 0) {
    unmerged.total.weight <- 0
    unmerged.total.weighted.diff <- 0
    unmerged.total <- 0
    unmerged.total.diff <- 0
    for (v in 1:nrow(unmerged.vertex.diff)) {
      current.name <- as.character(unmerged.vertex.diff$vertex.names[v])
      # only g.1 and g.2 has weights, but the edges are the same so this is OK
      weight.g.1 <- sum(E(g.1)[incident(g.1, V(g.1)[current.name])]$weight)
      weight.g.2 <- sum(E(g.2)[incident(g.2, V(g.2)[current.name])]$weight)
      # it is possible that one graph has no edges.
      weight <- sum(c(weight.g.1, weight.g.2), na.rm=T)
      unmerged.total.weighted.diff <- unmerged.total.weighted.diff + (unmerged.vertex.diff$graph.diff[v] * weight)
      unmerged.total.weight <- unmerged.total.weight + weight

      unmerged.total.diff <- unmerged.total.diff + unmerged.vertex.diff$graph.diff[v]
      unmerged.total <- unmerged.total + 1
    }
    unmerged.vertex.weighted.diff <- unmerged.total.weighted.diff / unmerged.total.weight
    unmerged.vertex.total.diff <- unmerged.total.diff / unmerged.total
  } else {
    unmerged.vertex.weighted.diff <- 1
    unmerged.vertex.total.diff <- 1
  }

  # merge the collected data
  temp.merge.1 = merge(get.data.frame(g.1, what="vertices"), vertex.diff, by.x="name", by.y="vertex.names", all=T)
  temp.merge.2 = merge(temp.merge.1, unmerged.vertex.diff, by.x="name", by.y="vertex.names", all=T, suffixes =c("",".unmerged"))

  return (list(vertex.diff=temp.merge.2,
               nodes.diff=nodes.diff,
               vertex.weighted.diff=vertex.weighted.diff,
               vertex.total.diff=vertex.total.diff,
               vertex.min.diff=min(vertex.diff$graph.diff),
               unmerged.vertex.weighted.diff=unmerged.vertex.weighted.diff,
               unmerged.vertex.total.diff=unmerged.vertex.total.diff,
               unmerged.vertex.min.diff=min(unmerged.vertex.diff$graph.diff)))
}

# Run a bunch of graph comparisons, with the given parameter
# compare.ranges is a data frame with the columns (original, compare)
# - original should be the base range-id to compare with
# - compare is the range-id to compare the data with
#
# returned will be a list(overview, vertexdata)
# where overview will be a data frame with the following columns:
# (original, compare, original.project.name, compare.project.name, original.type, compare.type,
#  original.range.string, compare.range.string,
#  original.cohesion, original.diameter, original.density, original.transitivity,
#  compare.cohesion, compare.diameter, compare.density, compare.transitivity,
#  nodes.diff,
#  vertex.weighted.diff, vertex.total.diff,
#  unmerged.vertex.weighted.diff, unmerged.vertex.total.diff,
#  rewired.vertex.weighted.diff, rewired.vertex.total.diff,
#  rewired.unmerged.vertex.weighted.diff, rewired.unmerged.vertex.total.diff
#  )
# and vertexdata will be a list of vertex comparison (one entry for each comparison)
# The data will be read from the database when needed.
run.batch.comparison <- function(con, compare.ranges) {
  len <- nrow(compare.ranges)
  graphdata <- list()
  vertexdata <- list()
  overview <- data.frame(id=integer(),
                         original.project.name=character(),
                         original.type=character(),
                         original.range.string=character(),
                         compare.project.name=character(),
                         compare.type=character(),
                         compare.range.string=character(),
                         original.edge.count=numeric(),
                         original.vertex.count=numeric(),
                         original.cohesion=numeric(),
                         original.diameter=numeric(),
                         original.density=numeric(),
                         original.transitivity=numeric(),
                         compare.edge.count=numeric(),
                         compare.vertex.count=numeric(),
                         compare.cohesion=numeric(),
                         compare.diameter=numeric(),
                         compare.density=numeric(),
                         compare.transitivity=numeric(),
                         nodes.diff=numeric(),
                         vertex.weighted.diff=numeric(),
                         vertex.total.diff=numeric(),
                         vertex.min.diff=numeric(),
                         unmerged.vertex.weighted.diff=numeric(),
                         unmerged.vertex.total.diff=numeric(),
                         unmerged.vertex.min.diff=numeric(),
                         rewired.vertex.weighted.diff=numeric(),
                         rewired.vertex.total.diff=numeric(),
                         rewired.vertex.min.diff=numeric(),
                         rewired.unmerged.vertex.weighted.diff=numeric(),
                         rewired.unmerged.vertex.total.diff=numeric(),
                         rewired.unmerged.vertex.min.diff=numeric(),
                         stringsAsFactors=FALSE)
  get.project.data <- function(con, range) {
    project.id <- get.project.id.from.release.range.id(con, range)
    if (is.null(project.id)) stop(str_c("Range id ", range, " is unknown!"))
    cycle <- get.cycle.from.release.range.id(con, range)
    project <- get.project.from.project.id(con, project.id)
    return (list(project.name=project$name, type=project$analysisMethod, range.string=cycle))
  }
  # Calculate some graph metrices
  get.graph.metrices <- function(g) {
    return (list(
      edge.count = length(E(g)),
      vertex.count = length(V(g)),
      cohesion = graph.cohesion(g),
      diameter = diameter(g),
      density = graph.density(g),
      transitivity = transitivity(g)))
  }
  
  myrewire <- function(g) {
    
    #graph.multi <- edge.weight.to.multi(g)
    #graph.multi <- remove.vertex.attribute(graph.multi, 'name')
    
    #rewired <- birewire.rewire(graph.multi, exact=T, verbose=F)
    #E(rewired)$weight <- 1
    #rewired <- simplify(rewired, remove.loops=FALSE)
    #return (graph.adjacency(rewired))
    
    #m<-as.matrix(get.adjacency(graph=g,sparse=TRUE))
    #m2=birewire.rewire(m, max.iter=1)
    #return (graph.adjacency(m2,mode="undirected"))
    
    
    #graph.multi <- edge.weight.to.multi(g)
    if (length(V(g)) > 4) {
      rewired <- rewire(g, mode="simple", niter = (length(E(g))))
      E(rewired)$weight <- rep(1, length(E(rewired)))
      return (rewired)
    } else {
      return (g)
    }
  }
  
  for (i in 1:len) {
    r.1 <- compare.ranges$original[i]
    r.2 <- compare.ranges$compare[i]
    meta.data.1 <- get.project.data(con, r.1)
    meta.data.2 <- get.project.data(con, r.2)
    print (str_c("Calculating comparison of ", meta.data.1$project.name, "/", meta.data.1$type, "(", meta.data.1$range.string ,") with ",
                 meta.data.2$project.name, "/", meta.data.2$type, "(", meta.data.2$range.string ,")..."))
    data.1 <- get.graph.data.from.range(con, r.1)
    data.2 <- get.graph.data.from.range(con, r.2)
    igraphs <- get.merged.igraphs(data.1,data.2)
    diff.sym <- run.graph.comparison(igraphs, symmetric=F)
    diff.rewire <- run.graph.comparison(list(g.1=myrewire(igraphs$g.1),
                                             g.2=myrewire(igraphs$g.2),
                                             unmerged.g.1=myrewire(igraphs$unmerged.g.1),
                                             unmerged.g.2=myrewire(igraphs$unmerged.g.2)))
    
    overview[nrow(overview)+1,] <- c(i,
                                     meta.data.1, meta.data.2,
                                     get.graph.metrices(igraphs$unmerged.g.1), get.graph.metrices(igraphs$unmerged.g.2),
                                     diff.sym$nodes.diff, 
                                     diff.sym$vertex.weighted.diff, diff.sym$vertex.total.diff,diff.sym$vertex.min.diff,
                                     diff.sym$unmerged.vertex.weighted.diff, diff.sym$unmerged.vertex.total.diff, diff.sym$unmerged.vertex.min.diff, 
                                     diff.rewire$vertex.weighted.diff, diff.rewire$vertex.total.diff, diff.rewire$vertex.min.diff,
                                     diff.rewire$unmerged.vertex.weighted.diff, diff.rewire$unmerged.vertex.total.diff, diff.rewire$unmerged.vertex.min.diff)

    #vertexdata[[as.character(str_c(meta.data.2$type, "_", meta.data.2$range.string))]] <- diff.sym$vertex.diff
    vertexdata[[as.character(str_c(as.character(r.1), "/", as.character(r.2)))]] <- diff.sym$vertex.diff
    graphdata[[as.character(str_c(as.character(r.1), "/", as.character(r.2)))]] <- igraphs
  }
  compare.ranges$id <- 1:len
  merged <- merge(compare.ranges, overview, by="id", all=T)
  return (list(overview=merged, vertexdata=vertexdata, graphs=graphdata))
}
