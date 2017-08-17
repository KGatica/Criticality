# Welcome

This repository contains a source	 files	 for	 all	 figures,	 simulated	 data,	 parameter	 fits	 and	 all	 source	 code
used	in	the	research project

"Signatures of criticality arise arise from random subsampling in simple population models"

You can find a pre-print at https://arxiv.org/abs/1603.00097

For reasons	 of	 transparency,	 this	 repository	 is	 a	 direct	 copy	 of	 the	code used	internally within the	project,	complete	with	the	full	and	raw	submission	history of	all	commits.	Given	that,	the	code	(found in the "code" folder) uses	absolute	pathnames	and	is included	as	it	was	run	on	our	workstation	and	on	our	compute-cluster,	it	is	likely	that	it	will	not	work	‘out	of	the	box’.

We	 have	 additionally	 uploaded	 the	 simulated	 data,	 source	 files	 with	 any	 data	that	went	into	any	figure	as	well	as	scripts	for	generating	raw	versions	of	all	figures. The figure scripts were updated to work with the file structure and should run out of the box when exectued from within the "figures" folder. 

The data and results files were uploaded using Git Large File Storage (https://git-lfs.github.com/).  Downloading the .mat and .gc files from this repository requires to install Git LFS. 

During the project, we generated long Markov Chain Monte Carlo runs that were used to gauge the gain in sampling effeciency obtained from Rao-Blackwellizing the Monte Carlo sampler. This repository only contains data on the quantified gain (i.e. the root mean square errors (RMSEs) referred to in the manuscript). The raw files for these MC samples (~ 4.2 GB) can be found on our lab dropbox at
https://www.dropbox.com/sh/ytogs5xdz2q47ab/AABMb_X9dOuRGy0je_BTxJj8a?dl=0

This repository also contains the code used to generate the activity of our simple simulated population of retinal ganglion cells, found under "data/data_generation/". This code can be readily used to generate additional simulated activity. 

We	are	in	the	process	of	preparing	a	well	documented	toolbox	which	implements	
the	statistical	methods	and	algorithms	used	in	the	project,	so	that	they	can	be	
used	 more	 widely	 and	 generally.	 This	 code	 will	 be	 made	 available	 at	
www.mackelab.org/code,	and	at https://github.com/mackelab/CorBinian/.	
