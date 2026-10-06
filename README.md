# exotic-manuscript <img src="man/figures/logo.png" align="right" height="140" alt="exotic-manuscript hex sticker" />

[![DOI](https://zenodo.org/badge/512768083.svg)](https://zenodo.org/badge/latestdoi/512768083)

Analysis, tables, and figure scripts for the published manuscript:

> Hoyd R, Wheeler CE, Liu Y, Jagjit Singh MS, Muniak M, Jin N, Denko NC, Carbone DP, Mo X, Spakowicz DJ. Exogenous sequences in tumors and immune cells (exotic): a tool for estimating the microbe abundances in tumor RNA-seq data. *Cancer Research Communications*. 2023 Nov 21;3(11):2375–2385. doi:[10.1158/2767-9764.CRC-22-0435](https://doi.org/10.1158/2767-9764.CRC-22-0435). PMID: [37850841](https://pubmed.ncbi.nlm.nih.gov/37850841/). PMCID: [PMC10662017](https://pmc.ncbi.nlm.nih.gov/articles/PMC10662017/).

Full author names, as printed: Rebecca Hoyd, Caroline E. Wheeler, YunZhou Liu, Malvenderjit S. Jagjit Singh, Mitchell Muniak, Ning Jin, Nicholas C. Denko, David P. Carbone, Xiaokui Mo, and Daniel J. Spakowicz.

Journal page: [Cancer Research Communications 3(11):2375–2385](https://aacrjournals.org/cancerrescommun/article/3/11/2375/730184/Exogenous-Sequences-in-Tumors-and-Immune-Cells).

![Graphical abstract. Tumor RNA-seq from ORIEN and TCGA is processed with exotic, validated against Fusobacterium literature and 16S, and tested for concordant survival, clinical, and immune associations. Alistipes is a network hub for metabolism, inflammation, and apoptosis.](man/figures/graphical-abstract.png)

## The {exotic} tool

Microbe quantification is implemented in the R package [{exotic}](https://github.com/spakowiczlab/exotic) (exogenous sequences in tumors and immune cells). This repository is the companion analysis for the paper. It does not replace the package.

Install the package from GitHub:

```r
install.packages("devtools")
devtools::install_github("spakowiczlab/exotic")
```

- User manual: [doc/user_manual.md](https://github.com/spakowiczlab/exotic/blob/main/doc/user_manual.md)
- Custom Kraken database (bacteria, fungi, viruses, archaea, and selected eukaryotes), plus the hg38 and UniVec filters used by the pipeline: [https://go.osu.edu/exotic-database](https://go.osu.edu/exotic-database)
- Package hex sticker, which this repository’s sticker follows: [`man/figures/logo-v2.png`](https://github.com/spakowiczlab/exotic/blob/main/man/figures/logo-v2.png)

Processed counts from the study are deposited under BioProject [PRJNA856973](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA856973).

## Reproduce the figures

The notebooks below are the scripts that drew the published figures and tables. Run them from a machine that can see the project data, in the order listed. `rmarkdown::render()` sets the working directory to the notebook, which the relative paths `../figures`, `../tables`, and `../data` expect.

```r
rmarkdown::render("analysis/scripts/01_waterfall-plot.RMD")
```

### Where the inputs live

Figure notebooks read a frozen [drake](https://docs.ropensci.org/drake/) snapshot:

`/fs/ess/PAS1695/projects/exotic/data/drake-output/2022-03-08/`

That tree is on the Ohio Supercomputer Center project `PAS1695`. It is not committed here. Rebuilding it, or pointing every `readRDS()` / `data.dir` at a new directory, is required before a notebook will draw. A few smaller inputs are already in the repo: `analysis/data/` and `processing/external-data/kraken2-metaphlan-noplants.txt`.

Two cohort names appear in the scripts. **TCC** is the ORIEN Avatar / Total Cancer Care cohort. **TCGA** is The Cancer Genome Atlas.

ORIEN RNA-seq is controlled-access (Ohio State IRB protocols 2015H0185 and 2013H0199, in coordination with Aster Insights). TCGA BAMs and expression were pulled with `{GenomicDataCommons}` and restricted to primary tumors (LUAD, LUSC, COAD, READ, SARC, SKCM, KIRC, BLCA). The manuscript run used R 3.6.3; the session is recorded in [`processing/drake-pipeline/drake-environment-details.txt`](processing/drake-pipeline/drake-environment-details.txt).

### 1. Counts from FASTQ

Skip this step if you start from the 2022-03-08 drake objects or from PRJNA856973.

| Step | Script | What it does |
| --- | --- | --- |
| STAR alignment to GRCh38 and extraction of unmapped reads | [`processing/generate-inputs/TCC_align-and-k2b.RMD`](processing/generate-inputs/TCC_align-and-k2b.RMD) | Writes PBS array jobs. STAR 2.4.2a environment: [`star-environment-details.txt`](processing/generate-inputs/star-environment-details.txt). |
| Kraken2 + Bracken classification | same notebook, `make.k2b.batch()` | Kraken2 2.0.7_beta and Bracken 2.5: [`braken-environment-details.txt`](processing/generate-inputs/braken-environment-details.txt). |
| Condense Bracken output | [`processing/generate-inputs/brackout-condense.R`](processing/generate-inputs/brackout-condense.R) | Sample-by-taxon count tables. |
| TCGA expression | [`processing/generate-inputs/TCGA-expression-condense.R`](processing/generate-inputs/TCGA-expression-condense.R) and [`gdc-pull.R`](processing/generate-inputs/gdc-pull.R) | Expression matrices joined later in the drake plan. |
| Cohort list | [`processing/generate-inputs/generalized-TCGA-data-pull.RMD`](processing/generate-inputs/generalized-TCGA-data-pull.RMD) | TCGA project download setup. |

Alignment follows the TCGA two-pass STAR workflow. Unmapped reads are classified against the exotic database. Taxa with more than five supporting reads are kept.

### 2. Filtering and normalization

[`processing/drake-pipeline/00_drake-and-format.RMD`](processing/drake-pipeline/00_drake-and-format.RMD) sources `processing/drake-pipeline/R/` and runs `plan.TCCandTCGA` from [`R/plan.R`](processing/drake-pipeline/R/plan.R).

The plan, in order:

1. Drop ORIEN slides flagged as non-GI (`tcc.badslids`) and keep TCGA tumor aliquots.
2. `check_human_percentages(counts, 0.95)` keeps samples in which *Homo sapiens* is more than 95% of classified reads.
3. `resolve_batches()` drops batches that are too small for a contaminant model (sequencing site, preservation, flow cell; batches with fewer than 10 samples).
4. `{decontam}` plus the Poore literature list (`get_contaminants()`, `resolve_contaminants()`) removes taxa correlated with input RNA concentration and taxa repeatedly found in negative controls.
5. `voom_snm_normalization()` keeps cancer type and removes sequencing center and FFPE versus fresh-frozen.
6. `calculate_exogenous_relative_abundance()` and `assign_taxonomy()` attach the Kraken/MetaPhlAn labels in `processing/external-data/kraken2-metaphlan-noplants.txt`.
7. The same VOOM-SNM model is fit to host gene expression.

The notebook saves one RDS per target under `/fs/ess/PAS1695/projects/exotic/data/drake-output/<date>/`. Figure code expects the `2022-03-08` folder. Package dependencies for that plan are in [`R/packages.R`](processing/drake-pipeline/R/packages.R): limma, edgeR, snm, decontam, GenomicDataCommons, and the tidyverse packages pinned in the session file.

Rarefied prevalence, used for every presence/absence test, is built by [`analysis/scripts/processing_generate-rarefied-prevalence.Rmd`](analysis/scripts/processing_generate-rarefied-prevalence.Rmd). Buffa hypoxia scores are built by [`analysis/scripts/processing_tmesig.Rmd`](analysis/scripts/processing_tmesig.Rmd).

### 3. Figure 1 — pipeline and validation

Figure 1A is the pipeline schematic (human alignment, microbial classification, four filters, VOOM-SNM). It is not written by a plotting script. The steps are the drake plan above and the `{exotic}` package.

| Panel | Notebook | File written under `analysis/figures/` |
| --- | --- | --- |
| 1B. Reads lost at each filter | [`01_waterfall-plot.RMD`](analysis/scripts/01_waterfall-plot.RMD) | `waterfall_TCGA-combine-types.pdf` |
| 1C. Sequencing center and FFPE versus fresh-frozen after normalization | [`01_pca_batch-effects_expression.Rmd`](analysis/scripts/01_pca_batch-effects_expression.Rmd) | `pca_compare-seqcen_expr_new.pdf`, `pca_compare-FFPE_expr_new.pdf` |
| 1D. Taxa removed by the RNA-concentration and literature filters | [`01_boxplots-and-corr_contaminants-and-metadata.Rmd`](analysis/scripts/01_boxplots-and-corr_contaminants-and-metadata.Rmd) | `barplot_corrs-with-contam_RNA.pdf` (also `barplot_corrs-with-contam_RIN.pdf`, `barplot_corrs-with-contam_DV200.pdf`, `boxplots_contaminant_FFPE.pdf`) |
| 1E. *Fusobacterium* prevalence versus published colorectal series | [`01_prevalence_literature-review.Rmd`](analysis/scripts/01_prevalence_literature-review.Rmd) | `barplot_prevalence_lit-compare.pdf` |
| 1F. exotic versus Poore et al. DNA-based TCGA prevalence | [`01_barplot_poore.Rmd`](analysis/scripts/01_barplot_poore.Rmd) | `barplot_exotic-poore.pdf` |
| 1G. RNA-seq versus 16S phylum composition | [`01_16s_stackedbar.Rmd`](analysis/scripts/01_16s_stackedbar.Rmd) | `16sValidation_stackedBar.png` |
| 1H. 16S distance, paired tumor and adjacent normal versus unpaired | [`01_16s_distance_boxplot.Rmd`](analysis/scripts/01_16s_distance_boxplot.Rmd) | `16s_distance_boxplot.svg` |

16S panels use `analysis/data/16s_sample_matching.csv`, `analysis/data/16s_counts_long.csv`, and `analysis/data/16s_distances.csv`, plus `tcc.counts.RDS` from the drake snapshot. The Poore comparison reads an earlier export under `/fs/ess/PAS1695/projects/exorien/data/drake-output/2022-03-16/`.

### 4. Figure 2 — survival, clinical variables, and immune cells

Run the estimation notebooks before the plotting notebooks.

| Panel | Estimate, then plot | File written under `analysis/figures/` |
| --- | --- | --- |
| 2A. Presence/absence Cox models at each taxonomic rank, then the ORIEN–TCGA concordance ring | [`02_survival_microbes-all-cancers.Rmd`](analysis/scripts/02_survival_microbes-all-cancers.Rmd), then [`02_visualize_survival.Rmd`](analysis/scripts/02_visualize_survival.Rmd) | `heatmap_ring_TCC_<rank>.pdf`, `heatmap_ring_TCGA_<rank>.pdf`, `heatmap_ring_agree_<rank>.pdf` for ranks `d`, `k`, `p`, `c`, `o`, `f`, `g`, `s` |
| 2B. Example concordant hazards (*Streptomyces* CdTB01, *Acinetobacter calcoaceticus*) | same visualization notebook | `forest_example-microbes.pdf` |
| 2C. Concordant Spearman correlations with age, BMI, and Buffa hypoxia | [`02_correlations_microbes-with-clinical.Rmd`](analysis/scripts/02_correlations_microbes-with-clinical.Rmd), then [`02_visualize_correlations_clin.Rmd`](analysis/scripts/02_visualize_correlations_clin.Rmd) | `lollipop_mic-clin.pdf` |
| 2D. Concordant correlations with CIBERSORT fractions | [`02_correlations_microbes-with-immune.Rmd`](analysis/scripts/02_correlations_microbes-with-immune.Rmd), then [`02_visualize_correlations_immune.Rmd`](analysis/scripts/02_visualize_correlations_immune.Rmd) | `heatmap_sigsum_mic-immune.pdf` |

Survival inputs are rarefied prevalence tables: any reads after rarefaction count as present. Models are Cox proportional hazards, tested by log-likelihood, fit separately in each cohort and cancer, then intersected on FDR and sign. Age, BMI, Buffa score, and immune fractions use Spearman correlation on relative abundance, with the same concordance rule. BMI is shown for ORIEN only, because TCGA is missing most values. Immune fractions are CIBERSORT on unnormalized expression.

Supplementary Figure S1 (abundance thresholds, not presence/absence) is [`02_mtsurv.Rmd`](analysis/scripts/02_mtsurv.Rmd), which writes `analysis/figures/mtsurv_concordance/`. The multi-threshold helper is the [{mt.surv}](https://zenodo.org/record/6644267) package.

### 5. Figure 3 — microbe–gene network

Host genes were associated with microbe abundance while controlling for cancer type. The published panels name *Alistipes finegoldii*, *Bifidobacterium bifidum*, and *Pseudomonas* sp. SDM007. Those labels are hardcoded in the regression notebook, so that notebook is the one that reproduces Figure 3. A parallel Spearman path is listed after it.

Order:

1. [`03_correlations_microbes-with-genes.Rmd`](analysis/scripts/03_correlations_microbes-with-genes.Rmd) and [`03_corr_functions.R`](analysis/scripts/03_corr_functions.R) — per-gene Spearman results on the cluster.
2. [`03_reg_functions.R`](analysis/scripts/03_reg_functions.R) — the same pairs with cancer type in the model. Results were written under `/fs/ess/PAS1695/projects/exotic/data/regressions_mic-gene/`.
3. [`cancer-regression.Rmd`](analysis/scripts/cancer-regression.Rmd) — worked example for *Alistipes*, saved in `analysis/data/regression_alistipes-genes*.csv`.
4. [`03_visualize_regressions_gene.Rmd`](analysis/scripts/03_visualize_regressions_gene.Rmd) — the Figure 3 drawings.

| Panel | What the regression notebook saves |
| --- | --- |
| 3A. Direction agreement between ORIEN and TCGA | [`03_regressions_microbes-with-genes_mosaic.R`](analysis/scripts/03_regressions_microbes-with-genes_mosaic.R) and [`03_regressions_microbes-with-genes_histogram_dir-filtered.R`](analysis/scripts/03_regressions_microbes-with-genes_histogram_dir-filtered.R). The mosaic `ggsave()` still points at an old local path; change it to `../figures/` before rendering. |
| 3B. Power-law degree distribution after keeping the most extreme 5% of concordant associations | `histogram_node-edges-count_reg.pdf` |
| 3C. Highest-degree taxa and their gene edges | `network_path-gene_highlight-mic_regression.pdf` and `alluvial_network-pathways_regression.png` |
| 3D. Hallmark enrichment for *A. finegoldii*, *B. bifidum*, and *Pseudomonas* sp. SDM007 | `barplot_LDA-regression-paths.pdf` |

Supplementary Figure S2 is the extreme-5% edge filter inside `03_visualize_regressions_gene.Rmd` (the step immediately before the degree histogram). Supplementary Figure S3 is the matched random network from [`S_network_random-example.Rmd`](analysis/scripts/S_network_random-example.Rmd), saved as `histogram_random-network_degree-centrality.pdf`.

Spearman versions of the same drawings, without the cancer-type term, are:

- [`03_correlations_microbes-with-genes_mosaic.R`](analysis/scripts/03_correlations_microbes-with-genes_mosaic.R)
- [`03_correlations_microbes-with-genes_histogram_dir-filtered.R`](analysis/scripts/03_correlations_microbes-with-genes_histogram_dir-filtered.R)
- [`03_visualize_correlations_gene.Rmd`](analysis/scripts/03_visualize_correlations_gene.Rmd) → `histogram_node-edges-count.png`, `network_microbe-gene_lit-mics.pdf`, `fgsea_alistipes.pdf`, `fgsea_bifido.pdf`, `alluvial_network-pathways.png`, `network_path-gene_highlight-mic.png`

### 6. Tables

Paper labels and the files the scripts actually write do not always share a number. The path column is the file on disk.

| Paper | Script | Path |
| --- | --- | --- |
| Table 1 | [`tableone_revised.Rmd`](analysis/scripts/tableone_revised.Rmd) | [`analysis/tables/table1_revised.csv`](analysis/tables/table1_revised.csv) |
| Table 1 split by preservation | same notebook | [`analysis/tables/sup_tab1-ffpe-split.csv`](analysis/tables/sup_tab1-ffpe-split.csv) |
| Supplementary Table S1. Survival results | [`02_visualize_survival.Rmd`](analysis/scripts/02_visualize_survival.Rmd) | [`analysis/tables/S1_survival-results.csv`](analysis/tables/S1_survival-results.csv) |
| Supplementary Table S2. Survival concordance joined to centrality | [`S_compare-survival-regression.R`](analysis/scripts/S_compare-survival-regression.R) | [`analysis/tables/summary_survival-network.csv`](analysis/tables/summary_survival-network.csv) |
| Microbe degree table used by that join | [`03_visualize_regressions_gene.Rmd`](analysis/scripts/03_visualize_regressions_gene.Rmd) | [`analysis/tables/S2_network_microbe_degree-centrality.csv`](analysis/tables/S2_network_microbe_degree-centrality.csv) |
| Supplementary Table S3. Gene links of the top-degree microbes | [`03_reg_padj-network.R`](analysis/scripts/03_reg_padj-network.R) | `analysis/tables/sup_network_top-degcent-mics.csv` (written by the script; not committed) |
| Supplementary Table S4. Full degree centrality | [`03_visualize_regressions_gene.Rmd`](analysis/scripts/03_visualize_regressions_gene.Rmd) | [`analysis/tables/S5_degree-centrality_regression.csv`](analysis/tables/S5_degree-centrality_regression.csv) |
| Supplementary Table S5. Closeness centrality | same notebook | [`analysis/tables/network_closeness-centrality_regression.csv`](analysis/tables/network_closeness-centrality_regression.csv) |
| Supplementary Table S6. Betweenness centrality | same notebook | [`analysis/tables/network_betweenness-centrality_regression.csv`](analysis/tables/network_betweenness-centrality_regression.csv) |
| Supplementary Table S7. Hallmark enrichment | same notebook | [`analysis/tables/S8_pathway-enrichment.csv`](analysis/tables/S8_pathway-enrichment.csv) |

[`tableone.Rmd`](analysis/scripts/tableone.Rmd) is the earlier cohort table. [`S9_pathway-enrichment.csv`](analysis/tables/S9_pathway-enrichment.csv) and the `network_*` CSVs without the `_regression` suffix are the Spearman-network exports.

### Other notebooks

These were not main-figure panels:

- [`modeling_FFPE.Rmd`](analysis/scripts/modeling_FFPE.Rmd) — preservation-associated microbes (`modelling_FFPE-microbes.csv`)
- [`additional-reviewer-qs.Rmd`](analysis/scripts/additional-reviewer-qs.Rmd) — prevalence split by cancer and FFPE
- [`S_summary_sig-accross-analyses.Rmd`](analysis/scripts/S_summary_sig-accross-analyses.Rmd) — microbes that recur across survival, clinical, and network tests
- [`02_correlations_microbes-with-clinical.Rmd`](analysis/scripts/02_correlations_microbes-with-clinical.Rmd) also writes the age-randomization check `lollipop_mic-clin_randomize.pdf`
