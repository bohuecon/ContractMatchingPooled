using Plots
theme(:default)
using LaTeXStrings
using JLD, HDF5

using Parameters
using Distributions
using Optim
using Optim: converged, maximum, maximizer, minimizer, iterations 

using LinearAlgebra
using Interpolations

include("internal_candi_parameters.jl")
include("internal_candi_solvemodel.jl")
include("internal_candi_bounds.jl")
include("internal_candi_valueupdate.jl")
include("internal_candi_contracting.jl")
include("internal_candi_policy.jl")
include("internal_candi_funcs.jl")
# include("internal_candi_plots.jl")
include("internal_candi_moments.jl")
include("whyholes.jl")

# this one does not converge
est_para3 = [
   # λi, λe, γi, γe, ai, bi, ae, be, ρ,
   7.9669, 6.4285, 11.3733, 19.6905, 4.3613, 5.6546, 4.7125, 9.0024, -0.2923, 
   # β1, β2, β3, β4, β5, 
   5.5108, -8.3194, -1.0298, -0.2501, 1.4096, 
   # γ1, γ3, γ4, γ5, κ0, κ1
   4.0561, 13.9467, 1.5728, -19.5414, -239.0179, 7.2275]


est_para3 = [
   # λi, λe, γi, γe, ai, bi, ae, be, ρ,
   7.9669, 6.4285, 11.3733, 19.6905, 4.3613, 5.6546, 4.7125, 9.0024, -0.2923, 
   # β1, β2, β3, β4, β5, 
   5.5108, -8.3194, -1.0298, -0.2501, 1.4096, 
   # γ1, γ3, γ4, γ5, κ0, κ1
   4.0561, -0.1, -0.1, -0.1, -239.0179, 7.2275]

para = est_para2deep_para(est_para3)
i_quasiconcave, e_quasiconcave = quasiconcave_objects(para)
sol, not_convergent = solve_main(para = para, diagnosis = true)

whyholes(29, 48, sol, para)
ii = 29
ei = 48

@unpack vec_Vi, vec_Ve, mat_Ve = sol


############################################
############################################


function whyholes(ii, ei, sol, deep_para)

   # ii = 29
   # ei = 48 #31-35 (32-34 are zeros)

   # sol.mat_Mu[ii, ei]
   # sol.mat_dummiesStar[ii, ei]
   # sol.mat_cStar[ii, ei]

   i_val = deep_para.vec_i[ii]
   e_val = deep_para.vec_e[ei]

   g_val = deep_para.mat_g[ii, ei]


   vi_val = sol.vec_Vi[ii] / g_val
   ve_val = sol.vec_Ve[ei] / g_val


   @unpack vec_dummies, num_dcases, h, ρ, β1, β2, vec_β, γ1, vec_γ = deep_para
   πi_s(c, dummies) = πi(c, dummies, β1, β2, vec_β, γ1, vec_γ) 
   πe_s(c, dummies) = πe(c, dummies, β1, β2, vec_β, γ1, vec_γ) 

   πi_ss00(c) = πi_s(c, [0,0,0])
   πi_ss10(c) = πi_s(c, [1,0,0])
   πi_ss01(c) = πi_s(c, [0,1,0])
   πi_ss11(c) = πi_s(c, [1,1,1])
   πe_ss00(c) = πe_s(c, [0,0,0])
   πe_ss10(c) = πe_s(c, [1,0,0])
   πe_ss01(c) = πe_s(c, [0,1,0])
   πe_ss11(c) = πe_s(c, [1,1,1])

   vec_c = range(0.0, 1.0, length = 200)

   # [:auto, :solid, :dash, :dot, :dashdot, :dashdotdot]
   plot(vec_c, πi_ss00.(vec_c), label = "πi00", linecolor = :green, linestyle = :solid, legend = :bottomleft, xlabel = "c", ylabel = "πi", title = "e = $ei")
   plot!(vec_c, πi_ss10.(vec_c), label = "πi10", linecolor = :darkorchid, linestyle = :solid)
   plot!(vec_c, πi_ss01.(vec_c), label = "πi01", linecolor = :deepskyblue, linestyle = :solid)
   plot!(vec_c, πi_ss11.(vec_c), label = "πi11", linecolor = :deeppink, linestyle = :solid)
   plot!(vec_c, vec_c -> vi_val, label = "vi_val", linecolor = :red, linestyle = :dashdot)

   p = twinx()

   plot!(p, vec_c, πe_ss00.(vec_c), label = "πe00", linecolor = :green, linestyle = :solid, legend = :bottomright, ylabel = "πe")
   plot!(p, vec_c, πe_ss10.(vec_c), label = "πe10", linecolor = :darkorchid, linestyle = :solid)
   plot!(p, vec_c, πe_ss01.(vec_c), label = "πe01", linecolor = :deepskyblue, linestyle = :solid)
   plot!(p, vec_c, πe_ss11.(vec_c), label = "πe11", linecolor = :deeppink, linestyle = :solid)
   plot!(p, vec_c, vec_c -> ve_val, label = "ve_val", linecolor = :indianred, linestyle = :dot)

   filename = "./figures/decision_e" * "$ei" * ".pdf"

   Plots.savefig(filename)
