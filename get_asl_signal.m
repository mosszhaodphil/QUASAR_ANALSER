% This function returns a vector of ASL intensity from a nifty file at a given voxel specified by roi parameter in param_user.mat

function asl_signal = get_asl_signal(file_handle)
	load('param_user.mat');

	asl_signal = zeros(length(file_handle.img(roi_x, roi_y, roi_z, :)), 1);

	for j = 1 : length(file_handle.img(roi_x, roi_y, roi_z, :))
		asl_signal(j) = file_handle.img(roi_x, roi_y, roi_z, j);
	end
end