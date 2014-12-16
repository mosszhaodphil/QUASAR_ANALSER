
file_name = 'signal_quasar.nii.gz';
file_handle = load_nii(file_name);

set_MR_param(file_handle);

asl_signal = get_asl_signal(file_handle);
