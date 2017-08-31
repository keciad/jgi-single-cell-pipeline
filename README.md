## JGI isolate assembly pipeline

This is based on a modifed version of the JGI microbial isolate pipeline,
removing the steps related to collecting metrics and evaluating the generated
assembly. The pipeline was developed by Brian Bushnell at the JGI and is based
around extensive preprocessing then assembly of overlapping 2x150bp reads from
Illumina HiSeq 2500.

  * Normalisation is not included in the pipeline as it not recommended for
    isolate data, though it may be beneficial for metagenome, single cell or
    RNA-seq data.

  * The JGI decontamination steps are not included here. These include removing
    any reads matching to common animal contaminants (human, cat, dog, mouse)
    and common microbial contaminants (*E.coli*, *Pseudomonas sp.*, *Delftia
    sp*, others).
