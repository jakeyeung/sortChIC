#!/bin/sh
# Jake Yeung
# run.split_bam_by_cluster.sh
#  
# 2020-01-09

jmem='16G'
jtime='12:00:00'

ps="/home/hub_oudenaarden/jyeung/projects/scchic-functions/scripts/processing_scripts/split_bam_by_cluster.py"
jmarks="H3K4me1 H3K4me3 H3K27me3 H3K9me3"
# jmarks2="K4me1 K4me3 K27me3 K9me3"
mapq=40

# indir="/hpc/hub_oudenaarden/jyeung/data/scChiC/raw_data/ZellerRawData_B6_All_MergedByMarks_final"
# indir="/hpc/hub_oudenaarden/jyeung/data/scChiC/raw_data_spikeins/BMround2all_VAN5046_VAN5109_VAN5230_BM_VAN5232_VAN5233_VAN5234_VAN5235_VAN5236/tagged_bams_links"
indir="/hpc/hub_oudenaarden/jyeung/data/scChiC/raw_data/ZellerRawData_B6_All_MergedByMarks_final.bams_remerged_by_cluster.MAPQ_40"
# annotdir="/hpc/hub_oudenaarden/jyeung/data/scChiC/from_rstudioserver/cell_cluster_tables"
annotdir="/hpc/hub_oudenaarden/jyeung/data/scChiC/from_rstudioserver/cell_cluster_tables.spikeins_mouse.BMround2_umaps_and_ratios.Round1Round2"

[[ ! -d $indir ]] && echo "$indir not found, exiting" && exit 1
[[ ! -d $annotdir ]] && echo "$annotdir not found, exiting" && exit 1


for jmark in $jmarks; do
    # outdir="/hpc/hub_oudenaarden/jyeung/data/scChiC/raw_data/ZellerRawData_B6_All_MergedByMarks_final.bams_by_cluster.MAPQ_${mapq}"
    # outdir="/hpc/hub_oudenaarden/jyeung/data/scChiC/raw_data_spikeins/BMround2all_VAN5046_VAN5109_VAN5230_BM_VAN5232_VAN5233_VAN5234_VAN5235_VAN5236/tagged_bams_links/split_by_cluster.MAPQ_${mapq}/${jmark}"
    outdir="/hpc/hub_oudenaarden/jyeung/data/scChiC/raw_data_spikeins/BM_merge_first_and_second/split_by_cluster.MAPQ_${mapq}/${jmark}"
    [[ ! -d $outdir ]] && mkdir $outdir
    # [[ ! -d $outdir ]] && echo "$outdir not found, exiting" && exit 1  # make dir before hand
    # annotname="spikeins_mouse.BMround2_umaps_and_ratios.colfix.celltyping.2020-10-31.WithRelLevels.mark_${jmark}.cell_cluster_tables.txt"
    annotname="spikeins_mouse.BMround1and2_umaps_and_ratios.colfix.celltyping.2020-11-01.WithRelLevels.mark_${jmark}.cell_cluster_tables.txt"
    annotfile=${annotdir}/${annotname}
    [[ ! -e $annotfile ]] && echo "$annotfile not found, exiting" && exit 1
    inf=${indir}/${bname}.bam
    jmarkshort=`echo $jmark | sed 's/^H3//g'`
    # echo $jmark
    # echo $jmarkshort
    # "PZ-BM-H3K4me1-1.sorted.tagged.bam"
    for inf in `ls -d ${indir}/*${jmarkshort}*.bam`; do
        # [[ ! -e $inf ]] && echo "$inf not found, exiting" && exit 1
        bname=$(basename $inf)
        bname=${bname%.*}

        BNAME=$outdir/${bname}.qsub
        DBASE=$(dirname "${BNAME}")
        [[ ! -d $DBASE ]] && echo "$DBASE not found, exiting" && exit 1
        # echo ". /hpc/hub_oudenaarden/jyeung/software/anaconda3/etc/profile.d/conda.sh; conda activate py3; python $ps -infile $inf -annotfile $annotfile -outdir $outdir -mapq ${mapq}" | qsub -l h_rt=${jtime} -l h_vmem=${jmem} -o ${BNAME}.out -e ${BNAME}.err -pe threaded 1 -N split_${jmark} -m beas -M j.yeung@hubrecht.eu
        cmd=". /hpc/hub_oudenaarden/jyeung/software/anaconda3/etc/profile.d/conda.sh; conda activate py3; python $ps -infile $inf -annotfile $annotfile -outdir $outdir -mapq ${mapq} --remove_chr_prefix"
        sbatch --time=$jtime --mem-per-cpu=$jme --output=${BNAME}_%j.log --ntasks=1 --nodes=1 --job-name=${jmark} --wrap "$cmd"
    done
done

# inf="/hpc/hub_oudenaarden/jyeung/data/scChiC/raw_data/ZellerRawDataB6_redo_2019-12-13.tagged_bams_mergedbymarks/H3K4me3-BM_Linneg_SC-merged.tagged.bam"
# annotfile="/hpc/hub_oudenaarden/jyeung/data/intestinal_scchic/from_rstudioiserver/pdfs_clustering/clusters_BM_All_merged_H3K4me3_20000_10000.txt"
# outdir="/hpc/hub_oudenaarden/jyeung/data/scChiC/raw_data/ZellerRawData_B6_redo_2019-12-13.split_bams_by_clusters"

# . /hpc/hub_oudenaarden/jyeung/software/anaconda3/etc/profile.d/conda.sh; conda activate py3; python $ps -infile $inf -annotfile $annotfile -outdir $outdir -mapq 40 --add_chr_prefix

