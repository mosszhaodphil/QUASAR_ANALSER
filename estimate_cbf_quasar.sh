#!/bin/sh

# Assign arguments
file_data=$1 # ASL tag - control file
file_option=$2 # Model based analysis options file
file_aif_option=$3 # Model free analysis AIF options file

echo "Begin model based analysis..."
home_dir=`pwd`

# Get current timestamp as output directory name
current_time=$(date +%H%M%S)

out_dir_mbased="$current_time"_mbased
out_cbf_mbased=perfusion_"$current_time"_mbased
out_abv_mbased=abv_"$current_time"_mbased


# Model fitting
# fabber --data=$file_data --data-order=singlefile --output=$out_dir_mbased -@ $file_option

# Rescale CBF to ml/100g/min unit
#fslmaths $out_dir_mbased/mean_ftiss -mul 6000 $out_cbf_mbased

# Rescale ABV to percentage
#fslmaths $out_dir_mbased/mean_fblood -mul 100 $out_abv_mbased

echo "Model based analysis finished."

echo "Begin model free analysis"
out_dir_mfree="$current_time"_mfree
out_cbf_mfree=perfusion_"$current_time"_mfree

# Split files
mkdir $out_dir_mfree
cd $out_dir_mfree

# Split QUASAR ASL (differenced) sequence into six phases
asl_file --data=$home_dir/$file_data --ntis=6 --ibf=tis --iaf=diff --split=asldata_ph
# 3rd and 6th phases are noncrushed signal
fslmaths asldata_ph002 -add asldata_ph005 -mul 0.5 asl_noncrush
# 1st, 2nd, 4th, and 5th phases are crushed signals
# Average them to get tissue signal
fslmaths asldata_ph000 -add asldata_ph001 -add asldata_ph003 -add asldata_ph004 -mul 0.25 asl_tissue
# Blood signal = noncruseshed - tissue
fslmaths asl_noncrush -sub asl_tissue asl_blood

# Inference AIF
fabber --data=asl_blood --mask=$home_dir/mask --output=aif --data-order=singlefile -@ $home_dir/$file_aif_option 

# Get AIF shape
fslmaths aif_latest/modelfit -div aif_latest/mean_fblood aif_shape

# Model free analysis (deconvolution) without arrival time correction
# asl_mfree --data=$home_dir/signal_tissue --mask=$home_dir/mask --out=modfree --aif=$home_dir/signal_aif --dt=0.3

# asl_mfree --data=$home_dir/asl_tissue --mask=$home_dir/mask --out=modfree --aif=$home_dirsignal_aif --dt=0.3

asl_mfree --data=asl_tissue --mask=$home_dir/mask --out=modfree --aif=aif_shape --dt=0.3

cd $home_dir

# Rescaling
#fslmaths $out_dir_mfree/modfree_magntiude -mul 6000 -div 2 -div 0.9 $out_cbf_mfree

fslmaths $out_dir_mfree/modfree_magntiude -mul 6000 $out_cbf_mfree

echo "Model free analysis finished."

echo "Complete"

