%ASLIB	an ALPHA SHAPE function library
%
%	use ASHAPE as a convenient wrapper
%	for instructions/options see also: ASHAPE
%
%SYNTAX
%-------------------------------------------------------------------------------
%	FH = ASLIB;
%		returns a structure of handles to ASLIB functions
%
%	     ASLIB  s  |  -s
%	P  = ASLIB('s' | '-s' | 0);
%		shows FUNCTION names/actions and a GLOSSARY of terms
%
%	     ASLIB  f  |  -f
%	P  = ASLIB('f' | '-f' | 1);
%		shows FIELD names/contents
%
%	     ASLIB  o  |  -o
%	P  = ASLIB('o' | '-o' | 2);
%		shows OPTIONS
%
%	     ASLIB(P);
%	P  = ASLIB(P);
%	C  = ASLIB(P,1);
%		checks validity of P
%
%OUTPUT
%-------------------------------------------------------------------------------
%  P	returns an ASLIB structure with empty/default fields
%  P.f	holds FH
%  C	returns an summary structure in quiet mode
%
%EXAMPLES
%-------------------------------------------------------------------------------
%	P = ASHAPE(...)		compute ALPHA COMPONENTS and return results in P
%	P.f.gall(P)		show		all components
%	P.f.gall(P,1)		delete		all components
%	P.f.gcir(P,opt)		show		all ALPHA CIRCLES with new options
%	P.f.gcir(P,1)		delete		all ALPHA CIRCLES
%	-or-
%	FH = aslib;		get function handles to most recent functions
%	FH.gall(P);		equivalent to	P.f.gall(P)
%	-or-
%	fun=P.f.gcir;		set an alias
%	fun(P,opt);		equivalent to	P.f.gcir(P,opt)
%	...
%	set([P.h.AS_con{:}],.)	redefine	all ALPHA NODE props
%	...
%	P = ASHAPE(P,[opt]);	re-compute a previous ASLIB result
%				using the most recent library version

% created:
%	us	05-Feb-1994
% modified:
%	us	13-Apr-2010 15:31:23

% test data
%{
	r=.75;
	x=[1,2,3,4,5,4,5].';
	y=[1,-1,1,2,3,0,1].';
%}

%--------------------------------------------------------------------------------
function	fh=aslib(varargin)

	if	nargout
		fh=[];
	end

	if	nargin
	if	nargin  >= 1
% remove CB6 colorbar
	if	strcmp(varargin{1},'delete')
		ASLIB_cb6(varargin{:});
		return;
	end
% help
		ftmp=ASLIB_ashelp(varargin{:});
	end
	if	nargout
		fh=ftmp;
	end
		return;
	end
		fh=ASLIB_asfun;
end
%--------------------------------------------------------------------------------
%--------------------------------------------------------------------------------
% ASLIB VERSION / HELP / PARAMETER INITIALIZER
%--------------------------------------------------------------------------------
function	[vtag,vid,MLvid,mag]=ASLIB_asver(mag)
% - version tracker
%   *** only change <vid> if functions/fields change ***

		vtag=		'13-Apr-2010 15:31:23';
%		vid =5.02; %	'12-Mar-2005'
%		vid =5.03; %	'20-Oct-2007'	/ FEX
%		vid =6.01; %	'19-Jul-2008'	/ FEX
%		vid =7.11; %	'02-Apr-2010'	/ FEX
		vid =8.02; %	'12-Apr-2010'	/ FEX

		MLvid=sscanf(version,'%2f',2).';
end
%--------------------------------------------------------------------------------
function	c=ASLIB_aschk(p,mod)

% - check version

		magic='ASHAPE';
	if	nargin < 2
		mod=1;
	end

		[ver,vid,MLvid,mag]=ASLIB_asver(magic);	%#ok
		c.r=0;
		c.msg='';
		c.class=class(p);
		c.p=p;

	if	isstruct(p)
	if	isfield(p,'magic')
	if	strcmp(p.magic,mag)
	if	p.ASLIBvid >= vid
		return;
	else
		c.msg=sprintf(...
			['ASLIB> version mismatch\n',...
			 'ASLIB> input   version  %7.2f (%s)\n',...
			 'ASLIB> current version  %7.2f (%s)\n',...
			 'ASLIB> run                       p=ashape(p.x,p.y,p.r);'],...
			p.ASLIBvid,p.ASLIBver,vid,ver);
		c.r=1;
	end
	else
		c.msg=sprintf(...
			'ASLIB> input is not a valid ASLIB structure:\nASLIB> missing field <magic=%s>',mag);
		c.r=2;
	end
	else
		c.msg=sprintf(...
			'ASLIB> input is not a valid structure:\nASLIB> missing field <magic>');
		c.r=3;
	end
	else
		c.msg=sprintf(...
			'ASLIB> input is not a structure:\nASLIB> class %s',c.class);
		c.r=4;
	end
	if	mod
		error(c.msg);
	end
end
%--------------------------------------------------------------------------------
function	fh=ASLIB_ashelp(varargin)

% - common help engine
%   *** NOTE formatting is optimized for fixed width fonts (eg, courier new) ***

		opt=varargin{1};
	if	(~isnumeric(opt) || (numel(opt) ~= 1)) && ~ischar(opt)
		c=ASLIB_aschk(opt,0);
	if	nargin > 1
		fh=c;
		return;
	end
	if	~c.r
		disp(sprintf('ASLIB> input is a valid ASLIB parameter structure'));
	else
		disp(c.msg);
	end
		fh=opt;
		return;
	end
		fh=ASLIB_apars(1);

		rbreak=repmat('-',1,23);
		delimiter=repmat('-',1,128);
	switch	opt

% - functions
	case	{0 's' '-s'}
		txt={
'FH = ASLIB;'
'     returns ASLIB function handles in structure FH'
' '
'FH			action		(A=alpha)'
delimiter
[rbreak ' COMPUTATIONAL ENGINES']
'.aini(x,y,r,opt)	initialize parameters and compute all possible'
'			segments from delaunay tessellation'
'			- x	x coordinates of input'
'			- y	y coordinates of input'
'			- r	radius        of circle'
'			- opt	option(s)'
' P = FH.aini(..)	- P	common ASLIB parameter structure'
'.circ(P,xoff,yoff)	create an A circle template'
'			- xoff	x offset		[def: 0]'
'			- yoff	y offset		[def: 0]'
'			- P.r	radius'
'			- P.ang	resolution		[def: 1, <-a>]'
'.mseg(P)		evaluate A nodes/A edges	[P.ashape]'
'.rseg(P)		remove   A nodes ~= lines	[P.sshape]'
'    .cfit(P,tix)	fit an A circle to two points'
'			- tix	index into P.dt'
'    .cchk(P)		check whether x/y points are within an A circle'
'.mcon(P)		compute list of connected A shapes'
'.mpat(P)		compute A patches within A shapes'
'    .cpat(P)		find best fitting next A edge at a n>1 degree A node'
'			using closest angle (and torsion of direction)'
'			from the preceding A edge'
[rbreak ' GRAPHICS ENGINES']
'.gall(P,opt)		show/delete all components:'
'.gdat(P,opt)		show/delete     data'
'.gcir(P,opt)		show/delete     A circles'
'.gseg(P,opt)		show/delete     A edges'
'.gcon(P,opt)		show/delete     A nodes'
'.gmod(P,opt)		show/delete specs:		[see: ASLIB -f]'
'					A nodes		[P.dmod]'
'					A edges		[P.amod]'
'.gpat(P,opt)		show/delete A patches'
'			- opt'
'			  a numeric	delete component'
'			  ''-opt(s)''	redraw component using new option(s)'
[rbreak ' UTILITY ENGINES']
'.mark(P,ix1,...,ixN)	mark A shapes/A patches on figure P.gpat()'
'			- ixX	 A shape'
'			- ixX	[A shape, A patch]'
delimiter
'GLOSSARY		(A=alpha)'
delimiter
'segment			a line connecting two x/y vertices as determined'
'			from delaunay tessellation'
'A circle		a circle to find vertices/segments that form'
'			an A shape'
'A node			a vertex  that is part of an A shape/A patch'
'A edge			a segment that is part of an A shape/A patch'
'A line			a two-sided A edge'
'A shape			connected A edges that form an unique shape'
'A patch			a closed digraph of A edges within an A shape'
'			that can be used as input to <patch>'
delimiter
'NOTE'
'	for an explanation of fields	see: ASLIB -f'
'	for    options			see: ASLIB -o'
		};

