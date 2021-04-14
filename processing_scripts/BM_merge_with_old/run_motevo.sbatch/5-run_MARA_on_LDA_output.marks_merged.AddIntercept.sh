#!/bin/sh
# Jake Yeung
# 6-run_MARA_on_LDA_output_highK.sh
# Run MARA on LDA output: highK
# 2019-03-13

# runscript="/home/jyeung/projects/scchic-functions/scripts/motevo_scripts/lib/run_mara_batch_promoters.sh"
runscript="/home/hub_oudenaarden/jyeung/projects/scchic-functions/scripts/motevo_scripts/lib/run_mara_batch_promoters.sh"
[[ ! -e $runscript ]] && echo "$runscript not found, exiting" && exit 1

# jmarks="H3K4me3"
# jmarks="H3K4me3"
jmarks="H3K4me1 H3K4me3 H3K27me3"
# jmarks="H3K4me1"
# jmarks="H3K4me3"

jscale=0
jcenter=0
jbyrow=0

jcenterE="TRUE"

n=0
maxjobs=1

jmem='96G'
jtime='6:00:00'

jbinskeep=250
jtopics=30
# pathprefix="/home/jyeung/hpc"
pathprefix="/hpc/hub_oudenaarden/jyeung/data"

jmem='96G'
jtime='3:00:00'

cdirname="count_mats_peaks_unnorm_LDA_merged"
ndirname="sitecount_mats_WithIntercept"
outprefix="AddIntercept_"

jmark="marks_merged"
# for jmark in $jmarks; do
    # Efname="countmat_PZ_fromHiddenDomains_${jmark}.AllMerged.KeepBestPlates2.GLMPCA_novar_correction.binskeep_${jbinskeep}.ntopics_${jtopics}.2020-02-11.txt"
    Efname="ldaOut.${jmark}.BM_AllMerged.merged_by_clusters_no_NAs.K-30.txt"
    E="${pathprefix}/scChiC/mara_analysis_BM-AllMerged_Peaks_1000/${jmark}/mara_input/${cdirname}/${Efname}"
    Ebase=$(basename $E)
    Ebase=${Ebase%.*}
    [[ ! -e $E ]] && echo "$E not found, exiting" && exit 1

    Nfname="hiddenDomains_motevo_merged.closest.long.scale_0.center_0.byrow_0.addint_1.${jmark}.txt"
    N="${pathprefix}/scChiC/mara_analysis_BM-AllMerged_Peaks_1000/${jmark}/mara_input/${ndirname}/${Nfname}"
    [[ ! -e $N ]] && echo "$N not found, exiting" && exit 1

    Nbase=$(basename $N)
    Nbase=${Nbase%.*}

    outdir="${pathprefix}/scChiC/mara_analysis_BM-AllMerged_Peaks_1000/${jmark}/mara_output/${outprefix}${Ebase}-${Nbase}"
    [[ -d $outdir ]] && echo "$outdir found, continuing for safety" && exit 1
    [[ ! -d $outdir ]] && mkdir -p $outdir

    [[ ! -e $N ]] && echo "$N not found, exiting" && exit 1

    BNAME=$outdir/${jmark}_qsub
    DBASE=$(dirname "${BNAME}")
    [[ ! -d $DBASE ]] && echo "$DBASE not found, exiting" && exit 1

    echo "Running MARA for $jmark"
    echo "bash $runscript $E $outdir $N&"
    echo ". /hpc/hub_oudenaarden/jyeung/software/anaconda3/etc/profile.d/conda.sh; conda activate R3.6; bash $runscript $E $outdir $N" | qsub -l h_rt=${jtime} -l h_vmem=${jmem} -o ${BNAME}.out -e ${BNAME}.err -pe threaded 1 -m beas -M j.yeung@hubrecht.eu -N MARA_${jmark}
# done