end

whyholes(7, 31, sol, deep_para)
whyholes(7, 32, sol, deep_para)
whyholes(7, 36, sol, deep_para)




############################################
############################################
############################################

include("./InternalCandi/InternalCandi.jl")

# λi, λe, γi, γe, ai, bi, ae, be, ρ, β1, β2, β3, β4, β5, γ1, γ3, γ4, γ5, κ0, κ1

# this does not converge
# est_para1 = [7.98398, 9.94985, 11.5009, 6.76383, 6.13025, 8.80139, 6.48018, 8.41869, -1.1507, 2.68856, -4.26221, 0.428072, -0.306312, -0.285261, 3.64172, -3.75063, 2.92743, 2.29239, -177.283, 8.64983]

# est_para2 = [7.98398, 9.94985, 11.5009, 6.76383, 6.13025, 8.80139, 6.48018, 8.41869, -1.1507, 2.68856, -4.26221, 0.428072, -0.306312, -0.285261, 3.64172, -3.75063, 2.92743, 2.0, -177.283, 8.64983]

# this converges
est_para1 = [
   # λi, λe, γi, γe, ai, bi, ae, be, ρ,
   5.5443, 14.9405, 8.0161, 1.3515, 1.1624, 6.7023, 3.1204, 3.4607, -0.5267, 
   # β1, β2, β3, β4, β5, 
   3.9576, -6.0942, 0.3479, -0.8109, -0.4704, 
   # γ1, γ3, γ4, γ5, κ0, κ1
   1.2006, -3.4716, 4.2472, -5.869, -147.622, 43.5689]

# this does not converge
est_para2 = [
   # λi, λe, γi, γe, ai, bi, ae, be, ρ,
   7.9669, 6.4285, 11.3733, 19.6905, 4.3613, 5.6546, 4.7125, 9.0024, -0.2923, 
   # β1, β2, β3, β4, β5, 
   5.5108, -8.3194, -1.0298, -0.2501, 1.4096, 
   # γ1, γ3, γ4, γ5, κ0, κ1
   4.0561, 13.9467, 1.5728, -19.5414, -239.0179, 7.2275]

modelMoment1, error_flag1, not_convergent1 = InternalCandi.genMoments(est_para = est_para1, diagnosis = true)
modelMoment2, error_flag2, not_convergent2 = InternalCandi.genMoments(est_para = est_para2, diagnosis = true)

est_para3 = [
   # λi, λe, γi, γe, ai, bi, ae, be, ρ,
   7.9669, 6.4285, 11.3733, 19.6905, 4.3613, 5.6546, 4.7125, 9.0024, -0.2923, 
   # β1, β2, β3, β4, β5, 
   5.5108, -8.3194, 0.0, 0.0, 0.0, 
   # γ1, γ3, γ4, γ5, κ0, κ1
   4.0561, 0.0, 0.0, 0.0, -239.0179, 7.2275]

