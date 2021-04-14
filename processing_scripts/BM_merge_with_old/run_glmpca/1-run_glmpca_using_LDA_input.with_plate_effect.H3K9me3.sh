#!/bin/sh
# Jake Yeung
# 1-run_glmpca_using_LDA_input.sh
#  
# 2020-11-17

jmem='16G'
jtime='24:00:00'

# rs="/home/hub_oudenaarden/jyeung/projects/scchic-functions/scripts/processing_scripts/run_GLMPCA_with_LDA_init.R"
rs="/home/hub_oudenaarden/jyeung/projects/scchic-functions/scripts/processing_scripts/run_GLMPCA_with_LDA_init_spikeins_plate.R"

# jmarks="H3K4me1 H3K4me3 H3K27me3"
jmarks="H3K9me3"
# jmark="H3K4me1"
# jcname="cell.var.within.sum.norm.log2.CenteredAndScaled"
platename="plate"
szname="none"

# it greps these rownames should be ok, rownames expected in form 1:344-6000;chr1:344-6000
# jchromos="chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19"

# bincutoff=10000
# bincutoff=5000
bincutoff=0
binskeep=0
niter=500

outdir="/hpc/hub_oudenaarden/jyeung/data/scChiC/glmpca_outputs"
annotdir="/hpc/hub_oudenaarden/jyeung/data/scChiC/from_rstudioserver/cell_cluster_tables.spikeins_mouse.BMround2_umaps_and_ratios.Round1Round2.redo_after_varfilt_with_spikeins"

indirpeaks="/hpc/hub_oudenaarden/jyeung/data/scChiC/raw_demultiplexed/LDA_outputs_all_spikeins/ldaAnalysisBins_mouse_spikein_BMround2all_MergeWithOld.frompeaks.filtNAcells_allbins"

for jmark in $jmarks; do
    peakname="lda_outputs.count_mat_from_hiddendomains.${jmark}.filtNAcells_allbins.K-30.binarize.FALSE/ldaOut.count_mat_from_hiddendomains.${jmark}.filtNAcells_allbins.K-30.Robj"
    infpeaks=${indirpeaks}/${peakname}
    [[ ! -e $infpeaks ]] && echo "$infpeaks not found, continuing" && continue
    # infpeaks="${indirpeaks}/lda_outputs.count_mat_from_sitecount_mat.${jmark}.filtNAcells_allbins.K-30.binarize.FALSE/ldaOut.count_mat_from_sitecount_mat.${jmark}.filtNAcells_allbins.K-30.Robj"
    outbase=${outdir}/glmpca.${jmark}.bincutoff_${bincutoff}.binskeep_${binskeep}.byplate.szname_${szname}.niter_${niter}.reorder_rownames.notfromsitecounts
    BNAME=${outdir}/glmpca.${jmark}.bincutoff_${bincutoff}.binskeep_${binskeep}.byplate.szname_${szname}.niter_${niter}.reorder_rownames.notfromsitecounts
    DBASE=$(dirname "${BNAME}")
    [[ ! -d $DBASE ]] && echo "$DBASE not found, exiting" && exit 1

    outcheck=${outbase}.RData
    [[ -e $outcheck ]] && echo "$outcheck found, continuing" && continue

    annotname="cell_cluster_table_with_spikeins.${jmark}.2020-11-18.txt"

    annotf=${annotdir}/${annotname}

    cmd=". /hpc/hub_oudenaarden/jyeung/software/anaconda3/etc/profile.d/conda.sh; conda activate R3.6; Rscript $rs -infpeaks $infpeaks -infmeta $annotf -outbase $outbase -platecname $platename -sizefactorcname $szname -bincutoff $bincutoff -binskeep $binskeep -niter $niter"
    sbatch --time=$jtime --mem-per-cpu=$jmem --output=${BNAME}_%j.log --ntasks=1 --nodes=1 --job-name=${jmark} --wrap "$cmd"
done
