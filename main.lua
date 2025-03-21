function factorial(n)
    local result = 1
    for i = 2, n do
        result = result * i
    end
    return result
end

-- gets the binomial coefficient (n choose r)
function binomial(n, r)
    return factorial(n) / (factorial(r) * factorial(n - r))
end

-- gets the probability of getting r successes in n trials -> P(X = r)
function binomial_distribution(r, n, p)
    return binomial(n, r) * p ^ r * (1 - p) ^ (n - r)
end

-- gets the cumulative distribution -> P(X <= r)
function cumulative_distribution(r, n, p)
    local sum = 0
    for i = 0, r do
        sum = sum + binomial_distribution(i, n, p)
    end
    return sum
end

-- one tailed test (returns if null hypothesis is accepted)
function perform_one_tailed_test(trials, success_probability, significance_level, result, greater_than)
    local p_value = 0
    if greater_than then
        p_value = 1 - (cumulative_distribution(trials, result - 1, success_probability))
    else
        p_value = cumulative_distribution(trials, result, success_probability)
    end

    if p_value < significance_level then
        -- reject null hypothesis
        return false, p_value
    else
        -- accept null hypothesis
        return true, p_value
    end
end

-- two tailed test (returns if null hypothesis is accepted)
function perform_two_tailed_test(trials, success_probability, significance_level, result)
    local significance_level = significance_level / 2

    local cumulative_distribution_table = {}

    for i = 0, trials, 1 do
        cumulative_distribution_table[i] = cumulative_distribution(trials, i, success_probability)
    end

    local top_critical_region = 0
    local top_real_significance_level = 0
    local bottom_critical_region = 0
    local bottom_real_significance_level = 0


    for i = 0, trials, 1 do
        if cumulative_distribution_table[i] < significance_level then
            bottom_critical_region = i
            bottom_real_significance_level = cumulative_distribution_table[i]
        end
        if cumulative_distribution_table[i] > 1 - significance_level then
            top_critical_region = i
            top_real_significance_level = 1 - cumulative_distribution_table[i]
            -- break because this would be the MOST closest one
            break
        end
    end

    local total_real_significance_level = top_real_significance_level + bottom_real_significance_level

    if result > bottom_critical_region and result < top_critical_region then
        -- accept null hypothesis
        return true, total_real_significance_level
    else
        -- reject null hypothesis
        return false, total_real_significance_level
    end
end

function main()
    print("Enter the number of trials:")
    local trials = io.read("*n")

    print("Enter the success probability:")
    local success_probability = io.read("*n")

    print("Enter the significance level:")
    local significance_level = io.read("*n")

    print("Enter the result:")
    local result = io.read("*n")

    print()

    print("null hypothesis (H0): p = " .. success_probability)

    print()

    print("Enter the alternative hypothesis (H1), -1 for p < " ..
        success_probability .. ", 1 for p > " .. success_probability .. ", and 0 for p != " .. success_probability)

    print()

    local alternative_hypothesis = io.read("*n")

    print("alternative hypothesis (H1): p " ..
        (alternative_hypothesis == "< 1" and "<" or alternative_hypothesis == "> 1" and ">" or "!=") ..
        " " .. success_probability)

    print()

    local null_hyp_accepted = false
    local real_significance_level = 0

    if alternative_hypothesis == 0 then
        null_hyp_accepted, real_significance_level = perform_two_tailed_test(trials, success_probability,
            significance_level, result)
    else
        if alternative_hypothesis == -1 then
            null_hyp_accepted, _ = perform_one_tailed_test(trials, success_probability,
                significance_level, result, false)
            real_significance_level = significance_level
        elseif alternative_hypothesis == 1 then
            null_hyp_accepted, _ = perform_one_tailed_test(trials, success_probability,
                significance_level, result, true)
            real_significance_level = significance_level
        else
            print("invalid alternative hypothesis provided")
            return
        end
    end

    if null_hyp_accepted == false then
        print("There is insufficient evidence to support the null hypothesis at the " ..
            real_significance_level .. " significance level, therefore reject the null hypothesis.")
    else
        print("There is insufficient evidence to support the alternative hypothesis at the " ..
            real_significance_level .. " significance level, therefore do not reject the null hypothesis.")
    end

    print()
end

while true do
    main()
    print("Do you want to continue? (y/n)")
    io.read()
    local continue = io.read()
    if continue == "n" then
        break
    end
end