modelMoment3, error_flag3, not_convergent3 = InternalCandi.genMoments(est_para = est_para3, diagnosis = true)

# Focus on this one to understand convergence

# est_para3 = [7.9669, 6.4285, 11.3733, 19.6905, 4.3613, 5.6546, 4.7125, 9.0024, -0.2923, 5.5108, -8.3194, -1.0298, -0.2501, 1.4096, 4.0561, 13.9467, 1.5728, -19.5414, -239.0179, 7.2275]


# # # Objectives should be quasiconcave

using Plots
using Parameters

include("./InternalCandi/InternalCandi.jl")

est_para = [7.9669, 6.4285, 11.3733, 19.6905, 4.3613, 5.6546, 4.7125, 9.0024, -0.2923, 5.5108, -8.3194, -1.0298, -0.2501, 1.4096, 4.0561, 13.9467, 1.5728, -19.5414, -239.0179, 7.2275]
para = InternalCandi.est_para2deep_para(est_para3)

@unpack h, ρ, β1, β2, vec_β, γ1, vec_γ, πi, πe = para

πi_s(c, dummies) = πi(c, dummies, β1, β2, vec_β, γ1, vec_γ) 
πe_s(c, dummies) = πe(c, dummies, β1, β2, vec_β, γ1, vec_γ) 

vec_c = range(0.0, 1.0, length = 200)

πi_ss00(c) = πi_s(c, [0,0,0])
πe_ss00(c) = πe_s(c, [0,0,0])
πi_ss10(c) = πi_s(c, [1,0,0])
πe_ss10(c) = πe_s(c, [1,0,0])
πi_ss01(c) = πi_s(c, [0,1,0])
πe_ss01(c) = πe_s(c, [0,1,0])
πi_ss11(c) = πi_s(c, [1,1,1])
πe_ss11(c) = πe_s(c, [1,1,1])

plot(vec_c, πi_ss00.(vec_c), label = "πi00")
plot!(vec_c, πi_ss10.(vec_c), label = "πi10")
plot!(vec_c, πi_ss01.(vec_c), label = "πi01")
plot!(vec_c, πi_ss11.(vec_c), label = "πi11")

plot(vec_c, πe_ss00.(vec_c), label = "πe00")
plot!(vec_c, πe_ss10.(vec_c), label = "πe10")
plot!(vec_c, πe_ss01.(vec_c), label = "πe01")
plot!(vec_c, πe_ss11.(vec_c), label = "πe11")



ii = 19 #17-20
ei = 40

sol.mat_Mu[ii, ei]
sol.mat_dummiesStar[ii, ei]
sol.mat_cStar[ii, ei]

i_val = para.vec_i[ii]
e_val = para.vec_e[ei]

vi_val = sol.vec_Vi[ii]
ve_val = sol.vec_Ve[ei]

g_val = para.mat_g[ii, ei]

using Plots

@unpack vec_dummies, num_dcases, h, ρ, β1, β2, vec_β, γ1, vec_γ = para
πi_s(c, dummies) = πi(c, dummies, β1, β2, vec_β, γ1, vec_γ) * g_val
πe_s(c, dummies) = πe(c, dummies, β1, β2, vec_β, γ1, vec_γ) * g_val

vec_c = range(0.0, 1.0, length = 200)

πi_ss00(c) = πi_s(c, [0,0,0])
πe_ss00(c) = πe_s(c, [0,0,0])

plot(vec_c, πi_ss00.(vec_c), label = "πi")
plot!(vec_c, πe_ss00.(vec_c), label = "πe") 


plot!(vec_c, vec_c -> vi_val, label = "vi_val")
plot!(vec_c, vec_c -> ve_val, label = "ve_val")



πi_ss10(c) = πi_s(c, [1,0,0])
πe_ss10(c) = πe_s(c, [1,0,0])

