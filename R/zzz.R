datacache <- new.env(hash=TRUE, parent=emptyenv())

org.Nv.eg <- function() showQCData("org.Nv.eg", datacache)
org.Nv.eg_dbconn <- function() dbconn(datacache)
org.Nv.eg_dbfile <- function() dbfile(datacache)
org.Nv.eg_dbschema <- function(file="", show.indices=FALSE) dbschema(datacache, file=file, show.indices=show.indices)
org.Nv.eg_dbInfo <- function() dbInfo(datacache)

org.Nv.egORGANISM <- "Notophthalmus viridescens"

## The database ships xz-compressed (49 MB instead of 778 MB) and is unpacked
## into the user cache on the first load (about 10 s). The unpacked file is
## named after the checksum of the compressed one, so a new version replaces it
.unpackDb <- function(pkgname, libname)
{
    xz <- system.file("extdata", "org.Nv.eg.sqlite.xz", package=pkgname, lib.loc=libname)
    cache <- tools::R_user_dir(pkgname, which="cache")
    dbfile <- file.path(cache, paste0("org.Nv.eg_", unname(tools::md5sum(xz)), ".sqlite"))

    if (!file.exists(dbfile)) {
        dir.create(cache, showWarnings=FALSE, recursive=TRUE)
        unlink(list.files(cache, full.names=TRUE)) # An older version

        ## Unpacked in pieces of 10 MB into a temporary file, renamed when complete
        input <- xzfile(xz, "rb")
        output <- file(paste0(dbfile, ".tmp"), "wb")
        repeat {
            piece <- readBin(input, "raw", 1e7)
            if (length(piece) == 0) break
            writeBin(piece, output)
        }
        close(input)
        close(output)
        file.rename(paste0(dbfile, ".tmp"), dbfile)
    }
    dbfile
}

.onLoad <- function(libname, pkgname)
{
    ## Connect to the SQLite DB
    dbfile <- .unpackDb(pkgname, libname)
    assign("dbfile", dbfile, envir=datacache)
    dbconn <- dbFileConnect(dbfile)
    assign("dbconn", dbconn, envir=datacache)

    ## Create the OrgDb object
    db <- loadDb(dbfile, packageName=pkgname)
    dbNewname <- AnnotationDbi:::dbObjectName(pkgname,"OrgDb")
    ns <- asNamespace(pkgname)
    assign(dbNewname, db, envir=ns)
    namespaceExport(ns, dbNewname)

    packageStartupMessage(AnnotationDbi:::annoStartupMessages("org.Nv.eg.db"))
}

.onUnload <- function(libpath)
{
    dbFileDisconnect(org.Nv.eg_dbconn())
}
