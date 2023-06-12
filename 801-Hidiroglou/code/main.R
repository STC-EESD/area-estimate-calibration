
command.arguments <- commandArgs(trailingOnly = TRUE);
data.directory    <- normalizePath(command.arguments[1]);
code.directory    <- normalizePath(command.arguments[2]);
output.directory  <- normalizePath(command.arguments[3]);

cat("\ndata.directory:",   data.directory,   "\n");
cat("\ncode.directory:",   code.directory,   "\n");
cat("\noutput.directory:", output.directory, "\n");

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

start.proc.time <- proc.time();

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# set working directory to output directory
setwd( output.directory );

##################################################
# source supporting R code
code.files <- c(
    # 'compute-metrics.R',
    # 'SpatRaster-to-polygons.R',
    # 'collapse-classes.R',
    # 'get-nearest-grid-point.R',
    # 'get-sub-spatraster.R',
    # 'test-SpatRaster-to-polygons.R'
    );

for ( code.file in code.files ) {
    source(file.path(code.directory,code.file));
    }

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
my.seed <- 7654321;
set.seed(my.seed);

is.macOS <- grepl(x = sessionInfo()[['platform']], pattern = 'apple', ignore.case = TRUE);
n.cores  <- ifelse(test = is.macOS, yes = 2, no = parallel::detectCores() - 1);
cat(paste0("\n# n.cores = ",n.cores,"\n"));

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
DF.confusion <- utils::read.csv(
    file = file.path(code.directory,"confusion-matrix.csv")
    );
rownames(DF.confusion) <- DF.confusion[,'X'];
DF.confusion <- DF.confusion[,setdiff(colnames(DF.confusion),'X')];
print( str(DF.confusion) );
print(     DF.confusion  );

totals.classified.as <- base::colSums(x = DF.confusion);
print( totals.classified.as );

DF.conditional.probs <- t(apply(
    X      = DF.confusion,
    MARGIN = 1,
    FUN    = function(x) { return( x / totals.classified.as ) } 
    ));
print( str(DF.conditional.probs) );
print(     DF.conditional.probs  );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
DF.pixel.counts.CAR3504 <- utils::read.csv(
    file = file.path(code.directory,"pixel-counts.csv")
    );
print( str(DF.pixel.counts.CAR3504) );
print(     DF.pixel.counts.CAR3504 );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
as.matrix(DF.conditional.probs) %*% as.matrix(DF.pixel.counts.CAR3504[,'pixel.count.CAR3504']);

as.matrix(DF.conditional.probs) %*% as.matrix(DF.pixel.counts.CAR3504[,'pixel.count.ON.ACI']);

##################################################
print( warnings() );

print( getOption('repos') );

print( .libPaths() );

print( sessionInfo() );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

stop.proc.time <- proc.time();
print( stop.proc.time - start.proc.time );
