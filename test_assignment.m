function test_assignment()
%TEST_ASSIGNMENT Run examples and automated checks for Problems 1 and 2.
%   From the repository folder, enter: test_assignment
%   Uses base MATLAB only; it is also compatible with GNU Octave.

    fprintf('Problem 1: samplevar compared with var\n');
    fprintf('%-22s %16s %16s %12s\n', ...
            'Input', 'samplevar', 'var', 'Abs. error');

    variance_cases = {
        'Row vector', [1 2 3 4 5], 2.5;
        'Column vector', [1; 2; 3; 4; 5], 2.5;
        'Two observations', [2 4], 2;
        'Constant values', [7 7 7 7], 0;
        'Mixed signs', [-3 -1 1 3], 20/3;
        'Decimal values', [0.5 1.5 2.5], 1;
        'Integer input', uint8([1 2 4]), 7/3;
        'Single input', single([1 2 3]), 1;
        'Offset data', 1e6 + [1 2 3 4 5], 2.5
    };

    checks = 0;
    for k = 1:size(variance_cases, 1)
        x = variance_cases{k, 2};
        actual = samplevar(x);
        % Both functions are compared in double precision.
        reference = var(double(x(:)));
        check_close(actual, variance_cases{k, 3}, 1e-12);
        check_close(actual, reference, 1e-12);
        checks = checks + 2;
        fprintf('%-22s %16.10g %16.10g %12.3g\n', ...
                variance_cases{k, 1}, actual, reference, abs(actual-reference));
    end

    % The assignment formula is undefined for fewer than two observations.
    assert(isnan(samplevar([])));
    assert(isnan(samplevar(5)));
    assert(isnan(samplevar([1 NaN 3])));
    assert(isnan(samplevar([1 Inf 3])));
    checks = checks + 4;
    fprintf('\nBoundary convention: samplevar([]) and samplevar(5) return NaN.\n');
    fprintf('For comparison, var(5) returns %g in this runtime.\n', var(5));

    fprintf('\nProblem 2: polynomial addition\n');
    polynomial_cases = {
        [2 3 4], [5 6], [2 8 10];
        [5 6], [2 3 4], [2 8 10];
        [1 2 3], [4 5 6], [5 7 9];
        [1 2 3], 4, [1 2 7];
        4, [1 2 3], [1 2 7];
        [2; 3; 4], [5 6], [2 8 10];
        [2; 3; 4], [5; 6], [2 8 10];
        [1 2], [-1 -2], [0 0];
        [0 1 2], [3 4], [0 4 6];
        0, [1 2 3], [1 2 3];
        0, 0, 0;
        uint8([1 2]), uint8([3 4]), [4 6];
        [1+2i; 3-1i], 2i, [1+2i 3+1i]
    };

    for k = 1:size(polynomial_cases, 1)
        p = polynomial_cases{k, 1};
        q = polynomial_cases{k, 2};
        actual = polyadd(p, q);
        assert(isequal(actual, polynomial_cases{k, 3}));
        checks = checks + 1;
        fprintf('polyadd(%s, %s) = %s\n', ...
                mat2str(p), mat2str(q), mat2str(actual));
    end

    % Reproducible randomized tests, without changing the caller's RNG state.
    previous_rng = rng;
    cleanup_rng = onCleanup(@() rng(previous_rng)); %#ok<NASGU>
    rng(3510, 'twister');
    t = [-2 -0.5 0 0.5 2];
    for k = 1:100
        x = 5*randn(1, randi([2 100])) + 2;
        check_close(samplevar(x), var(x), 1e-12);
        check_close(samplevar(x.'), var(x), 1e-12);

        p = randi([-10 10], 1, randi([1 12]));
        q = randi([-10 10], 1, randi([1 12]));
        r = polyadd(p, q);
        assert(isrow(r) && numel(r) == max(numel(p), numel(q)));
        assert(isequal(r, polyadd(q, p)));
        check_close(polyval(r, t), polyval(p, t) + polyval(q, t), 1e-12);
        checks = checks + 5;
    end

    % Reject matrices/non-numeric data rather than silently misinterpreting them.
    check_error(@() samplevar([1 2; 3 4]), 'samplevar:InvalidInput');
    check_error(@() samplevar('abc'), 'samplevar:InvalidInput');
    check_error(@() samplevar([1 2i]), 'samplevar:InvalidInput');
    check_error(@() polyadd([], 1), 'polyadd:InvalidInput');
    check_error(@() polyadd(1, []), 'polyadd:InvalidInput');
    check_error(@() polyadd([1 2; 3 4], 1), 'polyadd:InvalidInput');
    check_error(@() polyadd(1, [1 2; 3 4]), 'polyadd:InvalidInput');
    check_error(@() polyadd('abc', 1), 'polyadd:InvalidInput');
    checks = checks + 8;

    fprintf('\nAll tests passed: %d checks.\n', checks);
end

function check_close(actual, expected, tolerance)
%CHECK_CLOSE Use a relative tolerance with an absolute floor near zero.
    assert(isequal(size(actual), size(expected)), 'Result has the wrong size.');
    difference = abs(actual - expected);
    bound = tolerance .* max(1, abs(expected));
    assert(all(difference(:) <= bound(:)), 'Numerical result does not match.');
end

function check_error(action, expected_identifier)
%CHECK_ERROR Verify that invalid input produces the intended error.
    caught = false;
    try
        action();
    catch exception
        caught = true;
        assert(strcmp(exception.identifier, expected_identifier), ...
               'Unexpected error identifier.');
    end
    assert(caught, 'Expected an input-validation error.');
end
