function s2 = samplevar(x)
%SAMPLEVAR Compute sample variance using the formula in Problem 1.
%   S2 = SAMPLEVAR(X) accepts a real numeric row or column vector.
%   For n >= 2, S2 = sum((X - sum(X)/n).^2)/(n - 1).
%   Empty and one-element inputs return NaN because the sample variance
%   formula requires at least two observations. No call to VAR is used.

    if ~isnumeric(x) || ~isreal(x) || (~isvector(x) && ~isempty(x))
        error('samplevar:InvalidInput', ...
              'x must be a real numeric row or column vector.');
    end

    % Use a column vector and floating-point arithmetic for all inputs.
    x = double(x(:));
    n = numel(x);

    if n < 2
        s2 = NaN;
        return;
    end

    xbar = sum(x) / n;
    s2 = sum((x - xbar).^2) / (n - 1);
end
