*! Version 1.0.5  01Feb2026
*! Author: [Ma Junhao]
*! Implements Oster (2019) Stability Test with PSACALC mathematical core
*! Modification: Removed 'areg' support. Compatible with Stata 'bootstrap' prefix.

capture program drop coefstability
capture program drop _get_r2_new
capture program drop _calc_oster_bounds
capture program drop _build_base_cmd
capture program drop _cs_resolve_bname
capture program drop _get_vars_consistent

// -----------------------------------------------------------------------------
//  1. Main Program
// -----------------------------------------------------------------------------
program define coefstability, rclass sortpreserve
    version 13.0
    
    // 语法简化：不再接受 bootstrap 相关参数
    syntax varlist(min=1 max=1 fv ts) [if] [in] , ///
        MODEL(string)          ///
        [                      ///
          DELta(real 1)        ///
          RMAX(real 1.3)       ///
          BETA(real 0)         /// 
          NOIsily              ///
        ]

    local treatvar `varlist'
    local rmax_mult `rmax'
    local target_beta `beta'
    
    // --- Check Inputs ---
    if "`treatvar'" == "" {
        di as error "Error: Treatment variable is missing."
        exit 198
    }

    // =======================================================
    // Part A: Point Estimation (Full Model)
    // =======================================================
    if "`noisily'" != "" di as text _n "Running Full Model..."

    marksample touse
    local full_cmd `"`model'"'

    // Handle 'if' conditions inside model string
    if strpos(`"`full_cmd'"', ",") > 0 {
        local part1 = substr(`"`full_cmd'"', 1, strpos(`"`full_cmd'"', ",") - 1)
        local part2 = substr(`"`full_cmd'"', strpos(`"`full_cmd'"', ","), .)
        local run_cmd `"`part1' if `touse' `part2'"'
    }
    else {
        local run_cmd `"`full_cmd' if `touse'"'
    }

    // Run Full Model
    capture quietly `run_cmd'
    if _rc != 0 {
        di as error "Error: Full Model failed to run (r=`_rc')."
        di as error "Command: `run_cmd'"
        exit _rc
    }

    // Retrieve Parameters
    _cs_resolve_bname "`treatvar'"
    local treat_bname_full "`r(bname)'"
    if "`treat_bname_full'" == "" {
        di as error "Error: Cannot find coefficient for {bf:`treatvar'}."
        exit 111
    }

    tempname B_full B_base R2_full R2_base SYy SXx Tx RMAX

    scalar `B_full' = _b[`treat_bname_full']
    _get_r2_new "`e(cmd)'"
    scalar `R2_full' = r(r2)            

    // Mark Estimation Sample (Use e(sample) to align base model)
    tempvar esample
    gen byte `esample' = e(sample)

    // =======================================================
    // Part B: Baseline Model
    // =======================================================
    _build_base_cmd `"`full_cmd'"' "`treatvar'"
    local base_cmd_str "`r(base_cmd)'"
    if "`noisily'" != "" di as text "Baseline Model: `base_cmd_str'"

    // Run Base Model
    if strpos(`"`base_cmd_str'"', ",") > 0 {
        local p1 = substr(`"`base_cmd_str'"', 1, strpos(`"`base_cmd_str'"', ",") - 1)
        local p2 = substr(`"`base_cmd_str'"', strpos(`"`base_cmd_str'"', ","), .)
        local run_base `"`p1' if `esample' `p2'"'
    }
    else {
        local run_base `"`base_cmd_str' if `esample'"'
    }

    capture quietly `run_base'
    if _rc != 0 {
        // Fallback: simple regression if base command parsing failed slightly
        local fallback_cmd "regress `e(depvar)' `treatvar' if `esample'"
        capture quietly `fallback_cmd'
        if _rc != 0 {
            di as error "Error: Baseline model failed to run."
            exit _rc
        }
    }

    _cs_resolve_bname "`treatvar'"
    local treat_bname_base "`r(bname)'"
    if "`treat_bname_base'" == "" local treat_bname_base "`treat_bname_full'"

    scalar `B_base' = _b[`treat_bname_base']
    _get_r2_new "`e(cmd)'"
    scalar `R2_base' = r(r2)       
    
    if "`noisily'" != "" {
        di as text _n "---- Inputs from Regressions (psacalc-style check) ----"
        di as text "Uncontrolled | beta=" %10.5f scalar(`B_base') "  R2=" %9.3f scalar(`R2_base')
        di as text "Controlled   | beta=" %10.5f scalar(`B_full') "  R2=" %9.3f scalar(`R2_full')

    }

    // =======================================================
    // Part C: Variance Calculation (Unified Logic)
    // =======================================================
    
    local wgt ""
    if "`e(wtype)'" != "" {
        // yields something like [pweight=wvar]
        local wgt "[`e(wtype)'`e(wexp)']"
    }

    _get_vars_consistent, full_cmd(`"`full_cmd'"') base_cmd(`"`base_cmd_str'"') ///
    treatvar("`treatvar'") touse(`esample') wgt(`"`wgt'"')

    scalar `SYy' = r(sigma_yy)
    scalar `SXx' = r(sigma_xx)
    scalar `Tx'  = r(t_x)

    * Rmax: scalar化，避免local精度损失
    scalar `RMAX' = `rmax_mult' * scalar(`R2_full')
    if (scalar(`RMAX') > 1) scalar `RMAX' = 1
    if (scalar(`RMAX') <= scalar(`R2_full')) scalar `RMAX' = scalar(`R2_full') + 1e-12
    

    local b_full   = scalar(`B_full')
    local b_base   = scalar(`B_base')
    local r2_full  = scalar(`R2_full')
    local r2_base  = scalar(`R2_base')
    local rmax_val = scalar(`RMAX')
    local sigma_yy = scalar(`SYy')
    local sigma_xx = scalar(`SXx')
    local t_x      = scalar(`Tx')



    // =======================================================
    // Part D: Calculation (Mata Kernel)
    // =======================================================
    
    _calc_oster_bounds, ///
        b_o(`=scalar(`B_base')') b_tilde(`=scalar(`B_full')') ///
        r_o(`=scalar(`R2_base')') r_tilde(`=scalar(`R2_full')') ///
        rmax(`=scalar(`RMAX')') ///
        sigma_yy(`=scalar(`SYy')') sigma_xx(`=scalar(`SXx')') t_x(`=scalar(`Tx')') ///
        delta_in(`delta') target_beta(`target_beta')


    local beta_star  = r(beta_star)
    local delta_star = r(delta_star)



    if missing(`beta_star') {
        tempname DENOMR NUMERR K
        scalar `DENOMR' = scalar(`R2_full') - scalar(`R2_base')
        scalar `NUMERR' = scalar(`RMAX')    - scalar(`R2_full')
        if (scalar(`DENOMR') > 1e-12) & (scalar(`NUMERR') > 1e-12) {
            scalar `K' = scalar(`NUMERR') / scalar(`DENOMR')
            local beta_star = `b_full' - `delta' * (`b_base' - `b_full') * scalar(`K')
        }
    }


    // =======================================================
    // Part E: Output Formatting (Displayed only if not quietly)
    // =======================================================
    // When run via 'bootstrap:', output is suppressed automatically, which is what we want.
    
    local s_b_full : display %9.3f `beta_star'
    local s_b_full = trim("`s_b_full'")

    if `b_full' < `beta_star' {
        local val_low  = `b_full'
        local val_high = `beta_star'
    }
    else {
        local val_low  = `beta_star'
        local val_high = `b_full'
    }

    local s_low  : display %9.3f `val_low'
    local s_high : display %9.3f `val_high'
    local s_bounds "[`=trim("`s_low'")', `=trim("`s_high'")']"

    local s_reject "No"
    if (`val_low' > 0 & `val_high' > 0) | (`val_low' < 0 & `val_high' < 0) {
        local s_reject "Yes"
    }
    if abs(`beta_star') > 1e10 local s_b_full "No Sol."

    local base_for_label "`treatvar'"
    capture _ms_parse_parts `treatvar'
    if _rc == 0 {
        if "`r(name)'" != "" local base_for_label "`r(name)'"
    }
    local lbl ""
    capture local lbl : var label `base_for_label'
    if "`lbl'" == "" local lbl "`treatvar'"
    if length("`lbl'") > 15 local lbl = substr("`lbl'", 1, 13) + ".."

    local c1 20
    local c2 36
    local c3 56
    local c4 66
    local c5 78

    di _n
    di as text "{hline 88}"
    di as text "Oster (2019) Tests for Stability (Consistent Within-Variance)"
    di as text "{hline 88}"
    di as text _col(`c1') "  (1)" _col(`c2') "     (2)" _col(`c3') "   (3)" _col(`c4') "    (4)" _col(`c5') "    (5)"
    di as text _col(`c1') "" _col(`c2') "    Oster" _col(`c3') "   Rmax" _col(`c4') "   Delta" _col(`c5') "   Reject"
    di as text "Variable" _col(`c1') "beta_adj" _col(`c2') "    Bounds" _col(`c3') "   Value" _col(`c4') " (for β=`target_beta')" _col(`c5') "    Null?"
    di as text "{hline 88}"
    di as text "`lbl'" ///
        _col(`c1') as result "`s_b_full'" ///
        _col(`c2') as result "`s_bounds'" ///
        _col(`c3') as result %8.3f `rmax_val' ///
        _col(`c4') as result %8.3f `delta_star' ///
        _col(`c5') as result "     `s_reject'"
    di as text "{hline 88}"
    local s_rmax_mult : display %3.1f `rmax_mult'
    di as text "Note: Delta calculated for Beta=`target_beta'. Rmax=Min(1, `s_rmax_mult'*R2)."
    di as text "Note: Use 'bootstrap' prefix for inference."
    di as text "{hline 88}"


    // --- Return Values for Bootstrap ---
    // Critical: These are what 'bootstrap' needs to grab
    return scalar beta_full  = `b_full'
    return scalar beta_base  = `b_base'
    return scalar r2_full    = `r2_full'
    return scalar r2_base    = `r2_base'
    return scalar beta_star  = `beta_star'
    return scalar delta_star = `delta_star'
    return scalar rmax       = `rmax_val'
    return local  reject_null "`s_reject'"

end

// -----------------------------------------------------------------------------
//  2. Sub-Programs
// -----------------------------------------------------------------------------

// 2.1 Variance components (PSACALC-consistent: controls from e(b))
program define _get_vars_consistent, rclass
    syntax, full_cmd(string) base_cmd(string) treatvar(string) touse(string) [wgt(string)]

    // Make a clean 0/1 sample indicator
    tempvar __touse
    quietly gen byte `__touse' = (`touse'==1)

    // Sort for TS operators if needed
    capture xtset
    if _rc == 0 & "`r(timevar)'" != "" {
        if "`r(panelvar)'" != "" quietly sort `r(panelvar)' `r(timevar)'
        else quietly sort `r(timevar)'
    }

    // Build runnable commands by injecting if `__touse'
    local run_full ""
    local run_base ""

    // full
    if strpos(`"`full_cmd'"', ",") > 0 {
        local f1 = substr(`"`full_cmd'"', 1, strpos(`"`full_cmd'"', ",") - 1)
        local f2 = substr(`"`full_cmd'"', strpos(`"`full_cmd'"', ","), .)
        local run_full `"`f1' if `__touse' `f2'"'
    }
    else local run_full `"`full_cmd' if `__touse'"'

    // base
    if strpos(`"`base_cmd'"', ",") > 0 {
        local b1 = substr(`"`base_cmd'"', 1, strpos(`"`base_cmd'"', ",") - 1)
        local b2 = substr(`"`base_cmd'"', strpos(`"`base_cmd'"', ","), .)
        local run_base `"`b1' if `__touse' `b2'"'
    }
    else local run_base `"`base_cmd' if `__touse'"'

    // 1) Run FULL model (controlled)
    tempname est_full est_base
    capture quietly `run_full'
    if _rc != 0 {
        return scalar sigma_yy = .
        return scalar sigma_xx = .
        return scalar t_x      = .
        exit
    }
    quietly estimates store `est_full'

    local depvar_act "`e(depvar)'"
    local cmd_full_now "`e(cmd)'"

    tempname __syy
    scalar `__syy' = .

    tempvar __kfix_y y_within
    quietly gen byte `__kfix_y' = 1

    if "`cmd_full_now'" == "xtreg" {
        capture quietly xtreg `depvar_act' `__kfix_y' `wgt' if `__touse', fe
        if _rc == 0 {
            capture quietly predict double `y_within' if e(sample), e
            if _rc == 0 {
                quietly summarize `y_within' if e(sample)
                scalar `__syy' = r(Var)
            }
        }
        quietly estimates restore `est_full'
    }
    else if "`cmd_full_now'" == "reghdfe" {
        local abs_f "`e(absvars)'"
        capture quietly reghdfe `depvar_act' `__kfix_y' `wgt' if `__touse', absorb(`abs_f') resid
        if _rc == 0 {
            capture quietly predict double `y_within' if e(sample), resid
            if _rc == 0 {
                quietly summarize `y_within' if e(sample)
                scalar `__syy' = r(Var)
            }
        }
        quietly estimates restore `est_full'
    }
    else {
        quietly summarize `depvar_act' if e(sample)
        scalar `__syy' = r(Var)
    }

    * 兜底：万一上述失败，至少给overall Var(y)
    if missing(`__syy') {
        quietly summarize `depvar_act' if `__touse'
        scalar `__syy' = r(Var)
        quietly estimates restore `est_full'
    }

    return scalar sigma_yy = `__syy'




    // Resolve treatment coefficient name in FULL model for list operations
    _cs_resolve_bname "`treatvar'"
    local treat_bname_full "`r(bname)'"
    if "`treat_bname_full'" == "" local treat_bname_full "`treatvar'"

    // Build FULL controls from e(b): colnames(e(b)) - _cons - treatment
    local full_vars : colnames e(b)
    local cons "_cons"
    local full_controls : list full_vars - cons
    local full_controls : list full_controls - treat_bname_full

    // 2) Run BASE model (uncontrolled)
    capture quietly `run_base'
    if _rc != 0 {
        return scalar sigma_xx = .
        return scalar t_x      = .
        quietly estimates restore `est_full'
        exit
    }
    quietly estimates store `est_base'

    // Resolve treatment coefficient name in BASE model
    _cs_resolve_bname "`treatvar'"
    local treat_bname_base "`r(bname)'"
    if "`treat_bname_base'" == "" local treat_bname_base "`treatvar'"

    // Build BASE controls from e(b): colnames(e(b)) - _cons - treatment
    local base_vars : colnames e(b)
    local base_controls : list base_vars - cons
    local base_controls : list base_controls - treat_bname_base

    // 3) Build treatment_var (psacalc-style, robust to ts ops; minimal support for c.a#c.b)
    tempvar treatment_var
    capture confirm variable `treatvar'
    if _rc == 0 {
        quietly gen double `treatment_var' = `treatvar' if `__touse'
    }
    else {
        // try direct expression first (works for L.x / F.x etc.)
        capture quietly gen double `treatment_var' = `treatvar' if `__touse'
        if _rc {
            local expr = "`treatvar'"
            local expr = subinstr("`expr'", "c.", "", .)
            local expr = subinstr("`expr'", "i.", "", .)
            local expr = subinstr("`expr'", "#", "*", .)
            quietly gen double `treatment_var' = `expr' if `__touse'
        }
    }

    // ---------------------------------------------------------
    // 4) sigma_xx: Var( resid( treatment_var | BASE controls + FE ) )
    // ---------------------------------------------------------
    quietly estimates restore `est_base'
    local cmd_base "`e(cmd)'"

    tempvar __kfix treat_res
    quietly gen byte `__kfix' = 1

    if "`cmd_base'" == "xtreg" {
        if "`base_controls'" != "" {
            capture quietly xtreg `treatment_var' `base_controls' `wgt' if `__touse', fe
        }
        else {
            capture quietly xtreg `treatment_var' `__kfix' `wgt' if `__touse', fe
        }
        if _rc != 0 {
            return scalar sigma_xx = .
            return scalar t_x      = .
            quietly estimates restore `est_full'
            exit
        }

        capture quietly predict double `treat_res' if e(sample), e
        if _rc != 0 {
            return scalar sigma_xx = .
            return scalar t_x      = .
            quietly estimates restore `est_full'
            exit
        }
        quietly summarize `treat_res' if e(sample)
        return scalar sigma_xx = r(Var)
    }
    else if "`cmd_base'" == "reghdfe" {
        local abs_b "`e(absvars)'"
        if "`base_controls'" != "" {

            capture quietly reghdfe `treatment_var' `base_controls' `wgt' if `__touse', absorb(`abs_b') resid
        }
        else {

            capture quietly reghdfe `treatment_var' `wgt' if `__touse', absorb(`abs_b') resid
        }
        if _rc != 0 {
            return scalar sigma_xx = .
            return scalar t_x      = .
            quietly estimates restore `est_full'
            exit
        }
        capture quietly predict double `treat_res' if e(sample), resid
        if _rc != 0 {
            return scalar sigma_xx = .
            return scalar t_x      = .
            quietly estimates restore `est_full'
            exit
        }
        quietly summarize `treat_res' if e(sample)
        return scalar sigma_xx = r(Var)
    }
    else {
        if "`base_controls'" != "" {
            capture quietly regress `treatment_var' `base_controls' `wgt' if `__touse'
        }
        else {
            capture quietly regress `treatment_var' `__kfix' `wgt' if `__touse'
        }
        if _rc != 0 {
            return scalar sigma_xx = .
            return scalar t_x      = .
            quietly estimates restore `est_full'
            exit
        }
        capture quietly predict double `treat_res' if e(sample), resid
        if _rc != 0 {
            return scalar sigma_xx = .
            return scalar t_x      = .
            quietly estimates restore `est_full'
            exit
        }
        quietly summarize `treat_res' if e(sample)
        return scalar sigma_xx = r(Var)
    }


    // ---------------------------------------------------------
    // 5) t_x: Var( resid( treatment_var | FULL controls + FE ) )
    // ---------------------------------------------------------
    quietly estimates restore `est_full'
    local cmd_full "`e(cmd)'"

    tempvar err_hat __kfix2
    quietly gen byte `__kfix2' = 1

    if "`cmd_full'" == "xtreg" {
        if "`full_controls'" != "" {
            capture quietly xtreg `treatment_var' `full_controls' `wgt' if `__touse', fe
        }
        else {
            capture quietly xtreg `treatment_var' `__kfix2' `wgt' if `__touse', fe
        }
        if _rc != 0 {
            return scalar t_x = .
            exit
        }
        capture quietly predict double `err_hat' if e(sample), e
        if _rc != 0 {
            return scalar t_x = .
            exit
        }
        quietly summarize `err_hat' if e(sample)
        return scalar t_x = r(Var)
    }
    else if "`cmd_full'" == "reghdfe" {
        local abs_f "`e(absvars)'"
        if "`full_controls'" != "" {

            capture quietly reghdfe `treatment_var' `full_controls' `wgt' if `__touse', absorb(`abs_f') resid
        }
        else {

            capture quietly reghdfe `treatment_var' `wgt' if `__touse', absorb(`abs_f') resid
        }
        if _rc != 0 {
            return scalar t_x = .
            exit
        }
        capture quietly predict double `err_hat' if e(sample), resid
        if _rc != 0 {
            return scalar t_x = .
            exit
        }
        quietly summarize `err_hat' if e(sample)
        return scalar t_x = r(Var)
    }
    else {
        if "`full_controls'" != "" {
            capture quietly regress `treatment_var' `full_controls' `wgt' if `__touse'
        }
        else {
            capture quietly regress `treatment_var' `__kfix2' `wgt' if `__touse'
        }
        if _rc != 0 {
            return scalar t_x = .
            exit
        }
        capture quietly predict double `err_hat' if e(sample), resid
        if _rc != 0 {
            return scalar t_x = .
            exit
        }
        quietly summarize `err_hat' if e(sample)
        return scalar t_x = r(Var)
    }

end


// 2.2 Mata Wrapper
program define _calc_oster_bounds, rclass
    syntax, b_o(real) b_tilde(real) ///
            r_o(real) r_tilde(real) ///
            rmax(real) ///
            sigma_yy(real) sigma_xx(real) t_x(real) ///
            delta_in(real) target_beta(real)

    if missing(`sigma_yy') | missing(`sigma_xx') | missing(`t_x') {
        return scalar beta_star = .
        return scalar delta_star = .
        exit
    }

    local s_bo   = string(`b_o',   "%20.15f")
    local s_bt   = string(`b_tilde',"%20.15f")
    local s_ro   = string(`r_o',   "%20.15f")
    local s_rt   = string(`r_tilde',"%20.15f")
    local s_rmax = string(`rmax',  "%20.15f")
    local s_syy  = string(`sigma_yy',"%20.15f")
    local s_sxx  = string(`sigma_xx',"%20.15f")
    local s_tx   = string(`t_x',     "%20.15f")
    local s_del  = string(`delta_in',"%20.15f")
    local s_bet  = string(`target_beta',"%20.15f")

    capture mata: cs_solve_main("`s_bo'", "`s_bt'", "`s_ro'", "`s_rt'", "`s_syy'", "`s_sxx'", "`s_tx'", "`s_del'", "`s_bet'", "`s_rmax'")
    if _rc != 0 {
        return scalar beta_star  = .
        return scalar delta_star = .
        exit
    }

    return scalar beta_star  = r(beta_star)
    return scalar delta_star = r(delta_star)
end

// 2.3 Helper: Get R2 (PSACALC-aligned)
program define _get_r2_new, rclass
    args cmdname

    if "`cmdname'" == "xtreg" {
        return scalar r2 = e(r2_w)
        exit
    }
    else if "`cmdname'" == "reghdfe" {
		return scalar r2 = e(r2_w)
		if missing(r(r2)) return scalar r2 = e(r2)
		exit
	}

    else {
        return scalar r2 = e(r2)
        exit
    }
end






// 2.4 Helper: Build Base Command (PSACALC-consistent)
program define _build_base_cmd, rclass
    args full_cmd treatvar

    local clean_full "`full_cmd'"
    local options ""
    if strpos("`clean_full'", ",") > 0 {
        local options = substr("`clean_full'", strpos("`clean_full'", ","), .)
        local clean_full = substr("`clean_full'", 1, strpos("`clean_full'", ",") - 1)
    }

    // cmd dep rhs
    gettoken cmd  rest : clean_full
    gettoken dep  rhs  : rest

    // PSACALC baseline: keep ONLY treatment (drop all controls incl. i.year)
    local base_cmd "`cmd' `dep' `treatvar' `options'"
    return local base_cmd "`base_cmd'"
end



// 2.5 Helper: Resolve Coef Name
program define _cs_resolve_bname, rclass
    args treatvar
    local names : colnames e(b)
    local match : list posof "`treatvar'" in names
    if `match' > 0 {
        return local bname "`treatvar'"
        exit
    }
    foreach n of local names {
        if strpos("`n'", "`treatvar'") > 0 {
             return local bname "`n'"
             exit
        }
    }
end

// -----------------------------------------------------------------------------
//  3. Mata Core (PSACALC Logic)
// -----------------------------------------------------------------------------
capture mata: mata drop cs_solve_main()
capture mata: mata drop cs_bound()
capture mata: mata drop cs_d1quadsol()
capture mata: mata drop cs_dnot1cubsol()

mata:

void cs_solve_main( string scalar Beta_o, string scalar Beta_tilde, string scalar R_o, string scalar R_tilde,
                    string scalar Sigma_yy, string scalar Sigma_xx, string scalar T_x,
                    string scalar Delta_in, string scalar Target_Beta, string scalar R_max)
{
    real scalar beta_o, beta_tilde, r_o, r_tilde, sigma_yy, sigma_xx, t_x, delta_in, beta_target, r_max
    real scalar bo_m_bt, rt_m_ro_t_syy, rm_m_rt_t_syy, delta_star, beta_star
    real scalar eps

    beta_o      = strtoreal(Beta_o)
    beta_tilde  = strtoreal(Beta_tilde)
    r_o         = strtoreal(R_o)
    r_tilde     = strtoreal(R_tilde)
    sigma_yy    = strtoreal(Sigma_yy)
    sigma_xx    = strtoreal(Sigma_xx)
    t_x         = strtoreal(T_x)
    delta_in    = strtoreal(Delta_in)
    beta_target = strtoreal(Target_Beta)
    r_max       = strtoreal(R_max)

    eps = 1e-10

    bo_m_bt = beta_o - beta_tilde
    rt_m_ro_t_syy = (r_tilde - r_o) * sigma_yy
    rm_m_rt_t_syy = (r_max - r_tilde) * sigma_yy

    delta_star = .
    cs_bound(delta_star, bo_m_bt, rt_m_ro_t_syy, rm_m_rt_t_syy, beta_tilde, beta_target, t_x, sigma_xx)

    if (abs(bo_m_bt) < eps | abs(r_tilde - r_o) < eps | abs(r_max - r_tilde) < eps) {
        beta_star = beta_tilde
        st_numscalar("r(beta_star)", beta_star)
        st_numscalar("r(delta_star)", delta_star)
        return
    }

    beta_star = .
    real scalar altsol1, altsol2, distx, dist1, dist2, markx, mark1, mark2

    if (delta_in == 1) {
        cs_d1quadsol(rm_m_rt_t_syy, rt_m_ro_t_syy, bo_m_bt, sigma_xx, t_x, beta_o, beta_star,
                    altsol1, beta_tilde, distx, dist1, markx, mark1)
        if (beta_star==. | abs(beta_star)>1e14) beta_star = beta_tilde
    }
    else {
        cs_dnot1cubsol(bo_m_bt, sigma_xx, delta_in, t_x, rm_m_rt_t_syy, rt_m_ro_t_syy, beta_star,
                       altsol1, altsol2, distx, dist1, dist2, beta_tilde, beta_o, markx, mark1, mark2)
        if (beta_star==. | abs(beta_star)>1e14) beta_star = beta_tilde
    }

    st_numscalar("r(beta_star)", beta_star)
    st_numscalar("r(delta_star)", delta_star)
}

void cs_bound( real scalar ds, real scalar bo_m_bt, real scalar rt_m_ro_t_syy, real scalar rm_m_rt_t_syy, real scalar beta_tilde, real scalar beta, real scalar t_x, real scalar sigma_xx)
{
    real scalar bt_m_b, num, den
    bt_m_b = beta_tilde - beta  
    
    num = (bt_m_b)*rt_m_ro_t_syy*t_x + (bt_m_b)*sigma_xx*t_x*(bo_m_bt)^2 + 2*(bt_m_b)^2*(t_x*bo_m_bt*sigma_xx) + ((bt_m_b)^3)*((t_x*sigma_xx-t_x^2))
    den = rm_m_rt_t_syy*bo_m_bt*sigma_xx + bt_m_b*rm_m_rt_t_syy*(sigma_xx-t_x) + (bt_m_b^2)*(t_x*bo_m_bt*sigma_xx) + (bt_m_b^3)*(t_x*sigma_xx-t_x^2)
    
    if (abs(den) < 1e-25) ds = . 
    else ds = num / den
}

void cs_d1quadsol( real scalar rm_m_rt_t_syy, real scalar rt_m_ro_t_syy, real scalar bo_m_bt, real scalar sigma_xx, real scalar t_x, real scalar beta_o, real scalar betax, real scalar altsol1, real scalar beta_tilde, real scalar distx, real scalar dist1, real scalar markx, real scalar mark1)
{
    real scalar cap_theta, d1_1, d1_2, sol1, sol2, beta1, beta2, solc
    cap_theta = rm_m_rt_t_syy*(sigma_xx-t_x) - rt_m_ro_t_syy*t_x - sigma_xx*t_x*(bo_m_bt^2)
    d1_1 = 4*rm_m_rt_t_syy*(bo_m_bt^2)*(sigma_xx^2)*t_x
    d1_2 = -2*t_x*bo_m_bt*sigma_xx
    
    if (abs(d1_2) < 1e-25) {
		betax = .
		return
	}

    sol1 = (-1*cap_theta - sqrt((cap_theta)^2 + d1_1))/(d1_2)
    sol2 = (-1*cap_theta + sqrt((cap_theta)^2 + d1_1))/(d1_2)
    beta1 = beta_tilde - sol1
    beta2 = beta_tilde - sol2
    
    if ( (beta1 - beta_tilde)^2 < (beta2 - beta_tilde)^2) {
        betax = beta1; altsol1 = beta2
    }
    else {
        betax = beta2; altsol1 = beta1
    }
    if ( sign(betax - beta_tilde) != sign(beta_tilde - beta_o) ) {
        solc = betax; betax = altsol1; altsol1 = solc
    }
    markx = 0; mark1 = 0
    if ( sign(betax - beta_tilde) != sign(beta_tilde - beta_o) ) markx = 1
    if ( sign(altsol1 - beta_tilde) != sign(beta_tilde - beta_o) ) mark1 = 1
    distx = (betax - beta_tilde)^2
    dist1 = (altsol1 - beta_tilde)^2
}

void cs_dnot1cubsol( real scalar bo_m_bt, real scalar sigma_xx, real scalar delta, real scalar t_x, real scalar rm_m_rt_t_syy, real scalar rt_m_ro_t_syy, real scalar betax, real scalar altsol1, real scalar altsol2, real scalar distx, real scalar dist1, real scalar dist2, real scalar beta_tilde, real scalar beta_o, real scalar markx, real scalar mark1, real scalar mark2)
{
    real scalar A, B, C, Q, R, D, discrim, theta, sol1, sol2, sol3, t1, t2, crt1, crt2
    real matrix sols, dists, min, w
    real scalar i, denom_term
    denom_term = (delta-1)*(t_x*sigma_xx - t_x^2)
    
    if (abs(denom_term) < 1e-25) {
		betax = .; return
	}

    A = (t_x*bo_m_bt*sigma_xx*(delta-2)) / denom_term
    B = (delta*rm_m_rt_t_syy*(sigma_xx-t_x) - rt_m_ro_t_syy*t_x - sigma_xx*t_x*bo_m_bt^2) / denom_term
    C = (rm_m_rt_t_syy*delta*bo_m_bt*sigma_xx) / denom_term
    
    Q = (A^2 - 3*B)/9
    R = (2*A^3 - 9*A*B + 27*C)/54
    D = R^2 - Q^3
    
    if (D < 0) {
        theta = acos(R/sqrt(Q^3))
        sol1 = -2*sqrt(Q)*cos(theta/3) - (A/3)
        sol2 = -2*sqrt(Q)*cos((theta + 2*pi())/3) - (A/3)
        sol3 = -2*sqrt(Q)*cos((theta - 2*pi())/3) - (A/3)
        sols = (sol1, sol2, sol3); sols = beta_tilde :- sols
        dists = (sols :- beta_tilde):^2
        for (i=1; i<=3; i++) {
            if ( sign(sols[i] - beta_tilde) != sign(beta_tilde - beta_o) ) dists[i] = max(dists) + 1e5
        }
        min = J(1,3,.); w = J(1,3,.)
        minindex(dists, 3, min, w)
        betax = sols[min[1]]; altsol1 = sols[min[2]]; altsol2 = sols[min[3]]
        distx = dists[min[1]]; markx=0; mark1=0; mark2=0
        if ( sign(betax - beta_tilde) != sign(beta_tilde - beta_o) ) markx=1
    }
    else {
        t1 = -1*R + sqrt(D); t2 = -1*R - sqrt(D)
        crt1 = sign(t1) * abs(t1)^(1/3); crt2 = sign(t2) * abs(t2)^(1/3)
        sol1 = crt1 + crt2 - (A/3)
        betax = beta_tilde - sol1
        markx = 0
        if ( sign(betax - beta_tilde) != sign(beta_tilde - beta_o) ) markx=1
    }
}
end
