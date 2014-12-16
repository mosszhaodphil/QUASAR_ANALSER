

function [] = set_MR_param(file_handle)
	
	image_dimension = file_handle.hdr.dime.dim(2 : 5)

	% Update the MR parameters in param_MR.mat file
	load('param_MR.mat')
	x        = image_dimension(1); % x dimension of k space
	y        = image_dimension(2); % y dimension of k space
	z        = image_dimension(3); % total number of slices
	length_t = image_dimension(4); % total number of sampling points
	save('param_MR.mat', 'x', 'y', 'z', 'length_t'); % update changes

end