% - fields
	case	{1 'f' '-f'}
		txt={
'P.field		contents	(A=alpha)'
delimiter
'.f		function handles to ASLIB functions'
'.h.X		cells of graphics handles'
'			.AS_bar	= colorbar'
'			.AS_dat	= x/y data points'
'			.AS_cir	= A circles'
'			.AS_seg	= A edges'
'			.AS_con	= A nodes'
'.opt		run-time options'
'.flg		option flags and run-time parameters'
'.m		nr of all data points'
'.n		nr of unique and sorted data points'
'.x/.y		x/y coordinates of unique and sorted data points'
'.dmod		data point spec:'
'			0  = not an A node: inside A shape|singleton'
'			2  = A node'
'			4  = n>1 degree A node'
'			6+ = A node bifurcation between A edges of type 2&4'
'.nd		nr of unique segments      from delaunay tessellation'
'.dt		vertex indices of segments from delaunay tessellation'
'.drng		min/max of .dl'
'.dix		last index of sorted .dl <= .r'
'.dl		length/2 of segments'
'.r		radius of A circle'
'.ang		resolution of A circle				[def: 1 deg]'
'.xcir/.ycir	x/y coordinates of A circle template (.r/.ang)'
'.nseg		nr of A edges'
'.cen		x/y coordinates of centers of A circles'
'.seg		A edges (radius    search)'
'.segp		A edges (inpolygon search)			[use: -t]'
'.amod		A edge spec:'
'			1  = one-sided A edge (line)'
'			2  = two-sided A edge (polygon|bifurcation)'
'.nshape		nr of A shapes'
'.xshape		index of .seg into each unique A shape'
'.lshape		length of A shapes'
'.ashape		indices of A edges forming a unique A shape'
'.sshape			P.ashape(s) with P.amod == 1'
'.pmod		A patch connection mode				[def: ''angle'']'
'.npatch		nr of A patches'
'.xpatch		index of A shapes into A patches'
'.spatch		size of .apatch'
'			rows = nr of A shapes used'
'			cols = nr of A patch(es)/A shape'
'.lpatch		length of each A patch'
'.apatch		node indices of each A patch'
'.mpatch		A patch spec:'
'			1 = A patch is a subset of an A shape'
'			2 = A patch is A shape'
delimiter
'NOTE'
'	for an explanation of functions	see: ASLIB -s'
'	for a  glossary of terms	see: ASLIB -s'
'	for    options			see: ASLIB -o'
		};

% - options
	case	{2 'o' '-o'}
 		txt={
'OPT	args		contents	(A=alpha)'
delimiter
[rbreak ' PROCESSING']
' -a	degrees		angular resolution of A circles			[def: 1 deg]'
'				note: used for display and <-t>'
' -cd	diameter	diameter of A circles				[def: .ASLIB_aini(.,.,2*r)]'
' -cr	radius		radius   of A circles				[def: .ASLIB_aini(.,.,  r)]'
' -pta	none		find optimal A patches using the preceding'
'			A edge''s angle and direction of torsion		[def: angle]'
' -nu	none		do NOT extract unique x/y data points'
' -qh	{qhull-opt[s]}	set new qhull options				[def: {''QJ'',''Pp''}]'
'			for more options see:'
'				http://www.qhull.org'
[rbreak ' GRAPHICS']
' -bc	none		keep/plot .cen for both A circles/edge		[def: first match only]'
' -nc	none		do NOT keep/plot .cen for A circles'
' -am	none		use A shape colors to render A patches		[def: red>green>yellow>blue]'
' -cm	colormap(nc)	use <colormap> to render connected A shapes	[def: red>blue]'
'				note: <nc> colors are recycled'
' -cm	''colormap''	use the <''colormap''> function'
'				note: the colormap will be computed at'
'				run-time from <colormap(.nshape)>'
' -pc	[r g b]		define A patch selection color			[def: [0 1 1]]'
' -pp	none		plot A patches at runtime			[def: .gall(P)]'
' -g	none		do NOT plot at run-time				[def: .gall(P)]'
'				use:	P.f.gall(p,[opt]);'
'					    to plot all components'
'					P.f.ASLIB_gpat(p,[opt]);'
'					    to plot A patches'
[rbreak ' MISCELLANEOUS']
' -t	none		test x/y data points using ML''s <inpolygon>'
'			and compare results with the def <radius>'
'			search engine'
'				the input to <inpolygon> is the'
'				A circle computed by .circ and'
'				depends on parameters .r/.ang'
'				note: this may take longer!'
' -v	none		display progress at run-time			[def: quiet]'
' -wb	none		show progress bars				[def: none]'
delimiter
'NOTE'
'	for an explanation of functions	see: ASLIB -s'
'	for an explanation of fields	see: ASLIB -f'
'	for a  glossary    of terms	see: ASLIB -s'
		};

	otherwise
		disp(sprintf('ASLIB> unknown option!\n'));
		help(mfilename);
		return;
	end
		disp(char(txt));
end
%--------------------------------------------------------------------------------
function	p=ASLIB_apars(mod)

% - common ASLIB parameter structure
% - note several fields are removed after computation

		magic='ASHAPE';
		zint=int32([]);

		[ver,vid,MLvid,p.magic]=ASLIB_asver(magic);
		p.ASLIBver=ver;
		p.ASLIBvid=vid;
		p.MLver=version;
		p.MLvid=MLvid;
		p.f=ASLIB_asfun;
		p.h.pref='AS_';
		p.h.([p.h.pref,'bar'])={[]};
		p.section_1='--- run-time parameters ----------------';
		p.time=datestr(clock);
		p.runtime=clock;
		p.opt=[];
		p.flg=[];
		p.section_2='--- data -------------------------------';
		p.m=0;
		p.n=0;
		p.x=[];
		p.y=[];
		p.dmod=zint;
		p.section_3='--- delaunay tessellation segments -----';
		p.nd=0;
		p.dt=zint;
		p.drng=[];
		p.dix=0;
		p.dl=[];
		p.section_4='--- alpha circle template --------------';
		p.r=0;
		p.ang=0;
		p.xcir=0;
		p.ycir=0;
		p.section_5='--- alpha edges ------------------------';
		p.nseg=0;
		p.cen=[];
		p.seg=zint;
		p.segp=zint;
		p.amod=zint;
		p.section_6='--- alpha shapes -----------------------';
		p.nshape=0;
		p.xshape=zint;
		p.lshape=zint;
		p.ashape={};
		p.sshape={};
		p.section_7='--- alpha patches ----------------------';
		p.pmod='angle';
		p.npatch=0;
		p.xpatch=zint;
		p.spatch=zint;
		p.lpatch=zint;
		p.apatch={};
		p.mpatch=zint;
	if	nargin && mod == 1
		return;
	end
% - temporary fields
%   removed after computation
		p.cfn=fieldnames(p);
		p.cflg=false;
		p.cmsg='';
		p.r2=0;
		p.cr=[];
		p.xp=[];
		p.yp=[];
		p.ix=zint;
		p.cx=[];
		p.cy=[];
		p.ip=[];
		p.op=[];
		p.tfn='must remove itself!';
		p.tfn=fieldnames(p);
end
%--------------------------------------------------------------------------------
function	fh=ASLIB_asfun

% - library functions

		magic='ASLIB';

		fh.magic=magic;
		[fh.ver,fh.vid,fh.MLvid]=ASLIB_asver(magic);
%   computational engines
		fh.section_1='--- computational engines --------------';
		fh.aini=@ASLIB_aini;	% common initializer
		fh.circ=@ASLIB_circ;	%	create circle
		fh.mseg=@ASLIB_mseg;	% compute A edges
		fh.rseg=@ASLIB_rseg;	% remove  A edges > one-side
		fh.cfit=@ASLIB_cfit;	%	fit circle to rad/2pts
		fh.cchk=@ASLIB_cchk;	%	check region for pts inside circle
		fh.mcon=@ASLIB_mcon;	% create tree of unique A shapes
		fh.mpat=@ASLIB_mpat;	% compute A patches
		fh.cpat=@ASLIB_cpat;	%	find next A edge at n>1 dim A nodes
%   graphics engines
		fh.section_2='--- graphics engines -------------------';
		fh.gall=@ASLIB_gall;	% show all components
		fh.gdat=@ASLIB_gdat;	% show data
		fh.gcir=@ASLIB_gcir;	% show A circles
		fh.gseg=@ASLIB_gseg;	% show A shape edges
		fh.gcon=@ASLIB_gcon;	% show A shape nodes
		fh.gpat=@ASLIB_gpat;	% show A patches
		fh.gmod=@ASLIB_gmod;	% show A modes
%   utility engines
		fh.section_3='--- utility engines --------------------';
		fh.mark=@ASLIB_mark;	% mimick mouse clicks
%   utilities
	if	fh.MLvid(1) <= 7				&&...
		fh.MLvid(2) < 5
		fh.cbar=@() colorbar('v6','horizontal');	%#ok
	else
		fh.cbar=@() ASLIB_cb6('horizontal');
	end
end
%--------------------------------------------------------------------------------
function	p=ASLIB_aini(x,y,r,varargin)

% - initialize common ASLIB parameter structure

% - return empty ASLIB structure
	if	~nargin
		p=ASLIB_apars(1);
		return;
	end

% - return clean structure
	if	nargin < 4 && isstruct(x)
		p=x;
		ASLIB_aschk(p,1);
	if	isfield(p,'tfn')
		ix=ismember(p.tfn,p.cfn);
		p=rmfield(p,p.tfn(~ix));
		ASLIB_vdisp(p,sprintf('      done aslib:  %36.3fs',...
				p.runtime));
	end
		return;
	end

% - set/check input parameters
	if	numel(x) < 3 || numel(y) < 3
		error('ASLIB> too few x/y data points: [%-1d/%-1d]',numel(x),numel(y));
	end
	if 	numel(x) ~= numel(y)
		error('ASLIB> nr of x/y data points do NOT match: [%-1d/%-1d]',numel(x),numel(y));
	end

% - initialize common parameters
		n=numel(x);
		p=ASLIB_apars;
		p.f=aslib;
		p.r=r;
		p.ang=1;

