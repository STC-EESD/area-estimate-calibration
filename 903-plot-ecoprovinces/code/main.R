
command.arguments   <- commandArgs(trailingOnly = TRUE);
data.directory      <- normalizePath(command.arguments[1]);
code.directory      <- normalizePath(command.arguments[2]);
output.directory    <- normalizePath(command.arguments[3]);
google.drive.folder <- command.arguments[4];
resolution          <- command.arguments[5];

cat("\ndata.directory:",      data.directory,      "\n");
cat("\ncode.directory:",      code.directory,      "\n");
cat("\noutput.directory:",    output.directory,    "\n");
cat("\ngoogle.drive.folder:", google.drive.folder, "\n");
cat("\nresolution:",          resolution,          "\n");

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

start.proc.time <- proc.time();

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# set working directory to output directory
setwd( output.directory );

##################################################
require(jsonlite);
require(sf);
require(sfarrow);
require(stringr);
require(terra);

# source supporting R code
code.files <- c(
    "initializePlot.R"
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
proj4.crs.CoE <- "+proj=aea +lat_0=63.390675 +lon_0=-91.866667 +lat_1=49.000000 +lat_2=90.000000 +x_0=6200000.000000 +y_0=3000000.000000 +datum=NAD83 +units=m +no_defs +type=crs";
SF.crs        <- sf::st_crs(proj4.crs.CoE);

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
data.snapshot    <- "2024-02-19.01";
SF.eco.provinces <- sf::st_read(file.path(data.directory,data.snapshot,"nef_ca_ter_ecoprovince_v2_2.geojson"));
SF.eco.provinces <- sf::st_transform(
    x   = SF.eco.provinces,
    crs = SF.crs
    );
cat("\nSF.eco.provinces\n");
print( SF.eco.provinces   );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
PNG.output <- "plot-ecoprovinces.png";
my.ggplot <- initializePlot();    
my.ggplot <- my.ggplot + ggplot2::geom_sf(
    data = SF.eco.provinces
    );
# my.ggplot <- my.ggplot + ggplot2::coord_sf(
#     crs = sf::st_crs("ESRI:102001")
#     );
# my.ggplot <- my.ggplot + ggplot2::scale_fill_manual(
#     values = grDevices::rainbow(n.colours)
#     );
ggplot2::ggsave(
    filename = PNG.output,
    plot     = my.ggplot,
    units    = 'in',
    height   =   10,
    width    =   12,
    dpi      = 1000
    );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# dashboard.files <- c(
#     "dashboard-highcharter",
#     "dashboard-leaflet"
#     );

# for ( dashboard.file in dashboard.files ) {
#     rmarkdown::render(
#         input         = file.path(code.directory,paste0(dashboard.file,".Rmd")),
#         output_format = flexdashboard::flex_dashboard(theme = "cerulean"), # darkly
#         output_file   = file.path(output.directory,paste0(dashboard.file,".html"))
#         );
#     }

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
print( warnings() );

print( getOption('repos') );

print( .libPaths() );

print( sessionInfo() );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

stop.proc.time <- proc.time();
print( stop.proc.time - start.proc.time );