plot(vec_c, πi_ss10.(vec_c))
plot!(vec_c, πe_ss10.(vec_c))
plot!(vec_c, vec_c -> vi_val, label = "vi_val")
plot!(vec_c, vec_c -> ve_val, label = "ve_val")

πi_ss01(c) = πi_s(c, [0,1,0])
πe_ss01(c) = πe_s(c, [0,1,0])

plot(vec_c, πi_ss01.(vec_c))
plot!(vec_c, πe_ss01.(vec_c))
plot!(vec_c, vec_c -> vi_val, label = "vi_val")
plot!(vec_c, vec_c -> ve_val, label = "ve_val")

πi_ss11(c) = πi_s(c, [1,1,1])
πe_ss11(c) = πe_s(c, [1,1,1])
plot(vec_c, πi_ss11.(vec_c))
plot!(vec_c, πe_ss11.(vec_c))
plot!(vec_c, vec_c -> vi_val, label = "vi_val")
plot!(vec_c, vec_c -> ve_val, label = "ve_val")


# # Moment is NaN
# # It is because certain types are ruled out from the matching.

using Plots
theme(:default)
using LaTeXStrings

include("internal_candi_plots.jl")

using JLD, HDF5

est_para_initial = [3.65803, 2.72272, 4.94808, 17.0181, 4.11957, 5.3761, 4.04063, 2.58149, -0.547694, 4.59406, -6.87669, 0.290423, -0.793224, -0.240003, 0.479697, -2.84134, 4.54637, 1.99139, -153.041, 3.6081]
para = est_para2deep_para(est_para_initial)

# # genMoments(est_para = est_para_initial)

# # para = est_para2deep_para(est_para_initial)

sol, error_flag = solve_main(para = para, diagnosis = true, save_results = true)
plot_equ(para = para)
modelMoment = compute_moments(sol, para)

# # sol.mat_Mu

# # Score is Inf

# est_para_initial = [0.4757528330376203, 10.311682636376588, 11.205302317701191, 13.575152867705967, 7.625908706645962, 0.2074586086153344, 5.305456882693001, 1.7384377461064329, -0.822985561828605, 0.7245811893794712, -1.6476442086052763, 4.574396026127815, 1.0017949620520348, 1.725040908093134, 4.726685358913938, -1.7102183998275393, 0.5512342096847966, -1.9536548979866168, -96.05796730990805, 7.477075254493213]

# para = est_para2deep_para(est_para_initial)

# sol, error_flag = solve_main(para = para, diagnosis = true, save_results = true)
# plot_equ(para = para)
# modelMoment = compute_moments(sol, para)

# genMoments(est_para = est_para_initial)

# sol, error_flag = solve_model(ini_vec_Vi, ini_vec_Ve, ini_mat_Ve, bounds = bounds, para = para, sol_uc = sol_uc, max_iter = 3000, diagnosis = true)

# sol.vec_Vi
# sol.vec_Ve

# vec_x = range(0.0, 1.0, length = 100)
# Fi_pdf(x) = pdf(para.Fi, x)
# Fe_pdf(x) = pdf(para.Fe, x)

# plot(vec_x, Fi_pdf.(vec_x))
# plot(vec_x, Fe_pdf.(vec_x))


# ii = 10
# ei = 40

# vi_val = sol.vec_Vi[ii]
# ve_val = sol.vec_Ve[ei]


# mGrad is not of full rank, no parameter can affect cov_explicit_atwill, cov_long_atwill, cov_long_internal, cov_long_search

est_para_initial = [5.54431, 14.9405, 8.01613, 1.35146, 1.16238, 6.70227, 3.12045, 3.46072, -0.526669, 3.95762, -6.09421, 0.347944, -0.810893, -0.470389, 1.20059, -3.47155, 4.24721, -0.586905, -147.622, 43.5689]

para_ind = 14
h = abs(est_para_initial[para_ind]) * 10.0
est_para_u = copy(est_para_initial)
est_para_d = copy(est_para_initial)
est_para_u[para_ind] = est_para_initial[para_ind] + h
est_para_d[para_ind] = est_para_initial[para_ind] - h