% - set/check options
		p=ASLIB_asopt(p,0,varargin{:});

	if	p.flg.uniq
		xy=ASLIB_asunique([x(:),y(:)]);
	else
		xy=[x(:),y(:)];
	end
		p.x=xy(:,1);
		p.y=xy(:,2);
		p.m=n;
		p.n=numel(p.x);
	if	p.n < 3
		error('ASLIB> too few unique x/y data points for delaunay tessellation: [%-1d]',p.n);
	end

% - set default parameters
%   create A circle template
	if	~isempty(p.flg.cdia)
		p.r=.5*p.flg.cdia;
	elseif	~isempty(p.flg.crad)
		p.r=p.flg.crad;
	end
	if	p.r <= 0
		error('ASLIB> alpha circle radius <= 0: [%g]',r);
	end
	if	mod(p.flg.dang,360) <= 0
		error('ASLIB> modulus of alpha circle angle <= 0: [%g]',p.flg.dang);
	end
%V		p.r2=(p.r*p.r)+eps;		% FP!
		p.r2=(p.r*p.r)+2*eps(p.r);	% FP!
		p=ASLIB_circ(p,0,0);

		ASLIB_vdisp(p,sprintf('processing aslib:'));
		ASLIB_vdisp(p,sprintf('processing data:     %7d/%7d  (%5.1f%%)',...
				p.n,p.m,100*p.n/p.m));

% - get segments
		ti=clock;
		p=ASLIB_asdelaunay(p);
		to=clock;
		ASLIB_vdisp(p,sprintf('      done data:  %37.3fs',...
				etime(to,ti)));
end
%--------------------------------------------------------------------------------
function	p=ASLIB_asopt(p,mod,varargin)

% - set/check options

		ASLIB_aschk(p,1);

%   default ASLIB options
		pscol=[0 1 1];		% patch selection color
%   default QHULL options
	if	p.MLvid(1) <= 7				&&...
		p.MLvid(2) < 10
		qopt={'QJ','Pp'};
	else
		qopt={};		% r2010a+
	end
%   user options	opt	flag	ini	def	nr parameters
%			---------------------------------------------
		opt={
%   processing
			'-a'	'dang'	1	1	1
			'-cd'	'cdia'	[]	[]	1
			'-cr'	'crad'	[]	[]	1
			'-nu'	'uniq'	true	false	0
			'-pta'	'pmod'	0	1	0
			'-qh'	'qopt'	qopt	qopt	1
			'-wb'	'wbar'	false	true	0
%   graphics
			'-bc'	'bcir'	false	true	0
			'-nc'	'ncir'	false	true	0
			'-am'	'amap'	false	true	0
			'-cm'	'cmap'	[]	[]	1
			'-pc'	'pscol'	pscol	[]	1
			'-pp'	'pflg'	false	true	0
			'-g'	'gflg'	true	false	0
%   other
			'-t'	'tflg'	false	true	0
			'-v'	'vflg'	false	true	0
		};

% - set/check options
		p.opt=varargin;
	if	~mod
	for	i=1:size(opt,1)
		p.flg.(opt{i,2})=opt{i,3};
	end
	end

	if	nargin > 2
	for	i=1:size(opt,1)
		ix=find(strcmp(opt(i,1),varargin));
	if	~isempty(ix)
	if	~opt{i,5}
		p.flg.(opt{i,2})=opt{i,4};
	else
		ix=ix+1:ix+opt{i,5};
	if	ix(end) > length(varargin)
		p.flg.(opt{i,2})=opt{i,4};
	else
		p.flg.(opt{i,2})=varargin{ix};
	end
	end
	end
	end
	end

	if	p.flg.pmod
		p.pmod='search mode: torsion/angle';
	else
		p.pmod='search mode: angle';
	end
end
%--------------------------------------------------------------------------------
%--------------------------------------------------------------------------------
% ASLIB FUNCTIONS
%--------------------------------------------------------------------------------
function	p=ASLIB_mseg(p)

		ASLIB_aschk(p,1);
	if	~p.nd || isempty(p.dix) || ~p.dix
		return;
	end

		wh=0;
		rv=[100 80 60 40 20];
		txt=sprintf('processing edges:    %7d/%7d  (%5.1f%%)',...
			p.dix,p.nd,100*p.dix/p.nd);
	if	p.flg.wbar
		wh=waitbar(0,txt);
		set(wh,'name','ASLIB segmenting...');
		pause(0.01);
	end
		ASLIB_vdisp(p,txt);

		ti=clock;
	for	i=1:p.dix
		r=i/p.dix;
		rf=floor(100*r);
	if	wh
		waitbar(r,wh);
	end

		p=p.f.cfit(p,i);	% call <p>'s version!
		p=p.f.cchk(p);		% ...

	if	find(rf==rv)
		to=clock;
		ASLIB_vdisp(p,sprintf('      done edges:    %7d %7d%% %17.3fs',...
				i,rf,etime(to,ti)));
		rv(end)=[];
	end

	end
		to=clock;

	if	wh
		delete(wh);
	end

		ASLIB_vdisp(p,sprintf('      done edges:    %7d %26.3fs',...
				p.nseg,etime(to,ti)));
end
%-------------------------------------------------------------------------------
function	p=ASLIB_rseg(p)

		ASLIB_aschk(p,1);
	if	~p.nd || isempty(p.dix) || ~p.dix
		return;
	end

	if	~p.nshape
		return;
	end

		p.sshape=p.ashape;
		is=p.amod~=1;

	for	i=1:p.nshape
		iz=ismember(p.ashape{i},p.seg(is,:),'rows');
		p.sshape{i}(iz,:)=[];
	end
end
%--------------------------------------------------------------------------------
function	p=ASLIB_circ(p,xoff,yoff)

% - create a circle at offset xoff/yoff with radius p.r and resolution p.ang

		p.ang=mod(p.flg.dang,360);
		a=0:p.ang:360;
	if	a(end) < 360
		a=[a 360];
	end
		p.xcir=xoff+p.r*cosd(a);
		p.ycir=yoff+p.r*sind(a);
end
%--------------------------------------------------------------------------------
function	p=ASLIB_cfit(p,tix)

% - fit a circle with radius .r to two points .xp/.yp

% created:
%	us	11-Aug-1987
% modified:
%	us	12-Jul-2004
%	us	20-Jan-2005	/ TMW <aslib>

	if	nargin < 2
		return;
	end

		p.cflg=false;
		p.cmsg='';
		p.ix=p.dt(tix,:);
		p.xp=p.x(p.ix);
		p.yp=p.y(p.ix);
		p.cx=[];
		p.cy=[];

		dx=diff(p.xp);
		dy=diff(p.yp);
		p.cr=.5*sqrt(dx.^2+dy.^2);
	if	p.cr == 0
		p.cmsg='cannot fit a single point';
		return;
	end
	if	p.cr > p.r
		p.cmsg='radius too small';
		return;
	end
		p.cflg=true;
		xm=.5*sum(p.xp);
		ym=.5*sum(p.yp);
		r2=sqrt(p.r.^2-p.cr.^2);
		cr=2*p.cr;
		p.cx=[xm+r2*-dy/cr xm-r2*-dy/cr];
		p.cy=[ym+r2* dx/cr ym-r2* dx/cr];
end
%--------------------------------------------------------------------------------
function	p=ASLIB_cchk(p)

	if	~p.cflg
		return;
	end

% - remove current segment (severe FP problems!)
		xx=p.x;
		yy=p.y;
		xx(p.ix)=nan;
		yy(p.ix)=nan;

		ccnt=0;
	for	i=1:2
		aflg=0;
		bflg=0;
		cx=p.xcir+p.cx(i);
		cy=p.ycir+p.cy(i);
% - only check circle's proximity
		xt=find(xx>=p.cx(i)-p.r & xx<=p.cx(i)+p.r & ...
			yy>=p.cy(i)-p.r & yy<=p.cy(i)+p.r);
		rx=xx(xt);
		ry=yy(xt);
% - check against ML's <inpolygon> using
%   finite (!) circular polygon p.xcir/p.ycir based on p.ang [def: 1 deg]
	if p.flg.tflg
		ff=zeros(size(rx));
		gg=ff;
		[p.ip,p.op]=inpolygon(rx,ry,cx,cy);
	if	sum(p.ip) == 0				||...
		sum(p.op) > 1
		p.segp=[p.segp;p.ix];
		aflg=1;
		ff=p.ip;
		gg=p.op;
	end
	end

		rr=(rx-p.cx(i)).^2+(ry-p.cy(i)).^2;
		iz=(rr<=p.r2);
		p.ip=iz~=0;
		ir=(rr==p.r2);				% points on radius
		p.op=ir~=0;
	if	sum(p.ip) == 0				||...
		sum(p.op) > 1
		ccnt=ccnt+1;
	if	ccnt == 1
		p.nseg=p.nseg+1;
		p.cen=[p.cen;[p.cx(i) p.cy(i)]];
		p.seg=[p.seg;p.ix];
		p.amod=[p.amod;ccnt];
	elseif	ccnt == 2 && p.flg.bcir
		p.nseg=p.nseg+1;
		p.cen=[p.cen;[p.cx(i) p.cy(i)]];
		p.seg=[p.seg;p.ix];
		p.amod(end)=ccnt;
		p.amod=[p.amod;ccnt];
	else
		p.amod(end)=p.amod(end)+1;
	end
		bflg=1;
	end
	if	p.flg.tflg && (aflg~=bflg)
		disp(sprintf('mismatch> inpoly=%1d radius=%1d',aflg,bflg));
		line(cx,cy,'color',[0 0 0]);
		gdat(p);
		line(p.xp,p.yp);
		disp([ff,gg,p.ip,p.op]);
		keyboard
	end
	end

	if	p.flg.ncir
		p.cen=[];
	end
		p.dmod(p.ix,1)=p.dmod(p.ix,1)+ccnt;
