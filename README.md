## JGI single cell assembly pipeline

This is based on a modified version of the JGI microbial isolate pipeline,
removing the steps related to collecting metrics and evaluating the generated
assembly. The pipeline was developed at the JGI and is based around
preprocessing then assembly of overlapping 2x150bp reads from Illumina HiSeq
2500.

  * The JGI decontamination steps are not included here. These include removing
    any reads matching to common animal contaminants (human, cat, dog, mouse)
    and common microbial contaminants (*E.coli*, *Pseudomonas sp.*, *Delftia
    sp*, others).
