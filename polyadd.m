function r = polyadd(p, q)
%POLYADD Add two polynomials given in descending-power coefficient order.
%   R = POLYADD(P,Q) accepts nonempty numeric row or column vectors, even
%   when their lengths differ, and returns a row vector of coefficients.
%   Leading zeros are retained; the output length is max(numel(P),numel(Q)).
%   Represent the zero polynomial by 0, not by an empty vector.
%
%   Example: polyadd([2 3 4], [5 6]) returns [2 8 10], representing
%   (2*x^2 + 3*x + 4) + (5*x + 6) = 2*x^2 + 8*x + 10.

    if ~isnumeric(p) || ~isvector(p) || isempty(p) || ...
       ~isnumeric(q) || ~isvector(q) || isempty(q)
        error('polyadd:InvalidInput', ...
              'p and q must be nonempty numeric row or column vectors.');
    end

    % Nonconjugating transpose also preserves complex coefficients.
    p = double(p(:).');
    q = double(q(:).');
    n = max(numel(p), numel(q));

    % Pad on the LEFT so coefficients of the same power line up.
    p = [zeros(1, n - numel(p)), p];
    q = [zeros(1, n - numel(q)), q];
    r = p + q;
end
