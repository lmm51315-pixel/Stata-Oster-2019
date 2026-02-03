*===============================================================================
* 标题: Oster (2019) 敏感性分析案例复现与工具对比
* 任务: psacalc (旧) vs coefstability (新)
* 作者: [Ma Junhao]
* 日期: 2026-Spring
*===============================================================================

version 17.0
clear all
macro drop _all
set more off
set rmsg off        // 关闭运行时间消息

*===============================================================================
* 1. 环境设置与路径 (User Settings)
*===============================================================================
* 路径定义
global PP       "/Users/lmm/Documents/FE-马俊豪"   // 项目主目录
global path     "$PP"    
global data     "$path/data"                       // 数据存储路径
global output   "$path/out"   

* 切换目录
cd "$data"

* 图形模板
capture set scheme scientific  // 使用 capture 避免未安装报错

*===============================================================================
* CASE 1: Acheampong et al. (2024) Energy Economics 复现
* 重点: 循环对比不同控制变量组合下的稳健性
*===============================================================================

* 0. 载入数据
use "Acheampong-2024-EE-Oster-2019-omit-variable-test.dta", clear

* 1. 变量定义
global y_var            "lnco2kt"
global treat_var        "FI"
global core_controls    "lnrgdpc lnrgdpc2 lnrenew lnfdi lntrad lnurb"
global tlist            time2-time17 // 简写: time2 至 time17

local step_vars         baseline cc ge ps rq rl va

* 2. 输出设置
set linesize 130
local W = 130

* Bootstrap 参数
local B_reps  = 1000
local B_seed  = 12345
local B_level = 95

