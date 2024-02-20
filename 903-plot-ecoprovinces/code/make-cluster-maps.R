
make.cluster.maps <- function(
    PQT.slc    = NULL,
    CSV.cutree = NULL
    ) {

    thisFunctionName <- 'make.cluster.maps';
    cat('\n### ~~~~~~~~~~~~~~~~~~~~ ###');
    cat(paste0('\n',thisFunctionName,'() starts.\n\n'));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.slc <- sfarrow::st_read_parquet(dsn = PQT.slc);

    cat("\nstr(sf::st_drop_geometry(SF.slc))\n");
    print( str(sf::st_drop_geometry(SF.slc))   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.cutree <- utils::read.csv(CSV.cutree);
	DF.cutree[,'SLC.ID'] <- as.integer(DF.cutree[,'SLC.ID']);

    colnames.nclusters <- grep(
        x       = colnames(DF.cutree),
        pattern = 'n.clusters',
        value   = TRUE
        );

    for ( temp.colname in colnames.nclusters ) {
        DF.cutree[,temp.colname] <- as.factor(DF.cutree[,temp.colname]);
        }

    cat("\nstr(DF.cutree)\n");
    print( str(DF.cutree)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.slc <- dplyr::left_join(
        x  = SF.slc,
        y  = DF.cutree,
        by = 'SLC.ID'
        );

    cat("\nSF.slc\n");
    print( SF.slc   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    for ( temp.colname in colnames.nclusters ) {
        temp.stem <- gsub(
            x           = temp.colname,
            pattern     = '\\.',
            replacement = ''
            );
        make.cluster.maps_plot(
            SF.input     = SF.slc,
            colname.fill = temp.colname,
            PNG.output   = paste0('plot-map-',temp.stem,'.png')
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0('\n\n',thisFunctionName,'() quits.'));
    cat('\n### ~~~~~~~~~~~~~~~~~~~~ ###\n');
    return( NULL );

    }

##################################################
make.cluster.maps_plot <- function(
    SF.input     = NULL,
    colname.fill = NULL,
    PNG.output   = 'plot-temp.png'
    ) {
    colnames(SF.input) <- gsub(
        x           = colnames(SF.input),
        pattern     = paste0('^',colname.fill,'$'),
        replacement = "temp.colname"
        );
    n.colours <- length(unique(unlist(sf::st_drop_geometry(SF.input[,'temp.colname']))));
    my.ggplot <- initializePlot(
        subtitle = colname.fill
        );    
    my.ggplot <- my.ggplot + ggplot2::geom_sf(
        data    = SF.input,
        mapping = ggplot2::aes(fill = temp.colname)
        );
    my.ggplot <- my.ggplot + ggplot2::coord_sf(
        crs = sf::st_crs("ESRI:102001")
        );
    my.ggplot <- my.ggplot + ggplot2::scale_fill_manual(
        values = grDevices::rainbow(n.colours)
        );
    ggplot2::ggsave(
        filename = PNG.output,
        plot     = my.ggplot,
        units    = 'in',
        height   =   10,
        width    =   16,
        dpi      = 1000
        );
    return( NULL );
    }
