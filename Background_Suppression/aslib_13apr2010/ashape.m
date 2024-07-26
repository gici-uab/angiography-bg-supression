%ASHAPE		an ASLIB wrapper to compute ALPHA SHAPEs
%
%		ASHAPE is a convenient wrapper for the
%		ALPHA SHAPE library ASLIB
%		for instructions/options see also:	ASLIB
%
%SYNTAX
%-------------------------------------------------------------------------------
%		P = ASHAPE(X,Y,R,OPT)
%		P = ASHAPE(PO,OPT)
%
%INPUT
%-------------------------------------------------------------------------------
% X/Y	:	input vectors|matrices of x/y data coordinates
% R	:	radius of alpha circle template
%
% OPT	:	options
% --------------------------------------------------------------
%  PO	:	previously computed ASLIB structure P
%		see:					ASLIB -o
%
%OUTPUT
%-------------------------------------------------------------------------------
%  P	:	ASLIB structure
%		for explanations see:			ASLIB -f
%  P.f	:	handles to ASLIB functions
%		for explanations see:			ASLIB -s
%
%EXAMPLE
%-------------------------------------------------------------------------------
%		x=cosd(0:10:180);
%		y=sind(0:10:180);
%		p=ashape(x,y,.1);

% created:
%	us	17-Jan-2005
% modified:
%	us	13-Apr-2010 15:31:23

%--------------------------------------------------------------------------------
function	p=ashape(varargin)

	if	nargout
		p=[];
	end

	if	nargin					&&...
		isstruct(varargin{1})
		c=aslib(varargin{1},1);
	if	c.r < 2
		p=ashape(c.p.x,c.p.y,c.p.r,varargin{2:end});
		return
	else
		error(c.msg);
	end
	end

	if	nargin < 3
		help(mfilename);
		return;
	else
		x=varargin{1};
		y=varargin{2};
		r=varargin{3};
		o={};
	if	nargin > 3
		o=varargin(4:end);
	end
	end

		p.f=aslib;
		p=p.f.aini(x,y,r,o{:});
		p.runtime=clock;
		p=p.f.mseg(p);
		p=p.f.mcon(p);
		p=p.f.mpat(p);
		p.runtime=etime(clock,p.runtime);
		p=p.f.aini(p);

	if	p.flg.gflg
	if	p.flg.pflg
		p=p.f.gpat(p);
	else
		p=p.f.gall(p);
	end
	end
end
%--------------------------------------------------------------------------------