*-------------------------------------------------------------------------------
* 3. 循环估计与对比
*-------------------------------------------------------------------------------
foreach var of local step_vars {

    * --- A. 定义当前模型控制变量 ---
    if "`var'" == "baseline" {
        local current_controls "$core_controls"
        local model_name "Baseline"
    }
    else {
        local current_controls "$core_controls `var'"
        local model_name = cond(inlist("`var'","cc","ge","ps","rq","rl","va"), ///
                                "Control: " + upper("`var'"), ///
                                "Control: `var'")
    }
    
    local model_print = substr("`model_name'", 1, 20)

    * --- B. 运行基础回归 (Beta_OLS) ---
    quietly regress $y_var `current_controls' $treat_var $tlist, robust
    local b_orig = _b[$treat_var]

    * --- C. 旧方法 (psacalc) ---
    local delta_old = .
    local beta_old  = .
    
    capture psacalc delta $treat_var, rmax(1)
    if _rc == 0 local delta_old = r(delta)

    capture psacalc beta $treat_var, rmax(1)
    if _rc == 0 local beta_old = r(beta)

    * --- D. 新方法 (coefstability) ---
    local delta_new = .
    local beta_new  = .
    local ci_lb     = .
    local ci_ub     = .

    * D.1 点估计 (获取 beta_star / delta_star)
    local full_model `"regress $y_var `current_controls' $treat_var $tlist"'
    
    capture quietly coefstability $treat_var, ///
        model(`"`full_model'"') ///
        rmax(1000)              /// <- 小技巧: rmax倍数设大以确保 rmax=1
        delta(1)                ///
        beta(0)

    if _rc == 0 {
        local delta_new = r(delta_star)
        local beta_new  = r(beta_star)
    }

    * D.2 Bootstrap 推断
    tempfile bootfile
    capture quietly bootstrap   ///
        beta_star  = r(beta_star)  ///
        delta_star = r(delta_star), ///
        reps(`B_reps') seed(`B_seed') level(`B_level') ///
        nodots ///
        saving(`bootfile', replace) ///
        reject(missing(r(beta_star))) : ///
        coefstability $treat_var,       ///
            model(`"`full_model'"')     ///
            rmax(1000)                  ///
            delta(1)                    ///
            beta(0)

    if _rc == 0 {
        preserve
            quietly use `bootfile', clear
            capture quietly centile beta_star, centile(2.5 97.5)
            if _rc == 0 {
                local ci_lb = r(c_1)
                local ci_ub = r(c_2)
            }
        restore
    }

    * --- E. 格式化输出字符串 ---
    local s_d_old = cond(missing(`delta_old'), ".", string(`delta_old', "%6.3f"))
    local s_b_old = cond(missing(`beta_old'),  ".", string(`beta_old',  "%6.3f"))
    local s_d_new = cond(missing(`delta_new'), ".", string(`delta_new', "%6.3f"))
    local s_b_new = cond(missing(`beta_new'),  ".", string(`beta_new',  "%6.3f"))

    * Oster Set: [min(Beta_OLS, beta_star), max(...)]
    if !missing(`b_orig') & !missing(`beta_new') {
        local low   = min(`b_orig', `beta_new')
        local high  = max(`b_orig', `beta_new')
        local s_set = "[" + string(`low', "%6.3f") + "," + string(`high', "%6.3f") + "]"
    }
    else local s_set = "."

    * Bootstrap CI
    if !missing(`ci_lb') & !missing(`ci_ub') {
        local s_boot = "[" + string(`ci_lb', "%6.3f") + "," + string(`ci_ub', "%6.3f") + "]"
        
        * Robustness Check: CI 是否排除 0
        if (`ci_lb'>0 & `ci_ub'>0) | (`ci_lb'<0 & `ci_ub'<0) local s_rob "YES"
        else local s_rob "NO"
    }
    else {
        local s_boot = "."
        local s_rob  = "."
    }

    * --- F. 打印结果表格行 ---
    di _n ///
       "{result:{hline `W'}}" _n ///
       "{result:TABLE: Oster (2019) Stability Test - Method Comparison & Robustness}" _n ///
       "{result:{hline `W'}}" _n ///
       "{txt:Model Spec}{col 23}{txt:Delta(Old)}{col 35}{txt:Delta(New)}{col 47}{txt:Beta(Old)}{col 59}{txt:Beta(New)}{col 71}{txt:Oster Set}{col 90}{txt:Bootstrap95%CI}{col 121}{txt:Robust}" _n ///
       "{result:{hline `W'}}"   ///
       "{txt:`model_print'}"    ///
       "{col 23}{res:`s_d_old'}" ///
       "{col 35}{res:`s_d_new'}" ///
       "{col 47}{res:`s_b_old'}" ///
       "{col 59}{res:`s_b_new'}" ///
       "{col 71}{res:`s_set'}"   ///
       "{col 90}{res:`s_boot'}"  ///
       "{col 121}{res:`s_rob'}"
}


*===============================================================================
* CASE 2: Cepni et al. (2024) Energy Economics 复现
* 重点: reghdfe (Part 1) 与 xtreg (Part 2) 算法一致性对比
*===============================================================================

* 0. 数据准备与预处理
use "Cepni-2024-EE-xtabond2-DID-robust.dta", clear
xtset GVKEY_num year

* [预处理] 生成静态滞后变量 (psacalc 不支持时间序列算符)
local vars_to_lag ln_cc_expo_ew_w1 bm_w1 firm_size_w1 npm_w1 roa_w1 debt_at_w1 rd_sale_w1
foreach v of local vars_to_lag {
    capture drop L_`v'
    gen L_`v' = L.`v'
    label var L_`v' "Lagged `v'"
}

* 定义变量组
local y_var      "cost_of_equity_w1"
local treat_var  "L_ln_cc_expo_ew_w1"
local controls   "L_bm_w1 L_firm_size_w1 L_npm_w1 L_roa_w1 L_debt_at_w1 L_rd_sale_w1"
local cluster_id "GICIndustries"


*-------------------------------------------------------------------------------
* PART 1: 原文基准回归复现 (Based on reghdfe)
* psacalc 不支持 reghdfe，展示 coefstability 的原生支持能力
*-------------------------------------------------------------------------------
di _n as result "{hline 60}"
di as result ">>> PART 1: Benchmark Specification (reghdfe)"
di as result "{hline 60}"

* 1.1 定义命令
local cmd_reghdfe "reghdfe `y_var' `treat_var' `controls', absorb(GVKEY_num year) vce(cluster `cluster_id')"

* 1.2 运行原始回归
`cmd_reghdfe'

* 1.3 运行 coefstability (自动处理 Rmax = 1.3 * e(r2))
coefstability `treat_var',     ///
    model(`"`cmd_reghdfe'"')   ///
    delta(1)                   ///
    rmax(1.3)                  ///
    beta(0)                        


*-------------------------------------------------------------------------------
* PART 2: 算法一致性对比 (Based on xtreg)
* 统一使用 xtreg + i.year 确保 R2 口径一致
*-------------------------------------------------------------------------------
di _n as result "{hline 60}"
di as result ">>> PART 2: Algorithm Validation (xtreg vs. xtreg)"
di as result "{hline 60}"

local cmd_xtreg "xtreg `y_var' `treat_var' `controls' i.year, fe vce(cluster `cluster_id')"
`cmd_xtreg'

* --- A. 运行 coefstability (新程序) ---
coefstability `treat_var',     ///
    model(`"`cmd_xtreg'"')     ///
    delta(1)                   ///
    rmax(1.3)                  ///
    beta(0)                        

local beta_new  = r(beta_star)
local delta_new = r(delta_star)

* --- B. 运行 psacalc (旧程序) ---

* B.1 预回归：手动计算绝对值 Rmax (psacalc 不支持倍数输入)
quietly `cmd_xtreg'
local r2_within = e(r2_w)
local abs_rmax  = 1.3 * `r2_within'
if `abs_rmax' > 1 local abs_rmax = 1

di as text "   Within R2 (xtreg): " %6.4f `r2_within'
di as text "   Calculated Rmax:   " %6.4f `abs_rmax'

* B.2 计算 Beta* (delta=1)
psacalc beta `treat_var',      ///
    rmax(`abs_rmax')           /// 
    delta(1)                   ///
    model(`cmd_xtreg')

local beta_old = r(beta)

* B.3 计算 Delta* (beta=0)
psacalc delta `treat_var',     ///
    rmax(`abs_rmax')           ///
    beta(0)                    ///
    model(`cmd_xtreg')

local delta_old = r(delta)


*===============================================================================
* CASE 3: Bao et al. (2025) Management Science 复现
* 重点: areg (原文) vs reghdfe (新方法)
*===============================================================================

* 0. 数据准备
use "data_main.dta", clear

* PCA 降维
pca visual_positive visual_negative vocal_positive vocal_negative verbal
predict pc1 pc2 pc3, score

* 原文基准回归 (areg)
areg quality pc2 teacher_gender teacher_age teacher_experience age study gender, absorb(month)

*-------------------------------------------------------------------------------
* 1. 原始方法 (psacalc with areg)
*-------------------------------------------------------------------------------
* Rmax 设定为 0.40 (原文设定)

* Beta (Delta=1)
bs r(beta), rep(100): psacalc beta pc2, ///
    rmax(0.40) delta(1) ///
    model(areg quality pc2 teacher_gender teacher_age teacher_experience age study gender, absorb(month))

* Beta (Delta=1.5)
bs r(beta), rep(100): psacalc beta pc2, ///
    rmax(0.40) delta(1.5) ///
    model(areg quality pc2 teacher_gender teacher_age teacher_experience age study gender, absorb(month))

* Delta (Beta=0)
psacalc delta pc2, ///
    rmax(0.40) beta(0) ///
    model(areg quality pc2 teacher_gender teacher_age teacher_experience age study gender, absorb(month))


*-------------------------------------------------------------------------------
* 2. 新方法 (coefstability with reghdfe)
* 注意: rmax(1.3) 是指 Rmax = 1.3 * R2_full
*-------------------------------------------------------------------------------

* Beta (Delta=1)
bootstrap r(beta_star) r(delta_star), rep(100) seed(12345): /// 
    coefstability pc2,      ///
    model("reghdfe quality pc2 teacher_gender teacher_age teacher_experience age study gender, absorb(month)")  ///
    delta(1)                ///
    beta(0)                 ///
    rmax(1.3)
    
* Beta (Delta=1.5)
bootstrap r(beta_star), rep(100) seed(12345): ///
    coefstability pc2,      ///
    model("reghdfe quality pc2 teacher_gender teacher_age teacher_experience age study gender, absorb(month)")  ///
    delta(1.5)              ///
    beta(0)                 ///
    rmax(1.3)

*===============================================================================
* END OF FILE
*===============================================================================