%{
lh=line(xxo,yyo,'marker','o','markersize',12,'linestyle','none','markerfacecolor',[0,1,0]);
disp(sprintf('%5d ',[ccnt,xxo(:).',yyo(:).',p.dmod(p.ix,1).']));
shg
pause
delete(lh);
delete(ah);
%}
end
%--------------------------------------------------------------------------------
function	p=ASLIB_mcon(p)

% - find unique A shapes

		ASLIB_aschk(p,1);
	if	~p.nseg
		return;
	end

		wh=0;
		txt=sprintf('processing shapes:   %7d',p.nseg);
	if	p.flg.wbar
		cz=0;
		wh=waitbar(0,txt);
		set(wh,'name','ASLIB connecting...');
		pause(0.01);
	end
		ASLIB_vdisp(p,txt);

% - reset A shape tree
		p.nshape=0;
		p.xshape=zeros(p.nseg,1,'int32');
		p.lshape=[];
		p.ashape={};
% - re-index edge indices to obtain a min length vector
		z=reshape(p.seg.',1,[]);
		[zix,zix]=histc(z,ASLIB_asunique(z));	%#ok
		z=reshape(zix,fliplr(size(p.seg))).';
% - create empty templates only once
		zm=[max(zix) 1];
		zz=zeros(zm,'int32');
		zl=false(zm);

		ti=clock;
% - this is very fast despite the two <while>s!
	while	true

% - find kernel of new distinct A shape
% - note already used edges are marked by <nan>s
		zb=find(z(:,1)==z(:,1));
	if	isempty(zb)
% - no unmarked edge found
		break;
	end

% - set current kernel
		ix=zz;
		ix(z(zb(1),:))=1;
		ixo=ix;
		ir=zl;
		ir(zb(1))=true;

	while	true

% - check whether nodes of remaining (unmarked) edges
%   belong to current kernel
	for	i=zb(1:end).'
		iz=ix(z(i,:));
% - grow kernel and mark edge-index vec
	if	any(iz)
		ix(z(i,:))=1;
		ir(i)=true;
	end
	end
	if	isequal(ix,ixo)
% - current kernel has no new edges
		break;
	end
		ixo=ix;
	end
% - mark all edges of current kernel
		z(ir,:)=nan;
% - save new distinct (connected) A shape
		irx=find(ir);
		p.nshape=p.nshape+1;
		p.ashape{p.nshape,1}=p.seg(irx,:);
		p.lshape(p.nshape)=size(p.ashape{p.nshape},1);
		p.xshape(irx)=p.nshape;

	if	wh
		cz=cz+length(irx);
		waitbar(cz/p.nseg,wh);
	end

	end

		p=ASLIB_rseg(p);			% remove edges > 2 nodes

		to=clock;

	if	wh
		delete(wh);
	end
		ASLIB_vdisp(p,sprintf('      done shapes:   %7d %26.3fs',...
				p.nshape,etime(to,ti)));

end
%--------------------------------------------------------------------------------
function	p=ASLIB_mpat(p)

			ASLIB_aschk(p,1);
		if	~p.nshape
			return;
		end

			icm={
				'  open'
				'closed'
			};

			wh=0;
			txt=sprintf('processing patches:  %7d',p.nshape);
		if	p.flg.wbar
			wh=waitbar(0,txt);
			set(wh,'name','ASLIB patching...');
			pause(0.01);
		end
			ASLIB_vdisp(p,txt);

			[ixp,ixp]=sort(p.lshape,'descend');	%#ok
			p.xpatch=ixp;

			nr=0;
			ti=clock;
	for	nx=1:p.nshape
			ns=ixp(nx);
			kl=p.lshape(ns);
		if	kl < 2
			break;
		end
			k=p.ashape{ns};
			am=p.amod(p.xshape==ns);
			al=am==2;

		if	sum(al) ~= kl			&&...
			~all(al==0)
			ispatch=1;
			k(al,:)=[];
		else
			ispatch=0;
		end

	if	~isempty(k)
			k=k(:);
			kk=ASLIB_asunique(k);
			[b,b]=histc(k,kk);		%#ok

	if	length(b) > 1
			m=reshape(b,[],2);
			m=sortrows(m);
			mr=size(m,1);
			mc=max(m(:));
			s=sparse(1:mr,m(:,1),1,mr,mc);
			s=s+sparse(1:mr,m(:,2),1,mr,mc);

% US	12apr10
	if	~ispatch				&&...
		s(1,1) && s(mr,mc)
	if	mr == mc
			ispatch=2;			% shape
	else
			ispatch=1;			% subset
	end
	end

			kn=(1:mr).';
			kz=kn;
			ac=zeros(mc,1);
			kc=ac;
			scc=ac;
			sx=0;
			sc=1;

	while	true
			ix=0;
			a=kn(1);

	while	true
			ix=ix+1;
			ao=a;
			b=find(s(a,:)==1);
		if	~isempty(b)
		if	length(b) == 1
			s(a,b)=nan;
		else
			b=b(1);
		end
			aa=find(s(:,b)==1);
		if	isempty(aa)
			aa=a;
		end
		if	~isempty(aa)
			a=aa(1);
			sx=sx+1;
			scc(sc)=scc(sc)+1;
			kc(sx,1)=sc;
			ac(sx)=kk(b);
		if length(aa) > 1 && scc(sc) > 2
			a=ASLIB_cpat(p,s,sx,aa,ac,b,kk);
		end
			s(a,b)=nan;
			kz(a)=0;
		else
			kz(ao)=0;
		end
		if	isempty(a)
			kn=kz(find(kz));		%#ok
			sc=sc+1;
		if	isempty(kn)
			break;
		end
			a=kn(1);
		if	isempty(find(kc==sc-1,1))
			sc=sc-1;
		end
		end
		else	% isempty(b)
			kn=kz(find(kz));		%#ok
			sc=sc+1;
		if	isempty(kn)
			break;
		end
			a=kn(1);
		if	isempty(find(kc==sc-1,1))
			sc=sc-1;
		end
		end	% ~isempty(b)

	end	% true 1

			kn=kz(find(kz));		%#ok
			sc=sc+1;
		if	isempty(kn)
			break;
		end
		if	isempty(find(kc==sc-1,1))
			sc=sc-1;
		end

	end	% true 2

	if	ispatch
			nc=0;
			nr=nr+1;
		for	nns=1:max(kc)
			nc=nc+1;
			kix=find(kc==nns);
		if	ac(kix(1)) ~= ac(kix(end))	% should not happen...
			kix=[kix;kix(1)];		%#ok
		end
			p.apatch{nr,nc}=ac(kix);
			p.mpatch(nr,nc)=ispatch;
		end
			[lx,lx]=sort(cellfun('length',p.apatch(nr,:)),'descend');	%#ok
			p.apatch(nr,:)=p.apatch(nr,lx);
			p.mpatch(nr,:)=p.mpatch(nr,lx);
		
			txt=sprintf('     shape  %s:  %7d %7d',icm{ispatch},nx,nc);
			ASLIB_vdisp(p,txt);
	end	% patches: subshape/closed shape

	end	% length(b) > 1
	end	% ~isempty(kk)

		if	wh
			waitbar(nx/p.nshape,wh);
		end

	end	% nx=1:p.nshape
			to=clock;

			p.lpatch=int32(cellfun('length',p.apatch));
			p.npatch=sum(sum(p.lpatch>0));
			p.spatch=size(p.apatch);

		if	wh
			delete(wh);
		end
			ASLIB_vdisp(p,sprintf('      done patches:  %7d %26.3fs',...
					p.npatch,etime(to,ti)));

end
%--------------------------------------------------------------------------------
function	a=ASLIB_cpat(p,s,sx,aa,ac,b,kk)

% - find next edge at a n>1 degree nodes using
%   direction of torsion
%   closest angle

% - compute torsion of preceding two edges (cross product)
		ia=ac(sx-2:sx);
		x=p.x(ia(2:end))-p.x(ia(1:end-1));
		y=p.y(ia(2:end))-p.y(ia(1:end-1));
		vs=[x y];
		cp1=ASLIB_ascp(vs(1:end-1,:),vs(2:end,:));

% - compute torsion of all edges from current node (cross product)
		[ig,izz]=find(s(aa,:));
		izx=find(izz~=b);
		ig=ig(izx);
		iz=izz(izx);
		iz=kk(iz).';

		iza=ac(sx)*ones(size(iz));
		x=p.x(iz)-p.x(iza);
		y=p.y(iz)-p.y(iza);
		v=[x y];
		u=ones(size(v,1),1)*vs(end,:);
		cp2=ASLIB_ascp(u,v);

	if	~any(cp1) && ~any(cp2)
		a=aa(1);
		return;
	end

% - compute angle between current edge and all edges from current node (dot product)
		vv=sqrt(sum(v.^2,2));
		vu=sqrt(sum(u.^2,2));
		ang=acosd(sum(u.*v,2)./(vv.*vu));

% - find next edge
		as=sign(cp1)==sign(cp2);
		ax=as & as.*ang==max(as.*ang);
		ax=ig(ax);

	if	~p.flg.pmod
		ax=[];
	end
%   using direction of torsion and closest angle
	if	~isempty(ax)
		a=aa(ax);
	else
%   using closest angle only
		ang=abs(ang);
		ax=ang==max(ang);
		ax=ig(ax);
		a=aa(ax);
	end
end
%--------------------------------------------------------------------------------
%--------------------------------------------------------------------------------
% ASLIB UTILITIES
%--------------------------------------------------------------------------------
function	p=ASLIB_asdelaunay(p)

% - compute delaunay tessellation and length/2 of its edges
%   only fit circles to edges with lengths/2 <= radius

		p.dt=int32(delaunay(p.x,p.y));%,p.flg.qopt
	if	isempty(p.dt)
		error('ASLIB> delaunay tessellation failed for given data');
	end
		p.dt=sort(p.dt,2);
		p.dt=[
			p.dt(:,1) p.dt(:,2)
			p.dt(:,1) p.dt(:,3)
			p.dt(:,2) p.dt(:,3)
		];
		p.dt=ASLIB_asunique(p.dt);
		p.nd=size(p.dt,1);
		p.dl=(	(p.x(p.dt(:,1))-p.x(p.dt(:,2))).^2+...
			(p.y(p.dt(:,1))-p.y(p.dt(:,2))).^2	);
		p.dl=.5*sqrt(p.dl);
		[p.dl,p.dix]=sort(p.dl);
		p.dt=p.dt(p.dix,:);
		p.drng=[min(p.dl) max(p.dl)];
		p.dmod=zeros(size(p.x));
		p.dix=find(p.dl<=p.r,1,'last');
	if	isempty(p.dix)
		p.dix=0;
	end
end
%--------------------------------------------------------------------------------
function	m=ASLIB_asunique(m)
% - a poor man's <unique> replacement

	if	isempty(m)
		return;
	end

		ms=size(m,1);
	if	ms == 1
		m=m(:);
	end
		m=sortrows(m);
		iu=[true;any(diff(m,1),2)];
		m=m(iu,:);
	if	ms == 1
		m=m.';
	end
end
%--------------------------------------------------------------------------------
function	cp=ASLIB_ascp(u,v)
% - a poor man's <2d cross product> replacement

		cp=u(:,1).*v(:,2)-u(:,2).*v(:,1);
end
%-------------------------------------------------------------------------------
function	r=ASLIB_arange(v)

		r=max(v)-min(v);
end
%--------------------------------------------------------------------------------
function	ASLIB_vdisp(p,txt)
% - display text if verbose mode [-v]

	if	p.flg.vflg
		disp(txt);
	end
end
%--------------------------------------------------------------------------------
%--------------------------------------------------------------------------------
% ASLIB GRAPHICS FUNCTIONS
%--------------------------------------------------------------------------------
% - graphics utilities
%--------------------------------------------------------------------------------
function	[p,r]=ASLIB_set_graph(p,n,tag,varargin)

		ASLIB_aschk(p,1);
		r=true;
	if	numel(n) <= 0 || all(n(:) <=0)
		r=false;
	elseif	nargin > 3
	if	isnumeric(varargin{1})
		p=ASLIB_clr_graph(p,tag);
		r=false;
	else
		p=ASLIB_asopt(p,1,varargin{:});
	end
	end
		p=ASLIB_set_axis(p);
end
%--------------------------------------------------------------------------------
function	p=ASLIB_clr_graph(p,tag)

		lh=findall(gcf,'tag',tag);
		delete(lh);
		p.h.(tag)={};
end
%--------------------------------------------------------------------------------
function	p=ASLIB_set_axis(p)

	if	~strcmp(get(gca,'tag'),p.magic);
		axis equal;
		xrng=[min(p.x) max(p.x)];
		xdif=diff(xrng);
		yrng=[min(p.y) max(p.y)];
		r=min(p.r,p.drng(2)/2);
	if	r < .025*xdif
		r=.025*xdif;
	end
		r=2*r*[-1 1];
		set(gca,'xlim',r+xrng);
		set(gca,'ylim',r+yrng);
		set(gca,'tag',p.magic);
	end
end
%--------------------------------------------------------------------------------
function	p=ASLIB_get_colormap(p,mod)

	switch	mod

% - A shapes
	case	1
	if	isempty(p.flg.cmap)
% - create a simple red/blue only colormap
		cmapr=linspace(1,0,p.nshape).';
		cmapg=zeros(p.nshape,1);
		cmapb=linspace(0,1,p.nshape).';
		p.flg.cmap=[cmapr cmapg cmapb];
	elseif	ischar(p.flg.cmap)
		cmap=str2func(p.flg.cmap);
		p.flg.cmap=cmap(p.nshape);
	end
		p.flg.csiz=size(p.flg.cmap,1);
		p.flg.cmix=rem((1:p.nshape)-1,p.flg.csiz)+1;
		colormap(p.flg.cmap(1:min(p.flg.csiz,p.nshape),:));

% - A patches
	case	2
	if	~p.flg.amap
		cn1=max(1,floor(p.npatch/2));
		cnr=[linspace(1,0,cn1).';linspace(1,0,cn1).'];
		cng=[linspace(0,1,cn1).';linspace(1,0,cn1).'];
		cnb=[zeros(1,cn1).';linspace(0,1,cn1).'];
		cmap=[cnr cng cnb];
	if	size(cmap,1) < p.npatch
		cn2=ceil(p.npatch/2);
		cmap=[cmap(1:cn1,:);[1 .8 1];cmap(cn2:end,:)];
	elseif	size(cmap,1) > p.npatch
		cmap=cmap(1:cn1,:);
	end
		p.flg.acmap=cmap;
	else
		p.flg.acmap=p.flg.cmap;
	end

	end
end
%--------------------------------------------------------------------------------
% - user visible functions
%--------------------------------------------------------------------------------
function	p=ASLIB_gall(p,varargin)

		ASLIB_aschk(p,1);
% - plot all resulting elements
		p=ASLIB_gdat(p,varargin{:});
		p=ASLIB_gcir(p,varargin{:});
		p=ASLIB_gcon(p,varargin{:});
		p=ASLIB_gseg(p,varargin{:});

		set(gcf,'tag',p.magic);
		drawnow;
		shg;

	if	~nargout
		clear	p;
	end
end
%--------------------------------------------------------------------------------
function	p=ASLIB_gdat(p,varargin)

% - plot data

		tag=[p.h.pref,'dat'];
		[p,r]=ASLIB_set_graph(p,p.n,tag,varargin{:});
	if	~r
	if	~nargout
		clear	p;
	end
		return;
	end

		p.h.(tag){1,1}=...
		line(	p.x,p.y,...
			'marker','square',...
			'markersize',4,...
			'markerfacecolor',.8*[1 1 0],...
			'linestyle','none',...
			'color',[0 0 0],...
			'tag',tag).';

	if	~nargout
		clear	p;
	end
end
%--------------------------------------------------------------------------------
function	p=ASLIB_gcir(p,varargin)

% - plot A circles

		tag=[p.h.pref,'cir'];
		[p,r]=ASLIB_set_graph(p,~p.flg.ncir*length(p.cen),tag,varargin{:});
	if	~r
	if	~nargout
		clear	p;
	end
		return;
	end

		cz=-1*ones(size(p.xcir));
	for	i=1:size(p.cen,1)
		cx=p.xcir+p.cen(i,1);
		cy=p.ycir+p.cen(i,2);
	if	p.amod(i) == 2 && p.flg.bcir
		col=.50*[1 1 1];
	else
		col=.85*[1 1 1];
	end
		p.h.(tag){i,1}=...
		line(	cx,cy,cz,...
			'color',col,...
			'tag',tag).';
	end

	if	~nargout
		clear	p;
	end
end
%--------------------------------------------------------------------------------
function	p=ASLIB_gseg(p,varargin)

% - plot A edges

		tagr=[p.h.pref,'seg'];
		tagp=[p.h.pref,'segp'];
		tagm=[p.h.pref,'segm'];
		p    =ASLIB_set_graph(p,p.segp,tagp,varargin{:});
		p    =ASLIB_set_graph(p,p.seg, tagm,varargin{:});
		[p,r]=ASLIB_set_graph(p,p.seg ,tagr,varargin{:});
	if	~r
	if	~nargout
		clear	p;
	end
		return;
	end

	if	p.nshape
		p=ASLIB_get_colormap(p,1);
	for	i=1:p.nshape
		p.h.(tagr){i,1}=...
		line(	p.x(p.sshape{i}).',...
			p.y(p.sshape{i}).',...
			-.75*ones(size(p.x(p.sshape{i}).')),...
			'linewidth',1,...
			'color',p.flg.cmap(p.flg.cmix(i),:),...
			'tag',tagr).';
	end
	else
		p.h.(tagr){1,1}=...
		line(	p.x(p.seg).',...
			p.y(p.seg).',...
			'linewidth',1,...
			'color',[.5 .5 0],...
			'tag',tagr).';
	end
	if	~isempty(p.segp)
		p.h.(tagp){1,1}=...
		line(	p.x(p.segp).',...
			p.y(p.segp).',...
			'linewidth',4,...
			'hittest','off',...
			'color',[1 1 0],...
			'tag',tagp).';
	end

% multiple A edges
		ix=p.amod==2;

		p.h.(tagm){1,1}=...
		line(	p.x(p.seg(ix,:)).',...
			p.y(p.seg(ix,:)).',...
			-.5*ones(size(p.x(p.seg(ix,:)))).',...
			'linewidth',2,...
			'hittest','off',...
			'color',[0 0 0],...
			'tag',tagm);

	if	~nargout
		clear	p;
	end
end
%-------------------------------------------------------------------------------
function	p=ASLIB_gcon(p,varargin)

% - plot A nodes

		tag=[p.h.pref,'con'];
		[p,r]=ASLIB_set_graph(p,p.nshape,tag,varargin{:});
	if	~r
	if	~nargout
		clear	p;
	end
		return;
	end

		p=ASLIB_get_colormap(p,1);
	for	i=1:p.nshape
		mfc=p.flg.cmap(p.flg.cmix(i),:);
	if	1 || isequal(mfc,[1 1 1]);
		mfc=[0 0 0];
	end
		p.h.(tag){i,1}=...
		line(...
			p.x(p.ashape{i,:}),...
			p.y(p.ashape{i,:}),...
			ones(size(p.x(p.ashape{i,:}))),...
			'marker','square',...
			'markersize',4,...
			'markerfacecolor',p.flg.cmap(p.flg.cmix(i),:),...
			'linestyle','none',...
			'color',mfc,...
			'tag',tag).';
	end

		cbar=p.h.([p.h.pref,'bar']){1};
	if	ishandle(cbar)
		delete(cbar);
	end
		cbar=p.f.cbar();
		set(cbar,...
			'xtick',1.5:p.n+.5,...
			'xticklabel',1:p.n,...
			'ticklength',[0 0],...
			'tag',tag);
		p.h.([p.h.pref,'bar']){1}=cbar;

	if	~nargout
		clear	p;
	end
end
%--------------------------------------------------------------------------------
function	p=ASLIB_gmod(p,varargin)

% - plot A modes

		tag=[p.h.pref,'legend'];
		[p,r]=ASLIB_set_graph(p,p.nshape,tag,varargin{:});
	if	~r
	if	~nargout
		clear	p;
	end
		return;
	end

		ms=5;		% marker: size
		lfs=8;		% legend: font size
		ce=[0,0,0];
		dnod={
			'node 0'	0	0	[1,1,0]
			'node 1'	1	1	.80*[0,1,0]
			'node 2'	2	2	.90*[0,1,0]
			'node 3'	3	3	1.0*[0,1,0]
			'node 4'	4	4	[1,0,0]
			'node >'	6	inf	[0,0,0]
		};
		anod={
			'polygon'	1	1	[0,1,0]
			'line'		2	2	[1,0,0]
		};
		cnod=[
			dnod
			anod
		];

		nd=size(dnod,1);
		na=size(anod,1);

		yr=.04*ASLIB_arange(get(gca,'xlim'));	%#ok: text()
		lh=nan(nd+na,1);
		nc=0;
% nodes
	for	i=1:nd
		nc=nc+1;
		cm=dnod{i,4};
		ix=p.dmod>=dnod{i,2}&p.dmod<=dnod{i,3};
		xx=p.x(ix);
		yy=p.y(ix);
		zz=-1*ones(size(p.x(ix)));
		tlh=line(xx,yy,zz,...
			'marker','s',...
			'markersize',ms,...
			'markeredgecolor',ce,...
			'markerfacecolor',cm,...
			'linestyle','none',...
			'color',cm,...
			'tag',tag);
%{
		text(xx,yy+yr,zz,...
			num2cell(p.dmod(ix)),...
			'horizontalalignment','center');
%}
	if	~isempty(tlh)
		lh(nc,1)=tlh(1,1);
	end
	end

% edges
	for	i=1:na
		nc=nc+1;
		cm=anod{i,4};
		ix=p.amod==anod{i,2};
		xx=p.x(p.seg(ix,:)).';
		yy=p.y(p.seg(ix,:)).';
		zz=-2*ones(size(xx));
		tlh=line(xx,yy,zz,...
			'linewidth',4,...
			'color',cm,...
			'tag',tag);
	if	~isempty(tlh)
		lh(nc,1)=tlh(1,1);
	end
	end
		isnod=ishandle(lh);
		p.h.(tag)=legend(lh(isnod),cnod(isnod),...
			'fontsize',lfs,...
			'location','best',...
			'tag',tag);

	if	~nargout
		clear	p;
	end
		shg;
end
%--------------------------------------------------------------------------------
function	p=ASLIB_gpat(p,varargin)

% - plot A patches

		tag=[p.h.pref,'pat'];
		[p,r]=ASLIB_set_graph(p,p.npatch,tag,varargin{:});
	if	~r
	if	~nargout
		clear	p;
	end
		return;
	end

		p=p.f.gseg(p);
		p=p.f.gcon(p);
		th=findall(gca);
		tl=get(th,'tag');
		ix=strncmp(p.h.pref,tl,3);
		set(th(ix),'hittest','off');
		cbar=p.h.([p.h.pref,'bar']){1};
	if	ishandle(cbar)
		delete(cbar);
	end

		oax=gca;
		cbar=p.f.cbar();
		p.h.([p.h.pref,'bar']){1}=cbar;
		axes(oax);				%#ok

		php=[];					% fig:	alpha patch
		phh=[];					% fig:	alpha shape hull
		phc=[];					% cb:	shape
		[nr,nc]=size(p.apatch);
	if	p.npatch
		p=ASLIB_get_colormap(p,2);
		ixp=p.xpatch;
		bmap=zeros(p.npatch,3);
		txt=cell(p.npatch,1);
		cix=0;
		zv=linspace(-1.5,-1,p.npatch);
	for	i=1:nr
	for	j=1:nc
		dix=p.apatch{i,j};
	if	~isempty(dix)
		cix=cix+1;
	if	~p.flg.amap
		col=p.flg.acmap(cix,:);
	else
		col=p.flg.cmap(ixp(i),:);
	end	
		bmap(cix,:)=col;
		vx=p.x(dix);
		vy=p.y(dix);
		vz=zv(cix)*ones(size(vx));
		ph=patch(...
			vx,vy,vz,col,...
			'edgecolor','none',...
			'tag',sprintf('%-1d',i),...
			'userdata',{0,col,0,i,cix});
		php=[php;ph];				%#ok
		set(ph,...
			'buttondownfcn',...
			{@ASLIB_gpat_cb,p,oax,ph,2,php});
		pause(.01);
		txt{cix}=sprintf('%-1d\n%-1d\n%-1d',i,j,length(dix)-1);
	end
	end
		k=p.ashape{ixp(i)};
		kx=convhull(p.x(k),p.y(k));
		k=k(kx);
		phh=[phh;patch(...
			p.x(k),p.y(k),-2*ones(size(k)),[1 .95 .95],...
			'edgecolor',[1 .75 .75],...
			'userdata',{0,i,0,i,[1 .95 .95]},...
			'tag',tag)];			%#ok
	end

		colormap(bmap);
		cbar=p.f.cbar();
		p.h.([p.h.pref,'bar']){1}=cbar;
		xtick=((1:p.npatch)-.5)./p.npatch;
		set(cbar,...
			'xtick',xtick,...
			'xticklabel',[],...
			'ytick',[-.5 1.5],...
			'yticklabel',{'patch';'shape'},...
			'ticklength',[0 0],...
			'tag',tag);
		axes(cbar);				%#ok
		text(xtick,-3.0*ones(size(xtick)),txt,...
			'horizontalalignment','center',...
			'fontsize',7);

		ylim=get(cbar,'ylim');
		ybot=ylim(1)+ASLIB_arange(ylim)/2;
		ytop=ylim(2);
		lx=linspace(0,1,p.npatch+1);
		nw=0;
		xo=0;
		phc=nan(nr,1);
	for	i=1:nr
		col=p.flg.cmap(p.flg.cmix(ixp(i)),:);
		nw=nw+find(p.lpatch(i,:),1,'last');
		x=lx(nw+1);
		phc(i)=patch(...
			[xo x x xo],[ybot ybot ytop ytop],col,...
			'edgecolor','none',...
			'userdata',{0,i,0,i,col});
		set(phc(i),...				% keep this logic!
			'buttondownfcn',...
			{@ASLIB_gpat_cb,p,oax,phc(i),1});
		set(phh(i),...
			'buttondownfcn',...
			{@ASLIB_gpat_cb,p,oax,phc(i),1});
		xo=x;
	end
		set(cbar,...
			'buttondownfcn',...
			{@ASLIB_gpat_cb,p,oax,php,0})
		lh=line([lx;lx],ylim);
		lh=[lh;line([0 1],[.5 .5])];
		set(lh,...
			'hittest','off',...
			'color',[0 0 0]);
		axes(oax);					%#ok
	end
		title(cbar,p.pmod);

% undocumented
		p.h.([p.h.pref,'axis'])=oax;
		p.h.([p.h.pref,'patch'])=php;
		p.h.([p.h.pref,'hull'])=phh;
		p.h.([p.h.pref,'cbshape'])=phc;

	if	~nargout
		clear	p;
	end
end
%-------------------------------------------------------------------------------
function	p=ASLIB_mark(p,varargin)

	if	nargin < 2
		return;
	end

		ASLIB_aschk(p,1);
	if	~p.nd || isempty(p.dix) || ~p.dix
		return;
	end
	if	~isfield(p.h,'AS_axis')			||...
		~ishandle(p.h.AS_axis)			||...
		~isfield(p.h,'AS_bar')			||...
		~ishandle(p.h.AS_bar{1})
		p=p.f.gpat(p);
	end

		narg=nargin-1;
		[ns,np]=size(p.lpatch);
		pn=zeros(size(p.lpatch.'));
		pn(p.lpatch.'~=0)=1:p.npatch;
		pn=pn.';

	for	i=1:narg
		carg=varargin{i};
	if	isnumeric(carg)
	switch	numel(carg)
	case	1
% shape
	if	carg > 0				&&...
		carg <= ns
		ASLIB_gpat_cb([],[],p,p.h.AS_axis,p.h.AS_cbshape,11,carg)
	end
	otherwise
% patch
	if	carg(1) > 0				&&...
		carg(1) <= ns				&&...
		carg(2) > 0				&&...
		carg(2) <= np
		carg=pn(carg(1),carg(2));
		ASLIB_gpat_cb([],[],p,p.h.AS_axis,p.h.AS_patch,10,carg)
	end
	end
	end
	end

	if	~nargout
		clear	p;
	end
end
%--------------------------------------------------------------------------------
function	ASLIB_gpat_cb(h,e,varargin)			%#ok

% - callback routine for GPAT
%   mod
%	0:	bar patch
%	1:	bar shape | hull
%	2:	patch

		p=varargin{1};
		cn=p.npatch;
		nax=p.h.([p.h.pref,'bar']){1};		% AS_bar
		oax=varargin{2};			% AS_axis
		phv=varargin{3};			% AS_patch
		mod=varargin{4};			% mod

	if	~ishandle(nax) || ~ishandle(oax)
		return;
	end

% - user selected
%   shape on axis: mimick option <patch on colorbar>

	switch	mod
	case	2					% A PATCH
		ud=get(phv,'userdata');
		ap=ud{5};
		phv=varargin{5};
	case	10					% .mark A SHAPE
		mod=0;
		ap=varargin{5};
	case	11					% .mark A PATCH
		mod=1;
		ap=varargin{5};
		phv=phv(ap);
	otherwise
		ap=get(nax,'currentpoint');
		ap=fix(ap(1,1)*cn)+1;
	end

%   shape on colorbar
	if	mod == 1
		ud=get(phv,'userdata');
		ph=findall(oax,'tag',sprintf('%-1d',ud{2}));
	if	ud{1} == 0
		set(ph,...
			'facecolor',p.flg.pscol);
		set(phv,...
			'facecolor',p.flg.pscol,...
			'userdata',{1,ud{2},ph,ud{4},ud{5}});
	else
		set(phv,...
			'facecolor',ud{5},...
			'userdata',{0,ud{2},ph,ud{4},ud{5}});
	for	i=1:size(ph,1)
		ud=get(ph(i),'userdata');
		set(ph(i),...
			'facecolor',ud{2});
	end
	end

%   patch on colorbar
	else
		phv=phv(ap);
		ud=get(phv,'userdata');
	if	ud{1} == 0
		xt=get(nax,'xtick');
		yt=get(nax,'ytick');
		th=text(...
			xt(ap),yt(2),'+',...
			'parent',nax,...
			'fontsize',6,...
			'horizontalalignment','center',...
			'verticalalignment','top',...
			'backgroundcolor',[1 1 1],...
			'hittest','off',...
			'color',[0 0 0]);
		axes(oax);				%#ok
		x=get(phv,'xdata');
		y=get(phv,'ydata');
		lh=line(...
			[min(x) max(x) max(x) min(x) min(x)],...
			[min(y) min(y) max(y) max(y) min(y)],...
			'linewidth',3,...
			'hittest','off',...
			'color',[0 0 1]);
		set(phv,...
			'facecolor',p.flg.pscol,...
			'userdata',{1,ud{2},[lh,th],ud{4},ud{5}});
	else
		delete(ud{3});
		set(phv,...
			'facecolor',ud{2},...
			'userdata',{0,ud{2},0,ud{4},ud{5}});
	end
	end
		axes(oax);				%#ok
end
%--------------------------------------------------------------------------------
% - COLORBARV6
%+SSC_INSERT_BEG   20-Jul-2008/06:22:47   f:/usr/matlab/tmp/as/cb6.m
function h=ASLIB_cb6(arg1, arg2, arg3)
narg = nargin;
GCF = gcf;
GCA = gca;
if narg<2
	haxes = gca;
	hfig = gcf;
	if narg<1
    	loc = 'vert'; % Default mode when called without arguments.
	else
		% Peer must be followed by a valid axes handle.
		if strcmp(arg1,'peer')
			error('Parameter ''peer'' must be followed by an axes handle.');
		end
		loc = arg1;
	end
elseif narg == 2
	% This is the case ONLY when peer and a handle is passed.
	if strcmp(arg1,'peer')
		if ishandle(arg2) && strcmp(get(arg2, 'type'), 'axes')
			haxes = arg2;
			hfig = get(haxes,'parent');
			loc = 'vert';
			narg = 0;
		else
			% If second arg is not a valid axes handle
			error('Second argument must be a scalar axes handle.');
		end
	else
		error('Unknown command option.');
	end
else
	% For three arguments the first must be the mode or a axes handle, 
	% second must be the string 'peer' and third must be the peer axes handle.
	loc = arg1;
	if strcmp(arg2,'peer')
		if ishandle(arg3) && strcmp(get(arg3, 'type'), 'axes')
			haxes = arg3;
			hfig = get(haxes,'parent');
			narg = 1;
		else
			error('Third argument must be a scalar axes handle.');
		end
	else
		error('Unknown command option.');
	end
end
if narg==1 && strcmp(loc,'delete')
    ax = gcbo;
    % 
    % If called from ColorbarDeleteProxy, delete the colorbar axes
    %
    if strcmp(get(ax,'tag'),'ColorbarDeleteProxy')
        cbo = ax;
        ax = get(cbo,'userdata');
        if ishandle(ax)
            ud = get(ax,'userdata');
            
            % Do a sanity check before deleting colorbar
            if isfield(ud,'ColorbarDeleteProxy') && ...
                    isequal(ud.ColorbarDeleteProxy,cbo) && ...
                    ishandle(ax)
                try					%#ok
            	    delete(ax);
		catch					%#ok
            	end
            end
        end
    else
        %
        % If called from the colorbar image resize the original axes
        %
        if strcmp(get(ax,'tag'),'CB6_TMW_COLORBAR')
            ax=get(ax,'parent');
        end
       
        ud = get(ax,'userdata');
        if isfield(ud,'PlotHandle') && ...
                ishandle(ud.PlotHandle) && ...
                isfield(ud,'origPos') && ...
                ~isempty(ud.origPos)
            
            % Get position and orientation of colorbar being deleted
            delpos = get(ax,'Position');
            if delpos(3)<delpos(4)
                delloc = 'vert';
            else
                delloc = 'horiz';
            end
            
            % Search figure for existing colorbars
            % If one is found with the same plothandle but that is not
            % the same colorbar as the one being deleted
            % Get its position and orientation
            otherloc = '';
            otherpos = [];
            othercbar = [];
            phch = get(findall(hfig,'type','image','tag','CB6_TMW_COLORBAR'),{'parent'});
            for i=1:length(phch)
                phud = get(phch{i},'userdata');
                if isfield(ud,'PlotHandle') && isfield(phud,'PlotHandle')
                    if isequal(ud.PlotHandle,phud.PlotHandle)
                        if ~isequal(phch{i},ax)
                            othercbar = phch{i};
                            otherpos = get(phch{i},'Position');
                            if otherpos(3)<otherpos(4)
                                otherloc = 'vert';
                            else
                                otherloc = 'horiz';
                            end
                            break;
                        end
                    end
                end
            end
            
            
            % get the current plothandle units
            units = get(ud.PlotHandle,'units');
            % set plothandle units to normalized
            set(ud.PlotHandle,'units','normalized');
            % get current plothandle position
            phpos = get(ud.PlotHandle,'position');
            
            % if the colorbar being deleted is vertical
            % set the plothandle axis width to the original Pos
            % width of the colorbar being deleted
            % if there is another (horizontal) colorbar
            % do the same to that
            if strncmp(delloc,'vert',1) 
                phpos(3) = ud.origPos(3);
                set(ud.PlotHandle,'position',phpos);
                if strncmp(otherloc,'horiz',1)
                    otherpos(3) = ud.origPos(3);
                    set(othercbar,'position',otherpos);
                end
                
            % elseif the colorbar being deleted is horizontal
            % set the plothandle y and height to the original Pos
            % y and height of the colorbar being deleted.
            % if there is another (vertical) colorbar
            % do the same to that
            elseif strncmp(delloc,'horiz',1)
                phpos(4) = ud.origPos(4);
                phpos(2) = ud.origPos(2);
                set(ud.PlotHandle,'position',phpos);
                if strncmp(otherloc,'vert',1)
                    otherpos(4) = ud.origPos(4);
                    otherpos(2) = ud.origPos(2);
                    set(othercbar,'position',otherpos);
                end
                
            end
            
            % restore the plothandle units
            set(ud.PlotHandle,'units',units);
            
            
        end
        
        if isfield(ud,'ColorbarDeleteProxy') && ishandle(ud.ColorbarDeleteProxy)
            try
                delete(ud.ColorbarDeleteProxy)
	    catch					%#ok
            end
        end
    end
    % before going, be sure to reset current figure and axes
    if ishandle(GCF) && ~strcmpi(get(GCF,'beingdeleted'),'on')
        set(0,'currentfigure',GCF);
    end
    if ishandle(GCA) && ~strcmpi(get(GCA,'beingdeleted'),'on')
        set(gcf,'currentaxes',GCA);
    end
    return
end
ax = [];
cbarinaxis=0;
if narg==1
    if ishandle(loc)
        ax = loc;
        ud = get(ax,'userdata');
        if isfield(ud,'ColorbarDeleteProxy')
            error('Colorbar cannot be added to another colorbar.')
        end
        if ~strcmp(get(ax,'type'),'axes')
            error('Requires axes handle.');
        end
        
        cbarinaxis=1;
        units = get(ax,'units');
        set(ax,'units','pixels');
        rect = get(ax,'position');
        set(ax,'units',units);
        if rect(3) > rect(4)
            loc = 'horiz';
        else
            loc = 'vert';
        end
    end
end
h = haxes;
tagstr = get(h,'tag');
if strcmpi('Legend',tagstr) || strcmpi('Colorbar',tagstr)
    ud = get(h,'userdata');
    if isfield(ud,'PlotHandle')
        h = ud.PlotHandle;
    else
        % If handle is a dying or mutant colorbar or legend
        % do nothing.
        % but before going, be sure to reset current figure and axes
        set(0,'currentfigure',GCF);
        set(gcf,'currentaxes',GCA);
        return;
    end
end
ch = get(ASLIB_cb6_gcda(hfig,h),'children');
hasimage = 0; t = [];					%#ok
cdatamapping = 'direct';
for i=1:length(ch),
    typ = get(ch(i),'type');
    if strcmp(typ,'image'),
        hasimage = 1;
        cdatamapping = get(ch(i), 'CDataMapping');
    elseif strcmp(typ,'surface') && ...
            strcmp(get(ch(i),'FaceColor'),'texturemap') % Texturemapped surf
        hasimage = 2;
        cdatamapping = get(ch(i), 'CDataMapping');
    elseif strcmp(typ,'patch') || strcmp(typ,'surface')
        cdatamapping = get(ch(i), 'CDataMapping');
    end
end
if ( strcmp(cdatamapping, 'scaled') )
  % Treat images and surfaces alike if cdatamapping == 'scaled'
  t = caxis(h);
  d = (t(2) - t(1))/size(colormap(h),1);
  t = [t(1)+d/2  t(2)-d/2];
else
    if hasimage,
        t = [1, size(colormap(h),1)]; 
    else
        t = [1.5  size(colormap(h),1)+.5];
    end
end
oldloc = 'none';					%#ok
oldax = [];						%#ok
if ~cbarinaxis
    % Search for existing colorbar (parents of CB6_TMW_COLORBAR tagged images)
    ch = get(findall(hfig,'type','image','tag','CB6_TMW_COLORBAR'),{'parent'});
    ax = [];
    for i=1:length(ch)
        ud = get(ch{i},'userdata');
        d = ud.PlotHandle;
        % if the plothandle (axis) of the colorbar is our axis
        if isequal(d,h)
            pos = get(ch{i},'Position');
            if pos(3)<pos(4)
                oldloc = 'vert';
            else
                oldloc = 'horiz';
            end
            % set ax to the ith colorbar
            % if it's location (orientation) is the same as the
            % new colorbar location (so a second colorbar with
            % the same orientation won't be created, and existing
            % colorbar will be updated
            if strncmp(oldloc,loc,1)
                ax = ch{i}; 
                % Make sure image deletefcn doesn't trigger a colorbar('delete')
                % for colorbar update - huh?
                set(findall(ax,'type','image'),'deletefcn','')
                break; 
            end
        end
    end
end
origNextPlot = get(hfig,'NextPlot');
if strcmp(origNextPlot,'replacechildren') || strcmp(origNextPlot,'replace')
        set(hfig,'NextPlot','add');
end
if loc(1)=='v' % create or refresh vertical colorbar
    
    if isempty(ax)
        units = get(h,'units');
        set(h,'units','normalized');
        pos = get(h,'Position'); 
        [az,el] = view(h);
        stripe = 0.075; edge = 0.02; 
        if all([az,el]==[0 90])
            space = 0.05;
        else
            space = .1;
        end
        set(h,'Position',[pos(1) pos(2) pos(3)*(1-stripe-edge-space) pos(4)]);
        rect = [pos(1)+(1-stripe-edge)*pos(3) pos(2) stripe*pos(3) pos(4)];
        ud.origPos = pos;
        
        % Create axes for stripe and
        % create ColorbarDeleteProxy object (an invisible text object in
        % the target axes) so that the colorbar will be deleted
        % properly.
        ud.ColorbarDeleteProxy = text('parent',h,...
            'visible','off',...
            'tag','ColorbarDeleteProxy',...
            'HandleVisibility','off',...
            'deletefcn','aslib(''delete'',''peer'',get(gcbf,''currentaxes''))');
 
        axH = graph3d.colorbar('parent',hfig);
        set(axH,'position',rect,'Orientation','vert');
        ax = double(axH);
        setappdata(ax,'NonDataObject',[]); % For DATACHILDREN.M
        set(ud.ColorbarDeleteProxy,'userdata',ax)
        set(h,'units',units)
    else
        axH=[];						%#ok
        ud = get(ax,'userdata');
    end
    
    % Create color stripe
    n = size(colormap(h),1);
    
    img = image([0 1],t,(1:n)',...
        'Parent',ax,...
        'Tag','CB6_TMW_COLORBAR',...
        'deletefcn','aslib(''delete'',''peer'',get(gcbf,''currentaxes''))',...
        'SelectionHighlight','off',...
        'HitTest','off');				%#ok
    %set up axes delete function
    set(ax,...
        'Ydir','normal',...
        'YAxisLocation','right',...
        'xtick',[],...
        'tag','Colorbar',...
        'deletefcn','aslib(''delete'',''peer'',get(gcbf,''currentaxes''))');
   
    
elseif loc(1)=='h', % create or refresh horizontal colorbar
    
    if isempty(ax),
        units = get(h,'units'); set(h,'units','normalized')
        pos = get(h,'Position');
        stripe = 0.075; space = 0.1;
        set(h,'Position',...
            [pos(1) pos(2)+(stripe+space)*pos(4) pos(3) (1-stripe-space)*pos(4)])
        rect = [pos(1) pos(2) pos(3) stripe*pos(4)];
        ud.origPos = pos;
        % Create axes for stripe and
        % create ColorbarDeleteProxy object (an invisible text object in
        % the target axes) so that the colorbar will be deleted
        % properly.
        ud.ColorbarDeleteProxy = text('parent',h,...
            'visible','off',...
            'tag','ColorbarDeleteProxy',...
            'handlevisibility','off',...
            'deletefcn','aslib(''delete'',''peer'',get(gcbf,''currentaxes''))');
        axH = graph3d.colorbar('parent',hfig);
        set(axH,'Orientation','horiz');
        set(axH,'position',rect);
        ax = double(axH);
        
        setappdata(ax,'NonDataObject',[]); % For DATACHILDREN.M
        set(ud.ColorbarDeleteProxy,'userdata',ax)
        set(h,'units',units)
    else
        axH=[];						%#ok
        ud = get(ax,'userdata');
    end
    
    % Create color stripe
    n = size(colormap(h),1);
    img=image(t,[0 1],(1:n),...
        'Parent',ax,...
        'Tag','CB6_TMW_COLORBAR',...
        'deletefcn','aslib(''delete'',''peer'',get(gcbf,''currentaxes''))',...
        'SelectionHighlight','off',...
        'HitTest','off');				%#ok
    % set up axes deletefcn
    set(ax,...
        'Ydir','normal',...
        'Ytick',[],...
        'tag','Colorbar',...
        'deletefcn','aslib(''delete'',''peer'',get(gcbf,''currentaxes''))')
    
else
  error('COLORBAR expects a handle, ''vert'', or ''horiz'' as input.')
end
if ~isfield(ud,'ColorbarDeleteProxy')
    ud.ColorbarDeleteProxy = [];
end
if ~isfield(ud,'origPos')
    ud.origPos = [];
end
ud.PlotHandle = h;
set(ax,'userdata',ud)
set(hfig,'NextPlot',origNextPlot)
if nargout>0
    h = ax;
end
if ishandle(GCF) && ~strcmpi(get(GCF,'beingdeleted'),'on')
    set(0,'currentfigure',GCF);
end
if ishandle(GCA) && ~strcmpi(get(GCA,'beingdeleted'),'on')
    set(gcf,'currentaxes',GCA);
end
end
function h = ASLIB_cb6_gcda(hfig, haxes)
h = datachildren(hfig);
if isempty(h) || any(h == haxes)
  h = haxes;
else
  h = h(1);
end
end
%+SSC_INSERT_END   20-Jul-2008/06:22:47   f:/usr/matlab/tmp/as/cb6.m
%-------------------------------------------------------------------------------