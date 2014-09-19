## Copyright (C) 2001 Paul Kienzle
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## y = dct2 (x)
##   Computes the 2-D discrete cosine transform of matrix x
##
## y = dct2 (x, m, n) or y = dct2 (x, [m n])
##   Computes the 2-D DCT of x after padding or trimming rows to m and
##   columns to n.

## Author: Paul Kienzle
## 2001-02-08
##   * initial revision

function y = dct2 (x, m, n)

  if (nargin < 1 || nargin > 3)
    usage("dct (x) or dct (x, m, n) or dct (x, [m n])");
  endif

  if nargin == 1
    [m, n] = size(x);
  elseif (nargin == 2)
    n = m(2);
    m = m(1);
  endif

  if m == 1
    y = dct (x.', n).';
  elseif n == 1
    y = dct (x, m);
  else
    y = dct (dct (x, m).', n).';
  endif

endfunction
