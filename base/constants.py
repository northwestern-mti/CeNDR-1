# -*- coding: utf-8 -*-
"""

This page is intended to store application constants that change
very infrequently (if ever).

Author: Daniel E. Cook (danielecook@gmail.com)
"""
from base.config import WORMBASE_VERSION


class PRICES:
    DIVERGENT_SET = 160
    STRAIN_SET = 640
    STRAIN = 15
    SHIPPING = 65


# Maps chromosome in roman numerals to integer
CHROM_NUMERIC = {"I": 1,
                 "II": 2,
                 "III": 3,
                 "IV": 4,
                 "V": 5,
                 "X": 6,
                 "MtDNA": 7}

# WI Strain Info Dataset
GOOGLE_SHEETS = {"orders": "1BCnmdJNRjQR3Bx8fMjD_IlTzmh3o7yj8ZQXTkk6tTXM",
                 "WI": "1V6YHzblaDph01sFDI8YK_fP0H7sVebHQTXypGdiQIjI"}


# Report version = The current HTML template to use for reports.
REPORT_VERSION = "v2"


class URLS:
    """
        URLs are stored here so they can be easily integrated into the database
        for provenance purposes.
    """

    #
    # AWS URLS
    #
    BAM_URL_PREFIX = "https://s3.us-east-2.amazonaws.com/elegansvariation.org/bam"

    """
       Wormbase URLs
    """

    # Gene GTF
    GENE_GTF_URL = f"ftp://ftp.wormbase.org/pub/wormbase/releases/{WORMBASE_VERSION}/species/c_elegans/PRJNA13758/c_elegans.PRJNA13758.{WORMBASE_VERSION}.canonical_geneset.gtf.gz"

    # GENE GFF_URL
    GENE_GFF_URL = f"ftp://ftp.wormbase.org/pub/wormbase/releases/{WORMBASE_VERSION}/species/c_elegans/PRJNA13758/c_elegans.PRJNA13758.{WORMBASE_VERSION}.annotations.gff3.gz"

    # Maps wormbase ID to locus name
    GENE_IDS_URL = "ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/annotation/geneIDs/c_elegans.PRJNA13758.current.geneIDs.txt.gz"

    # Lists C. elegans orthologs
    ORTHOLOG_URL = "ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/PRJNA13758/annotation/orthologs/c_elegans.PRJNA13758.current_development.orthologs.txt"

    #
    # Ortholog URLs
    #

    # Homologene
    HOMOLOGENE_URL = 'https://ftp.ncbi.nih.gov/pub/HomoloGene/current/homologene.data'

    # Taxon IDs
    TAXON_ID_URL = 'ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz'


BIOTYPES = {
    "miRNA": "microRNA",
    "piRNA": "piwi-interacting RNA",
    "rRNA": "ribosomal RNA",
    "siRNA": "small interfering RNA",
    "snRNA": "small nuclear RNA",
    "snoRNA": "small nucleolar RNA",
    "tRNA": "transfer RNA",
    "vaultRNA": "Short non-coding RNA genes that form part of the vault ribonucleoprotein complex",
    "lncRNA": "Long non-coding RNA",
    "lincRNA": "Long interspersed ncRNA",
    "pseudogene": "non-functional gene.",
    "asRNA": "Anti-sense RNA",
    "ncRNA": "Non-coding RNA",
    "scRNA": "Small cytoplasmic RNA"
}

TABLE_COLORS = {"LOW": 'success',
                "MODERATE": 'warning',
                "HIGH": 'danger'}