modelMomentU, error_flag1, not_convergent1 = InternalCandi.genMoments(est_para = est_para_u, diagnosis = true)
modelMomentD, error_flag2, not_convergent2 = InternalCandi.genMoments(est_para = est_para_d, diagnosis = true)

(modelMomentU .- modelMomentD)./(2*h)


est_para1 = [5.54431, 14.9405, 8.01613, 1.35146, 1.16238, 6.70227, 3.12045, 3.46072, -0.526669, 3.95762, -6.09421, 0.347944, -0.810893, -0.470389, 1.20059, -3.47155, 4.24721, -0.586905, -147.622, 43.5689]
est_para2 = copy(est_para1)

for i in [14, 18]
	est_para2[i] = 0.0
end


modelMoment1, error_flag1, not_convergent1 = InternalCandi.genMoments(est_para = est_para1, diagnosis = true)
modelMoment2, error_flag2, not_convergent2 = InternalCandi.genMoments(est_para = est_para2, diagnosis = true)

(modelMoment1 .- modelMoment2)

# Understand the interaction terms



using Plots
theme(:default)
using LaTeXStrings

est_para1 = [5.54431, 14.9405, 8.01613, 1.35146, 1.16238, 6.70227, 3.12045, 3.46072, -0.526669, 3.95762, -6.09421, 0.347944, -0.810893, -0.470389, 1.20059, -3.47155, 4.24721, -0.586905, -147.622, 43.5689]
est_para1 = [5.54431, 14.9405, 8.01613, 1.35146, 1.16238, 6.70227, 3.12045, 3.46072, -0.526669, 3.95762, -6.09421, 0.347944, -0.810893, -0.470389, 1.20059, -3.47155, 4.24721, 5.86905, -147.622, 43.5689]

para1 = est_para2deep_para(est_para1)

@unpack vec_dummies, num_dcases, h, ρ, β1, β2, vec_β, γ1, vec_γ = para1

πi_s(c, dummies) = πi(c, dummies, β1, β2, vec_β, γ1, vec_γ) 

vec_c = range(0.0, 1.0, length = 200)

πi_ss00(c) = πi_s(c, [0,0,0])
πi_ss10(c) = πi_s(c, [1,0,0])
πi_ss01(c) = πi_s(c, [0,1,0])
πi_ss11(c) = πi_s(c, [1,1,1])

plot(vec_c, πi_ss00.(vec_c), label = "πi00")
plot!(vec_c, πi_ss10.(vec_c), label = "πi10")
plot!(vec_c, πi_ss01.(vec_c), label = "πi01")
plot!(vec_c, πi_ss11.(vec_c), label = "πi11")

πe_s(c, dummies) = πe(c, dummies, β1, β2, vec_β, γ1, vec_γ) 

πe_ss00(c) = πe_s(c, [0,0,0])
πe_ss10(c) = πe_s(c, [1,0,0])
πe_ss01(c) = πe_s(c, [0,1,0])
πe_ss11(c) = πe_s(c, [1,1,1])

plot(vec_c, πe_ss00.(vec_c), label = "πe00")
plot!(vec_c, πe_ss10.(vec_c), label = "πe10")
plot!(vec_c, πe_ss01.(vec_c), label = "πe01")
plot!(vec_c, πe_ss11.(vec_c), label = "πi11")




vec_c = range(0.0, 1.0, length = 200)

πi_ss00(c) = πi_s(c, [0,0,0])
πe_ss00(c) = πe_s(c, [0,0,0])

plot(vec_c, πi_ss00.(vec_c), label = "πi")
plot!(vec_c, πe_ss00.(vec_c), label = "πe") 


plot!(vec_c, vec_c -> vi_val, label = "vi_val")
plot!(vec_c, vec_c -> ve_val, label = "ve_val")



πi_ss10(c) = πi_s(c, [1,0,0])
πe_ss10(c) = πe_s(c, [1,0,0])

