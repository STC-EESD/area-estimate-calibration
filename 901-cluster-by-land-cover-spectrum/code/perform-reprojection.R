
perform.reprojection <- function(
    directory.aoi     = NULL,
    output.directory  = "output-reproject",
    WKT.Canada.Albers = NULL,
    DF.coltab.SDLU    = NULL,
    colour.NA         = 'black'
    ) {

    thisFunctionName <- "perform.reprojection";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    original.directory <- normalizePath(getwd());

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( dir.exists(paths = output.directory) ) {
        cat("The directory",output.directory,"already exists; do nothing ...");
        cat(paste0("\n",thisFunctionName,"() quits."));
        cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
        return( NULL );
    } else {
        dir.create(path = output.directory, recursive = TRUE);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    tiff.files <- list.files(
        path    = file.path(original.directory,directory.aoi),
        pattern = "\\.tiff$"
        );

    cat("\ntiff.files\n");
    print( tiff.files   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    for ( temp.tiff in tiff.files ) {
        perform.reprojection_reproject(
            collapse           = TRUE,
            tiff.aoi           = temp.tiff,
            original.directory = original.directory,
            directory.aoi      = directory.aoi,
            WKT.Canada.Albers  = WKT.Canada.Albers,
            DF.coltab.SDLU     = DF.coltab.SDLU,
            output.directory   = output.directory
            );
        # perform.reprojection_collapse.if.applicable(
        #     tiff.aoi            = temp.tiff,
        #     original.directory  = original.directory,
        #     DF.coltab.SDLU      = DF.coltab.SDLU,
        #     output.directory    = output.directory
        #     );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    setwd(original.directory);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
perform.reprojection_collapse.if.applicable <- function(
    tiff.aoi            = NULL,
    original.directory  = NULL,
    DF.coltab.SDLU      = NULL,
    output.directory    = NULL,
    colour.NA           = 'black'
    ) {

    thisFunctionName <- "perform.reprojection_collapse.if.applicable";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    temp.directory <- gsub(
        x       = tiff.aoi,
        pattern = "raster-buffered-[0-9]{2}-",
        replacement = ""
        );
    temp.directory <- gsub(
        x           = temp.directory,
        pattern     = "\\.tiff",
        replacement = ""
        );
    temp.directory <- file.path(original.directory,output.directory,temp.directory);
    cat("\noriginal.directory\n");
    print( original.directory   );
    cat("\ntemp.directory\n");
    print( temp.directory   );
    if ( !dir.exists(paths = temp.directory) ) {
        dir.create(path = temp.directory, recursive = TRUE);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    setwd(temp.directory);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    non.collapsed.tiff.files <- grep(
        x       = list.files(pattern = "\\.tiff$"),
        pattern = "collapse",
        invert  = TRUE,
        value   = TRUE
        );
    non.collapsed.tiff.files <- setdiff(
        non.collapsed.tiff.files,
        'original.tiff'
        );
    cat("\nnon.collapsed.tiff.files\n");
    print( non.collapsed.tiff.files   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    for ( tiff.file in non.collapsed.tiff.files ) {

        TIF.collapsed <- gsub(
            x           = tiff.file,
            pattern     = "\\.tiff",
            replacement = "-collapse.tiff"
            );

        PNG.collapsed <- gsub(
            x           = tiff.file,
            pattern     = "\\.tiff",
            replacement = "-collapse.png"
            );

        SR.original <- terra::rast(tiff.file);

        collapse.classes.AAFC.SDLU(
            SR.input       = SR.original,
            DF.coltab.SDLU = DF.coltab.SDLU,
            TIF.output     = TIF.collapsed
            );
        SF.collapsed <- terra::rast(TIF.collapsed);

        terra::coltab(SF.collapsed) <- DF.coltab.SDLU[,c('value','col')];

        png(
            filename = PNG.collapsed,
            res      = 300,
            width    =  12,
            height   =  10,
            units    = 'in'
            );
        terra::plot(
            x     = SF.collapsed,
            colNA = colour.NA
            );
        dev.off();

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    rm(list = c(
        "SR.original",
        "SF.collapsed"
        ));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    setwd(original.directory);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

perform.reprojection_reproject <- function(
    collapse            = NULL,
    tiff.aoi            = NULL,
    original.directory  = NULL,
    directory.aoi       = NULL,
    WKT.Canada.Albers = NULL,
    DF.coltab.SDLU      = NULL,
    output.directory    = NULL,
    aggregation.factor  = 2,
    colour.NA           = 'black'
    ) {

    temp.directory <- gsub(
        x       = tiff.aoi,
        pattern = "raster-buffered-[0-9]{2}-",
        replacement = ""
        );
    temp.directory <- gsub(
        x           = temp.directory,
        pattern     = "\\.tiff",
        replacement = ""
        );
    temp.directory <- file.path(original.directory,output.directory,temp.directory);
    cat("\noriginal.directory\n");
    print( original.directory   );
    cat("\ntemp.directory\n");
    print( temp.directory   );
    if ( !dir.exists(paths = temp.directory) ) {
        dir.create(path = temp.directory, recursive = TRUE);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    setwd(temp.directory);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SR.original <- terra::rast(
        file.path(original.directory,directory.aoi,tiff.aoi)
        );

    cat("\nhas.colors(SR.original)\n");
    print( has.colors(SR.original)   );

    cat("\nterra::coltab(SR.original)\n");
    print( terra::coltab(SR.original)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( collapse ) {
        cumulative.stem <- "original-collapse";
    } else {
        cumulative.stem <- "original";
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    TIF.cumulative <- paste0(cumulative.stem,".tiff");
    PNG.cumulative <- paste0(cumulative.stem,".png" );

    if ( collapse ) {
        collapse.classes.AAFC.SDLU(
            SR.input       = SR.original,
            DF.coltab.SDLU = DF.coltab.SDLU,
            TIF.output     = TIF.cumulative
            );
        SR.cumulative <- terra::rast(TIF.cumulative);
        terra::coltab(SR.cumulative) <- DF.coltab.SDLU[,c('value','col')];
    } else {
        terra::writeRaster(
            x         = SR.original,
            filename  = TIF.cumulative,
            overwrite = FALSE
            );
        SR.cumulative <- terra::rast(TIF.cumulative);
        }

    cat("\nhas.colors(SR.cumulative)\n");
    print( has.colors(SR.cumulative)   );

    cat("\nterra::coltab(SR.cumulative)\n");
    print( terra::coltab(SR.cumulative)   );

    png(
        filename = PNG.cumulative,
        res      = 300,
        width    =  12,
        height   =  10,
        units    = 'in'
        );
    terra::plot(
        x     = SR.cumulative,
        colNA = colour.NA
        );
    dev.off();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( collapse ) {
        # just to capture levels and colours
        random.string <- paste(
            sample(x = c(LETTERS,letters), size = 10, replace = TRUE),
            collapse = ""
            );
        TIF.temp <- paste0(random.string,".tiff");
        terra::aggregate(
            x        = SR.cumulative,
            fact     = 2,
            fun      = 'modal',
            filename = TIF.temp
            );
        SR.temp <- terra::rast(TIF.temp);
        temp.levels <- levels(SR.temp);
        temp.coltab <- terra::coltab(SR.temp);
        files.to.remove <- list.files(pattern = TIF.temp);
        base::file.remove(files.to.remove);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # reproject to Albers by nearest neighbour

    TIF.reprojected <- paste0(cumulative.stem,"-reprojectNear.tiff");
    PNG.reprojected <- paste0(cumulative.stem,"-reprojectNear.png" );

    random.string <- paste(
        sample(x = c(LETTERS,letters), size = 10, replace = TRUE),
        collapse = ""
        );
    TIF.temp <- paste0("tmp-",random.string,".tiff");

    terra::project(
        x        = SR.cumulative,
        y        = terra::crs(WKT.Canada.Albers),
        filename = TIF.temp,
        method   = 'near',
        res      = terra::res(SR.cumulative)[1]
        );
    SR.reprojected <- terra::rast(TIF.temp);
    if ( collapse ) {
        levels(SR.reprojected) <- temp.levels;
        terra::coltab(SR.reprojected) <- temp.coltab;
        }

    terra::writeRaster(
        x         =  SR.reprojected,
        filename  = TIF.reprojected,
        overwrite = TRUE
        );

    png(
        filename = PNG.reprojected,
        res      = 300,
        width    =  12,
        height   =  10,
        units    = 'in'
        );
    terra::plot(
        x     = SR.reprojected,
        colNA = colour.NA
        );
    dev.off();

    files.to.remove <- list.files(pattern = TIF.temp);
    base::file.remove(files.to.remove);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    rm(list = c(
        "SR.original",
        "SR.cumulative",
        "SR.reprojected"
        ));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    setwd(original.directory);
    return( NULL );

    }