plot(vec_c, πi_ss10.(vec_c))
plot!(vec_c, πe_ss10.(vec_c))
plot!(vec_c, vec_c -> vi_val, label = "vi_val")
plot!(vec_c, vec_c -> ve_val, label = "ve_val")

πi_ss01(c) = πi_s(c, [0,1,0])
πe_ss01(c) = πe_s(c, [0,1,0])

plot(vec_c, πi_ss01.(vec_c))
plot!(vec_c, πe_ss01.(vec_c))
plot!(vec_c, vec_c -> vi_val, label = "vi_val")
plot!(vec_c, vec_c -> ve_val, label = "ve_val")

πi_ss11(c) = πi_s(c, [1,1,1])
πe_ss11(c) = πe_s(c, [1,1,1])
plot(vec_c, πi_ss11.(vec_c))
plot!(vec_c, πe_ss11.(vec_c))
plot!(vec_c, vec_c -> vi_val, label = "vi_val")
plot!(vec_c, vec_c -> ve_val, label = "ve_val")

julia> show(dfMoment, allcols = true)
20×4 DataFrame
 Row │ Moments              Data          Model         tStat
     │ String               Float64       Float64       Float64
─────┼─────────────────────────────────────────────────────────────
   1 │ mean_search           0.471831      0.373292     -4.11186
   2 │ var_search            0.126921      0.15412       0.727749
   3 │ mean_internal         0.59233       0.592728      0.0215132
   4 │ var_internal          0.241819      0.241402     -0.121996
   5 │ mean_delta            0.378239      0.343615     -9.26014
   6 │ var_delta             0.00966046    0.000962466  -9.11529
   7 │ mean_explicit         0.31108       0.364245      3.04717
   8 │ mean_atwill           0.176136      0.150888     -1.75863
   9 │ cov_delta_explicit   -0.00296118    6.75003e-5    1.76997
  10 │ cov_delta_atwill     -0.000378705  -0.00115094   -0.54926
  11 │ cov_explicit_atwill   0.0262107     0.0685567     5.85545
  12 │ cov_delta_search     -0.00445154   -0.000331283   1.78817
  13 │ cov_explicit_search   0.000383037  -0.0112045    -0.974948
  14 │ cov_atwill_search    -0.00345281   -0.00977203   -0.916243
  15 │ mean_long             0.731534      0.731528     -0.0003886
  16 │ cov_long_delta       -0.00215109    0.00364345    3.19676
  17 │ cov_long_explicit    -0.0187852     0.00834206    3.3923
  18 │ cov_long_atwill      -0.0195025     0.0405092     8.64036
  19 │ cov_long_internal     0.0269563     0.000426101  -3.17998
  20 │ cov_long_search      -0.0186774    -0.0119087     0.488757

est_para_initial = [5.54431, 14.9405, 8.01613, 1.35146, 1.16238, 6.70227, 3.12045, 3.46072, -0.526669, 3.95762, -6.09421, 0.347944, -0.810893, -0.470389, 1.20059, -3.47155, 4.24721, -5.86905, -147.622, 43.5689]

ThetaStar = est_para_initial;

modelMomentThetaStar, error_flag = InternalCandi.genMoments(est_para = ThetaStar);
stdErr = diag(CovDataMoment).^0.5;
tStat = (modelMomentThetaStar - dataMoment) ./ stdErr;
dfMoment = DataFrame(Moments = momentName,  Data = dataMoment, Model = modelMomentThetaStar, tStat = tStat);
show(dfMoment, allcols = true)
println()




using Parameters
using Distributions
using Optim
using Optim: converged, maximum, maximizer, minimizer, iterations 

using LinearAlgebra
using Interpolations
using DataFrames
using CSV

using Plots
theme(:default)
using LaTeXStrings
using JLD, HDF5


include("internal_candi_parameters.jl")
include("internal_candi_solvemodel.jl")
include("internal_candi_bounds.jl")
include("internal_candi_valueupdate.jl")
include("internal_candi_contracting.jl")
include("internal_candi_policy.jl")
include("internal_candi_funcs.jl")
include("internal_candi_plots.jl")
include("internal_candi_moments.jl")

est_para_initial = [7.98398, 9.94985, 11.5009, 6.76383, 6.13025, 8.80139, 6.48018, 8.41869, -1.1507, 2.68856, -4.26221, 0.428072, -0.306312, -0.285261, 3.64172, -3.75063, 2.92743, 2.29239, -177.283, 8.64983]
deep_para = est_para2deep_para(est_para_initial)
i_quasiconcave, e_quasiconcave = quasiconcave_objects(deep_para)

sol, not_convergent = solve_main(para = deep_para, diagnosis = true, save_results = true)
plot_equ(;para = deep_para)


function whyholes(ii, ei, sol, deep_para)

   # ii = 7 
   # ei = 32 #31-35 (32-34 are zeros)

   # sol.mat_Mu[ii, ei]
   # sol.mat_dummiesStar[ii, ei]
   # sol.mat_cStar[ii, ei]

   i_val = deep_para.vec_i[ii]
   e_val = deep_para.vec_e[ei]

   g_val = deep_para.mat_g[ii, ei]


   vi_val = sol.vec_Vi[ii] / g_val
   ve_val = sol.vec_Ve[ei] / g_val


   @unpack vec_dummies, num_dcases, h, ρ, β1, β2, vec_β, γ1, vec_γ = deep_para
   πi_s(c, dummies) = πi(c, dummies, β1, β2, vec_β, γ1, vec_γ) 
   πe_s(c, dummies) = πe(c, dummies, β1, β2, vec_β, γ1, vec_γ) 

   πi_ss00(c) = πi_s(c, [0,0,0])
   πi_ss10(c) = πi_s(c, [1,0,0])
   πi_ss01(c) = πi_s(c, [0,1,0])
   πi_ss11(c) = πi_s(c, [1,1,1])
   πe_ss00(c) = πe_s(c, [0,0,0])
   πe_ss10(c) = πe_s(c, [1,0,0])
   πe_ss01(c) = πe_s(c, [0,1,0])
   πe_ss11(c) = πe_s(c, [1,1,1])

   vec_c = range(0.0, 1.0, length = 200)

   # [:auto, :solid, :dash, :dot, :dashdot, :dashdotdot]
   plot(vec_c, πi_ss00.(vec_c), label = "πi00", linecolor = :green, linestyle = :solid, legend = :bottomleft, xlabel = "c", ylabel = "πi", title = "e = $ei")
   plot!(vec_c, πi_ss10.(vec_c), label = "πi10", linecolor = :darkorchid, linestyle = :solid)
   plot!(vec_c, πi_ss01.(vec_c), label = "πi01", linecolor = :deepskyblue, linestyle = :solid)
   plot!(vec_c, πi_ss11.(vec_c), label = "πi11", linecolor = :deeppink, linestyle = :solid)
   plot!(vec_c, vec_c -> vi_val, label = "vi_val", linecolor = :red, linestyle = :dashdot)

   p = twinx()

   plot!(p, vec_c, πe_ss00.(vec_c), label = "πe00", linecolor = :green, linestyle = :solid, legend = :bottomright, ylabel = "πe")
   plot!(p, vec_c, πe_ss10.(vec_c), label = "πe10", linecolor = :darkorchid, linestyle = :solid)
   plot!(p, vec_c, πe_ss01.(vec_c), label = "πe01", linecolor = :deepskyblue, linestyle = :solid)
   plot!(p, vec_c, πe_ss11.(vec_c), label = "πe11", linecolor = :deeppink, linestyle = :solid)
   plot!(p, vec_c, vec_c -> ve_val, label = "ve_val", linecolor = :indianred, linestyle = :dot)

   filename = "./figures/decision_e" * "$ei" * ".pdf"

   Plots.savefig(filename)
end

whyholes(7, 31, sol, deep_para)
whyholes(7, 32, sol, deep_para)
whyholes(7, 36, sol, deep_para)



