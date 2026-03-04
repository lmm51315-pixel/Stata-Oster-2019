# Stata 程序编写：Oster (2019) 系数稳定性检验的 Stata 实现

> **Source**: Oster, E. (**2019**). Unobservable Selection and Coefficient Stability: Theory and Evidence. **Journal of Business & Economic Statistics**, 37(2), 187–204. [Link](https://doi.org/10.1080/07350015.2016.1227711), [PDF](http://sci-hub.ren/10.1080/07350015.2016.1227711), [Google](<https://scholar.google.com/scholar?q=Unobservable Selection and Coefficient Stability: Theory and Evidence>). [-cited-5000次](https://scholar.google.com/scholar?cites=11936978270607540916&as_sdt=2005&sciodt=0,5&hl=zh-CN), [github-`coefstability`](https://github.com/gratzt/Coef-Stability-Oster)

> **作者：** 马俊豪 (中山大学岭南学院)
>
> **邮箱:**  <lmm51315@163.com>

**摘要** ：
在经验研究与因果推断中，评估遗漏变量偏误（Omitted Variable Bias）对估计结果的影响至关重要。传统上仅依赖“加入控制变量后系数是否稳定”的定性判断往往不够严谨，忽略了模型拟合优度（$R^2$）变动所蕴含的关键信息。基于 Oster (2019) 提出的理论框架，本文开发了 Stata 命令 `coefstability`，实现了系数稳定性检验的自动化。该命令通过对比基准模型与完整模型的系数及 $R^2$ 变化，结合不可观测变量的选择比例（$\delta$）与最大理论拟合优度（$R_{\max}$），计算经偏误调整后的处理效应（$\beta_{adj}$）及使效应归零的临界选择强度（$\delta^*$）。本文详细介绍了该命令的语法结构、参数设定及 Bootstrap 推断功能，并通过复现 *Energy Economics* 两篇近期文献（Acheampong & Said, 2024; Cepni et al., 2024），展示了其在截面与面板数据分析中的应用。`coefstability` 为研究者提供了一个便捷、严谨的工具，以量化评估实证结果的稳健性。

---

目录
[TOC]

# 1. 引言

因果推断研究中常常面临控制变量不完备导致的遗漏变量偏误问题。换言之，即使我们在回归中加入了一系列观察到的控制变量，仍可能存在未观察到的混杂因素影响处理效应的估计。经验研究者通常采用一种朴素的方法来评估遗漏变量偏误的风险：比较加入控制变量前后的系数是否稳定。如果在纳入观测控制变量后，处理效应的回归系数几乎没有变化，研究者往往据此认为遗漏变量偏误有限。然而，仅仅依赖系数的“稳定”并不足以保证因果推断的稳健性。正如 Oster（2019）指出的，判断未观察因素是否会推翻结果，不仅要看系数的变动，还应考虑模型拟合优度 $R^2$ 的变化。如果加入控制变量后 $R^2$ 大幅提升而系数几乎不变，这表明即使存在能提高 $R^2$ 的未观察变量，估计结果也不大可能被颠覆；反之，如果系数对控制变量非常敏感，即使 $R^2$ 提升不大，未观察变量仍可能对结果产生显著影响。

为了解决这一问题，Oster（2019）提出了一种形式化的系数稳定性检验方法，结合系数变动和 $R^2$ 变化来推断遗漏变量偏误可能造成的影响。她的方法引入了一个关键参数 $\delta$ 表示“未观察变量的选择偏向强度相对于已观察变量的比例”，并利用理论上的最大 $R^2$ （记作 $R_{\max}$）来推算在存在未观察混杂时处理效应系数可能达到的范围。本文介绍的 `coefstability` 命令由作者 马俊豪 开发，旨在将 Oster 方法在 Stata 中自动化，实现对处理效应估计稳健性的方便检验。通过该命令，研究者只需提供回归结果和假定的 $\delta$ 与 $R_{\max}$ 等参数，即可轻松评估未观察变量偏误对估计系数的潜在影响，从而为因果推断结果的稳健性提供更有力的支持。

---

# 2. 文献综述

敏感性分析（Sensitivity Analysis）在观测数据的因果推断中占据着核心地位。其理论渊源可追溯至 Cornfield 等（1959）关于吸烟与肺癌致病机理的开创性争论。此后，Rosenbaum 和 Rubin（1983）以及 Imbens（2003）等学者对相关理论进行了系统性拓展，旨在量化不可观测的混杂因素（unobserved confounders）对因果估计结果的潜在偏误程度。

在经济学与管理学实证研究领域，Altonji, Elder 和 Taber（2005）率先提出了一种基于“选择比率”的启发式策略，即通过比较引入控制变量前后的系数变化来推断遗漏变量的影响。Oster（2019）在此基础上构建了更为严谨的理论框架，论证了单纯的“系数稳定性”（coefficient stability）仅为识别的必要非充分条件，必须结合模型拟合优度（$R^2$）的变化来构建处理效应的识别边界（identified bounds）。凭借其直观的逻辑与坚实的理论基础，Oster 的方法近年来在权威期刊中得到了广泛应用。例如，Nunn 和 Wantchekon（2011）在早期研究中即应用了类似逻辑；近期文献如 Acheampong 和 Said（2024）关于金融包容性与净零排放的研究，Bao, Huang 和 Lin（2025）关于人工智能与性别平等的探讨，以及 Cepni, Şensoy 和 Yılmaz（2024）对气候变化暴露度的分析，均采用该方法验证结果的稳健性，以排除遗漏变量偏误的干扰。

伴随着敏感性分析理论的演进，Stata 软件社区涌现出一系列计算工具。Oster（2019）发布了 `psacalc` 命令作为其理论的基准实现，而 `psasvy` 则进一步扩展了对复杂抽样调查数据的支持。此外，Cinelli 和 Hazlett（2020）开发的 `sensemakr` 提供了一种基于部分 $R^2$ 的非参数敏感性分析框架，不再依赖于关于不可观测变量分布特征的强假设；Linden, Mathur 和 VanderWeele（2020）引入的 `evalue` 命令侧重于计算“E-value”，即解释现有关联所需的最小混杂强度。针对控制变量非外生的更一般情形，Masten 和 Poirier（2025）提出了相应的理论框架及 `regsensitivity` 命令；正如 Bazzi 等（2020）所指出，这在特定情境下修正了 Oster 方法的潜在局限。

尽管现有工具已较为丰富，但在应用 Oster（2019）这一主流方法时，研究者仍面临诸多实操层面的挑战。作为早期工具，`psacalc` 在兼容高维固定效应（如 `reghdfe`）、批量结果输出以及标准误推断（Inference）等方面存在局限，且在处理 `areg` 与 `xtreg` 的固定效应模型时表现出不一致性。为此，本文开发了 `coefstability` 命令以填补这一技术缺口。该命令严格遵循 Oster（2019）的理论推导，能够自动计算并输出经偏误调整后的处理效应 $\beta_{adj}$ 及临界值 $\delta^*$。此外，该命令优化了语法结构，显著提升了用户体验，协助研究者在截面与面板数据中高效复现如 Acheampong 和 Said（2024）等文献的稳健性检验结果，为实证研究提供了一个严谨且高效的遗漏变量偏误评估工具。

--- 
# 3. Oster（2019） 文章理论回顾

本节旨在阐明传统处理遗漏变量偏误（Omitted Variable Bias, OVB）方法的局限性，并系统阐述Oster（2019）提出的检验方法及其数理基础。

## 3.1 一个直观可算的数学例子

传统研究中，研究者常以“加入控制变量后核心解释变量的系数保持稳定”为依据，推断遗漏变量偏误可能不严重。Oster（2019）指出，仅依赖“系数稳定性”这一标准并不可靠。本节通过一个简化的教育回报率示例，说明单独观察系数变动可能导致的误判，并论证必须同时考察系数与模型拟合优度（$R^2$）的联合变动。

### 3.1.1 基本假设

具体地，考虑一个真实工资决定式：

$$
Y=\beta X+W+C,
$$

其中：

- $X$：教育（treatment），**假设其真实效应为零**
- $W,C$：能力(ability)的两个**正交**分量

并且：

1. **方差差异**：$\text{Var}(W)\gg \text{Var}(C)$（$W$是“高方差能力”，$C$是“低方差能力”）。
2. **与$X$的关系“相同”**：把$X$分别对$W$或对$C$做一元回归，得到的斜率相同：

$$
\pi \equiv \frac{\text{Cov}(X,W)}{\text{Var}(W)}
      = \frac{\text{Cov}(X,C)}{\text{Var}(C)}.
$$

则当**真实效应为零**时，可以得到：

$$
Y=W+C
$$

假设我们只能观测到一个能力代理变量：要么观察到$W$，要么观察到$C$。

---

### 3.1.2 “只关注系数稳定”的问题

如果我们只观测到了C，那么此时看“无控制”与“控制$C$”的对比：

- 无控制：

$$
\hat\beta^{\,0}
=\frac{\text{Cov}(X,W)+\text{Cov}(X,C)}{\text{Var}(X)}.
$$

- 控制$C$：

$$
\hat\beta^{\,C}
=\frac{\text{Cov}(X,W)}
{\text{Var}(X)-\frac{\text{Cov}(X,C)^2}{\text{Var}(C)}}.
$$

如果$\text{Var}(C)$很小，那么$\text{Cov}(X,C)$也会很小（在“回归$X$对$C$与对$W$斜率相同”的假设下更是如此：$\text{Cov}(X,C)=\pi\text{Var}(C)$）。
于是：

- $\hat\beta^{\,0}$里那项$\text{Cov}(X,C)$本来就很小；
- $\hat\beta^{\,C}$的分母修正项$\text{Cov}(X,C)^2/\text{Var}(C)$也很小（数量级是$\text{Var}(C)$）。

因此会出现：

$$
\hat\beta^{\,C}\approx \hat\beta^{\,0}.
$$

这制造了一种系数稳定的表象：控制一个低方差的代理变量后，$X$ 的系数变动甚微。然而，由于真实效应 $\beta = 0$，而 $\hat\beta^{,0}$ 与 $\hat\beta^{,C}$ 皆可能显著不为零，其偏误根源在于遗漏的高方差能力分量 $W$ 仍然存在。

---

### 3.1.3 引入 $R^2$ 变动作为诊断工具

系数稳定而偏误仍在，关键在于控制变量 $C$ 对结果变量 $Y$ 的解释力很弱。这一缺陷可通过考察模型 $R^2$ 的变动来揭示。

- **无控制时R²**：
  在简单回归 $Y\sim X$ 下：

  $$
  R_0^2=\frac{\text{Cov}(X,Y)^2}{\text{Var}(X)\text{Var}(Y)}.
  $$

  因为$\beta=0\Rightarrow Y=W+C$ 且 $W\perp C$，

  $$
  \text{Var}(Y)=\text{Var}(W)+\text{Var}(C),
  \quad
  \text{Cov}(X,Y)=\text{Cov}(X,W)+\text{Cov}(X,C).
  $$
- **控制$W$时R²**：
  在回归 $Y\sim X+W$ 中，$W$本身就是$Y$里的一个大块分量（$\text{Var}(W)$很大），因此仅仅加入$W$就能解释掉几乎$\text{Var}(W)$这么多的方差。
  更形式化地：控制$W$后，$Y-W=C$，此时额外由$X_W$解释的只是$C$的一小部分，所以

$$
R_{X,W}^2
\approx \frac{\text{Var}(W)}{\text{Var}(W)+\text{Var}(C)}
\approx 1.
$$

- **控制$C$时R²**：
  在回归 $Y\sim X+C$ 中，加入$C$最多也只能“直接”解释掉$\text{Var}(C)$这部分方差。
  而$\text{Var}(C)$很小，因此即使加入$C$，R²的增量也会很小：

$$
R_{X,C}^2 - R_0^2 \ \text{通常很小}.
$$

这正是“低方差控制变量信息含量低”的诊断：**它既没怎么改变系数，也没怎么提升R²。**

---

### 3.1.4 小结

只考虑系数的稳定性并不稳妥，还需要把$R^2$的运动纳入进来，因为如果控制变量对解释结果变量的方差几乎没有贡献（$R^2$变动极小），那么即使系数非常稳定，也可能只是因为这些控制变量本身“质量很差”，不足以消除潜在的偏误

## 3.2  Oster (2019) 提出的系数稳定性检验方法

本节旨在阐述清楚 Oster (2019) 提出的系数稳定性检验方法的数理基础,以及其中一些重要参数的选取标准与经验。

### 3.2.1 模型设定与基本假设

我们首先描述 Oster (2019) 在第三节中使用的线性模型设定和符号约定。
考虑线性回归模型：

- **基本模型：** $Y = \beta X + W_1 + W_2 + \varepsilon$
- 其中：$X$ 是处理变量（标量），$Y$ 是结果变量。$W_1$ 表示**观测到的**混淆因素的**指数**（index），$W_2$ 表示**未观测到的**混淆因素的指数，$\varepsilon$ 是独立误差项。模型中 $W_1$ 和 $W_2$ 分别代表已控制和未控制的混杂影响，两者均以**系数1**加权进入结果方程，这意味着我们已将观测控制变量的线性组合 $W_1$ 定义为它们对 $Y$ 的总贡献。
- **正交性假定：** 假定 $W_1$ 与 $W_2$ 正交，即相关系数为0。这意味着观测到的控制因素 $W_1$ 与未观测因素 $W_2$ 没有关联，从而将观测组和未观测组的影响区分开来。这一假设主要是为了方便推导**比例选择关系**，实际只要存在某个 $\delta$ 满足比例关系，该假设并不失一般性。
- **比例选择系数 $\delta$：** 定义**选择比例关系**为

  $$
  \delta \frac{\sigma_{1X}}{\sigma_1^2} \;=\; \frac{\sigma_{2X}}{\sigma_2^2},
  $$

  其中 $\sigma_{iX} = \mathrm{Cov}(W_i, X)$ 是 $W_i$ 与处理 $X$ 的协方差，$\sigma_i^2 = \mathrm{Var}(W_i)$ 是 $W_i$ 的方差（$i=1,2$ 分别对应观测和未观测部分）。系数 $\delta$ 度量了**未观测变量与处理的关联强度相对于观测变量的关联强度**：当 $\delta = 1$ 时表示**观测变量和未观测变量对处理的选择偏差程度相同**（“等比例选择”）；$\delta > 1$ 表示未观测部分相对于观测部分更强（更严重的选择偏差），而 $\delta < 1$ 则表示未观测部分相对较弱。
- **回归系数与 $R^2$ 定义：** 不包含任何控制时回归 $Y$ 关于 $X$ 的系数记为 $\beta_u$，对应的 $R^2$ 记为 $R^2_u$。包含观测控制 $\omega_o$（即 $W_1$ 所代表的控制集合）时的回归系数记为 $\beta_c$，$R^2$ 记为 $R^2_c$。设想如果能够控制全部观测和未观测变量，则该“完全回归”中 $X$ 的系数为真实的因果效应 $\beta$，其对应的理论 $R^2$ 记为 $R^2_{\max}$。
  注意：$R^2_{\max}$ 是一个理论上的上限值，满足 $R^2_c \le R^2_{\max} \le 1$。

上述设定中，$\beta_u$ 和 $\beta_c$ 都可能因为遗漏变量偏误而偏离真实效应 $\beta$。$\beta_u$ 是只含处理的“短回归”系数，包含了由于遗漏 **$W_1$** 和 **$W_2$** 导致的偏误；$\beta_c$ 是包含观测控制的“中间回归”系数，只剩下遗漏 **$W_2$** 导致的偏误。我们用这些符号正式推导命题1至3所述的结果。

---

### 3.2.2 命题1：有约束情形下的偏误调整估计（等比例选择，$\delta = 1$）

在一个**受限的情形**下给出了偏误校正后系数的解析形式和一致性。这个受限情形采用了两个额外假设：

- **假设 1（等比例选择）**：$\delta = 1$，即默认观测与未观测混杂对处理的关联程度相同；
- **假设 2**：观测控制中各变量对 $X$ 和对 $Y$ 的相对贡献保持相同比例。第二个假设技术上保证了当我们以 $W_1$ 指数代表所有观测控制时，不会因各控制影响力不均而引入偏差——直观而言，它要求“每个观测控制对 $X$ 的解释力与其对 $Y$ 的影响力成比例”。虽然在实际中多个控制很难严格满足这一关系，但如果偏离不严重，结果仍近似成立。在这两个假设下，我们可以得到**偏误一致估计**的简单形式。

**1. 系数偏误的表达：**

利用线性回归遗漏变量偏误公式，表示 $\beta_u$ 和 $\beta_c$ 的偏差部分。由于 $W_1, W_2$ 在结构方程中系数为1：

*   **无控制回归的系数 $\beta_u$：** 包含所有遗漏偏误。由 $Y = \beta X + W_1 + W_2 + \varepsilon$，有

    $$
    \beta_u \;=\; \beta + \frac{\mathrm{Cov}(X,\,W_1 + W_2)}{\mathrm{Var}(X)} \;=\; \beta + \frac{\sigma_{1X} + \sigma_{2X}}{\sigma_X^2}\,.
    $$

    其中附加项 $\frac{\sigma_{1X} + \sigma_{2X}}{\sigma_X^2}$ 正是由于遗漏 $W_1, W_2$ 引入的总偏误。

*   **有观测控制回归的系数 $\beta_c$：** 仅遗漏 $W_2$ 的偏误。对 $Y$ 关于 $X$ 和 $W_1$ 回归，$W_1$ 已包含在回归中，只剩 $W_2$ 的影响未被控制。此时 $X$ 的系数由对 $W_2$ 的遗漏引起偏误：

    $$
    \beta_c \;=\; \beta + \frac{\mathrm{Cov}(X,\,W_2 \mid W_1)}{\mathrm{Var}(X \mid W_1)}\,.
    $$

    由于 $W_1$ 与 $W_2$ 正交，$\mathrm{Cov}(X, W_2 \mid W_1) = \mathrm{Cov}(X,W_2) = \sigma_{2X}$。而 $\mathrm{Var}(X \mid W_1) = \sigma_X^2 - \frac{\sigma_{1X}^2}{\sigma_1^2}$：这体现了控制 $W_1$ 后 $X$ 剩余的方差（记作 $\tau_x$）。因此，

    $$
    \beta_c \;=\; \beta + \frac{\sigma_{2X}}{\sigma_X^2 - \frac{\sigma_{1X}^2}{\sigma_1^2}} \;=\; \beta + \frac{\sigma_{2X}}{\tau_x}\,.
    $$

  该偏误项可进一步用 $\delta=1$ 简化：当 $\delta=1$，根据比例选择关系有 $\sigma_{2X}/\sigma_2^2 = \sigma_{1X}/\sigma_1^2$，从而 $\frac{\sigma_{2X}}{\tau_x} = \frac{\sigma_{2X}}{\sigma_X^2 - \sigma_{1X}^2/\sigma_1^2}$。
  方便起见：记 $\phi = \beta_c - \beta$ 为在包含观测控制后的剩余偏误（即遗漏 $W_2$ 导致的偏误）。

- 基于以上，$\beta_u$ 与 $\beta_c$ 的关系可以写为：
  $$
  \beta_u - \beta_c \;=\; \frac{\sigma_{1X} + \sigma_{2X}}{\sigma_X^2} \;-\; \frac{\sigma_{2X}}{\sigma_X^2 - \frac{\sigma_{1X}^2}{\sigma_1^2}}\,,
  $$

  而 $\beta_c - \beta = \phi$（此时 $\phi$ 也可写成上述差式的等价形式）。为了获得校正偏误的估计量，我们需要将 $\phi$ 解出并扣除。

**2. 系数变化与 $R^2$ 变化的比例关系**：

在假设 $\delta=1$ 下，Oster 证明了一个重要的比例关系：**系数移动的比例等于 $R^2$ 移动的比例**。也就是说，在等比例选择假设下：

$$
\frac{\beta_c - \beta}{\,\beta_u - \beta_c\,} \;=\; \frac{R^2_{\max} - R^2_c}{\,R^2_c - R^2_u\,}\,
$$

其中左边是“**系数减少量**与**剩余偏误量**之比”，右边是“**已解释 $R^2$ 增量**与**剩余未解释 $R^2$ 比率**”。

理解这一比例关系的直观含义：当观测变量和未观测变量对处理的关联程度相同（$\delta=1$）时，**加入观测控制所导致的系数变化比例，应该等于这些控制对 $R^2$ 的贡献比例**。换言之，如果观测控制已经消除了相对于全部混杂因素的一定比例的偏误，那么它们也解释了相应比例的结果方差；二者比例相同意味着观测部分与未观测部分在影响上的对称性。只有当未观测混杂的方差不同于观测混杂时，这一比例关系才会偏离1，但这部分差异正好体现为 $R^2$ 贡献的差异。

**3. 偏误调整系数的解：**
利用上述比例关系，我们可以求解未观测偏误 $\beta_c - \beta$ 并构造偏误调整后的系数估计。根据比例关系可得：

$$
\beta_c - \beta \;=\; (\beta_u - \beta_c)\,\frac{R^2_{\max} - R^2_c}{\,R^2_c - R^2_u\,}\,.
$$

将右侧表示的偏误量从包含控制的系数中扣除，即可得到**校正后的处理效应估计** $\beta^*$：

$$
\beta_{adj} \;=\; \beta_c \;-\; \Big(\beta_u - \beta_c\Big)\,\frac{R^2_{\max} - R^2_c}{\,R^2_c - R_u\,}\,.
$$

这一公式正是 Oster (2019) 在命题1中给出的结果。

**4. 命题1的结论与验证：** 根据推导，所定义的 $\beta^*$ 是对真实系数 $\beta$ 的一致估计，即在样本量趋于无穷时 $\beta_{adj} \xrightarrow{p} \beta$。**命题1**正式表述为：在假设 1 和 2 下，所构造的

$$
\beta_{adj} = \beta_c - (\beta_u - \beta_c)\frac{R^2_{\max} - R^2_c}{R^2_c - R^2_u}
$$

满足 $\beta_{adj} \overset{p}{\to} \beta$。

**5. 直观解释：** **命题1**强调了**系数稳定性结合 $R^2$ 变化**在推断偏误时的重要作用。等比例选择假设下，观测控制对系数的影响程度可以直接比照其对 $R^2$ 的影响来推断未观测偏误。若加入控制变量后系数几乎不变但 $R^2$ 提升显著，那么根据上述公式计算出的 $\beta^*$ 将非常接近原始系数，暗示未观测偏误也许很小（结果稳健）；反之，如果加入控制后系数剧烈变化而 $R^2$ 变化不大，则 $\beta^*$ 调整值偏离 $\beta_1$ 较远，提示潜在的未观测偏误较大。因此，在 **$\delta = 1$** 框架下，**“系数的稳定”只有结合“$R^2$的稳定”才能判断稳健性**。

---

### 3.2.3 命题2：无约束情形下的广义估计（精确解算法）

**命题2**放松了命题1中的假设，讨论更加一般的情形（允许 $\delta \neq 1$，且不要求各控制变量的贡献完全成比例）。在这种**非约束**情况下，我们仅保留基本的**假设1**（观测与未观测成比例选择），但允许 $\delta$ 为任意给定值。这是 Oster（2019）方法中最通用的形式。

**1. 引入关键参数 $\tau_x$**
无约束估计需要引入处理变量 $X$ 的残差方差 $\tau_x = \mathrm{Var}(X \mid W_1)$。具体定义如下：
*   $\sigma_X^2$：处理变量 $X$ 的总方差。
*   $\tau_x$：剔除观测控制变量（保留固定效应）影响后，$X$ 中剩余的变异。
这一参数衡量了观测控制变量在多大程度上解释了处理变量 $X$。在 `coefstability` 命令中，程序会根据模型类型（如 `areg`, `xtreg`）准确计算组内方差作为 $\tau_x$。

**2. 偏误 $\nu$ 的多项式方程**
Oster (2019) 证明，真实的偏误调整量 $\nu$（即 $\beta^* = \tilde{\beta} - \nu$ 中的 $\nu$）必须满足以下多项式方程 $f(\nu) = 0$：

$$
A\nu^3 + B\nu^2 + C\nu + D = 0
$$

其中各项系数定义为：
*   $A = (\delta - 1)(\tau_x \sigma_X^2 - \tau_x^2)$
*   $B = \tau_x (\beta_u - \beta_c) \sigma_X^2 (\delta - 2)$
*   $C = \delta (R^2_{\max} - R^2_c)\sigma_y^2 (\sigma_X^2 - \tau_x) - (R^2_c - R^2_u)\sigma_y^2 \tau_x - \sigma_X^2 \tau_x (\beta_u - \beta_c)^2$
*   $D = \delta (R^2_{\max} - R^2_c)\sigma_y^2 (\beta_u - \beta_c) \sigma_X^2$

**3. 精确解的解析式与算法实现**

不同于部分文献使用的线性近似公式，本命令（`coefstability` v3.3.0）在底层通过 Mata 语言复刻了 `psacalc` 的核心算法，直接求解上述方程的**精确根**。根据 $\delta$ 的取值，算法分为两种路径：

#### (1) 当 $\delta = 1$ 时（降阶为二次方程）
此时三次项系数 $A=0$，方程退化为一元二次方程 $B\nu^2 + C\nu + D = 0$。程序使用标准的求根公式：

$$
\nu_{1,2} = \frac{-C \pm \sqrt{C^2 - 4BD}}{2B}
$$

#### (2) 当 $\delta \neq 1$ 时（卡尔丹公式求解三次方程）
此时方程为完整的三次方程。程序采用经典的**卡尔丹公式（Cardano's Formula）** 结合三角解法进行求解：
1.  **标准化**：将方程转化为 $x^3 + ax^2 + bx + c = 0$ 的形式。
2.  **消去二次项**：通过变量代换 $x = y - a/3$，将方程转化为不含二次项的压缩形式 $y^3 + py + q = 0$。
3.  **判别式判定**：计算判别式 $\Delta = (q/2)^2 + (p/3)^3$。
    *   若 $\Delta \ge 0$：存在一个实根，使用立方根公式直接求解。
    *   若 $\Delta < 0$（不可约情形）：存在三个不相等的实根。程序利用三角函数形式求解：
        $$
        y_k = 2\sqrt{-\frac{p}{3}} \cos\left( \frac{1}{3} \arccos\left(\frac{3q}{2p}\sqrt{-\frac{3}{p}}\right) - \frac{2\pi k}{3} \right), \quad k=0,1,2
        $$

**4. 根的筛选（假设 3）**
当方程存在多个实根时，程序依据 Oster (2019) 的**假设 3 (Assumption 3)** 进行筛选：
*   计算每个根对应的 $\beta_{adj} = \beta_c - \nu$。
*   选择使得“调整后系数 $\beta_{adj}$”与“完整模型系数 $\beta_c$”的距离最小，且未观测偏误方向合理的那个根。
*   具体而言，程序会惩罚那些导致 
$$
\text{Sign}(\text{cov}(X, \text{Unobserved})) \neq \text{Sign}(\text{cov}(X, \text{Observed}))
$$ 
的解，从而识别出具有经济学意义的唯一解。

**4. 根的判定与解的选择**
由于三次方程可能有1个或3个实根，命题2定义了两种情形：
*   **情形1（单实根）**：如果 $f(\nu)$ 只有一个实根 $\nu_1$，则无歧义，校正后的系数为 $\beta_{adj} = \beta_c - \nu_1$。
*   **情形2（多实根）**：如果存在三个实根，则形成一个解集。为了从多重解中识别出“真解”，Oster 提出了**假设3（Assumption 3）**。
    *   **假设3的内容**：假设未观测变量产生的偏误幅度不足以改变 $X$ 与控制变量组之间协方差的符号（$\text{Sign}(\text{cov}(X, \hat{W}_1)) = \text{Sign}(\text{cov}(X, W_1))$）。
    *   **实际操作**：在 $\delta=1$ 的情况下，通常选择使得 $R^2$ 变动与系数变动逻辑一致的那个根（valid root）。

**5. 近似解：** 虽然上述的精确解处理起来非常复杂，且严格证明较为繁琐，但在论文中 Oster（2019） 提供了一个近似的**解析表达**来增强直觉。该表达表明，在放松等比例选择假设时，偏误调整公式相对于命题1出现一个简单的 $\delta$ 倍率因子：

$$
\beta_{adj} \approx \beta_c \;-\; \delta\,(\beta_u - \beta_c)\,\frac{R^2_{\max} - R^2_c}{\,R^2_c - R^2_u\,}\,.
$$

可以看出，当 $\delta=1$ 时，这就退化为命题1的结果；而 $\delta$ 越大（未观测选择偏差越严重），调整量就相应放大，$\beta_{adj}$ 会离 $\beta_c$ 较远。这一近似公式**并非严格证明的估计量**，而是基于附加假设得到的简化形式，但在许多情形下非常接近精确解。因此，研究者在应用中经常直接使用这一公式作为稳健性分析的计算工具，只需为 $\delta$ 选择适当值即可。

**6. 算法声明**：
本命令未采用 $\beta_{adj} \approx \beta_c - \delta(\beta_u - \beta_c)\frac{R^2_{\max} - R^2_c}{R^2_c - R^2_u}$ 这一近似公式，而是**完全复刻了 Oster 官方代码 `psacalc` (v2.1) 中的 `d1quadsol`（二次解）和 `dnot1cubsol`（三次解）Mata 函数**。这确保了即便在 $R^2$ 变化较大或 $\delta$ 远离 1 的极端情形下，计算结果依然精确可靠。

---

### 3.2.4 命题3：使处理效应为0的 $\delta$ 解（反推所需的选择比例）
命题3关注的不是直接求 $\beta$，而是反过来**求出使某指定效应值成立所需的 $\delta$**。特别地，一个重要应用是计算**需要多大的未观测选择偏差（相对于观测偏差）才能使处理效应归零**。这一命题对于稳健性分析意义重大，因为它回答了一个政策研究常问的问题：“**需要多少未观测偏差可以解释掉当前结果？**”

**1. 命题3的定义：** 令 $\hat{\beta}$ 表示我们关注的某一特定效应值（例如 0，以检验零效性假设）。命题3将 $\hat{\delta}$ 定义为：在给定 $R_{\max}$ 的情况下，使真实效应 $\beta = \hat{\beta}$ 所需的比例系数。换言之，$\hat{\delta}$ 满足当 $\delta = \hat{\delta}$ 时，通过命题2的调整公式得到 $\beta_{adj} = \hat{\beta}$。命题3推导了 $\hat{\delta}$ 的显式表达式。给定 $R_{\max}$ 和目标真实系数 $\beta$（例如设 $\beta=0$），我们可以反向求解出对应的 $\delta^*$。

Oster 推导出的 $\delta^*$ 表达式如下（基于设定 $\Pi = \tilde{\beta} - \beta$ 代入上述三次方程反解 $\delta$）：

$$
\delta^* = \frac{(\tilde{\beta} - \beta)(\tilde{R} - \mathring{R})\sigma_y^2 \tau_x + (\tilde{\beta} - \beta)\sigma_X^2 \tau_x (\mathring{\beta} - \tilde{\beta})^2 + 2(\tilde{\beta} - \beta)^2 (\tau_x (\mathring{\beta} - \tilde{\beta})\sigma_X^2) + (\tilde{\beta} - \beta)^3 (\tau_x \sigma_X^2 - \tau_x^2)}{(R_{\max} - \tilde{R})\sigma_y^2 (\mathring{\beta} - \tilde{\beta})\sigma_X^2 + (\tilde{\beta} - \beta)(R_{\max} - \tilde{R})\sigma_y^2 (\sigma_X^2 - \tau_x) + (\tilde{\beta} - \beta)^2 (\tau_x (\mathring{\beta} - \tilde{\beta})\sigma_X^2) + (\tilde{\beta} - \beta)^3 (\tau_x \sigma_X^2 - \tau_x^2)}
$$

尽管公式繁琐，但这个结果直观地表示：当前观测系数占未解释系数移动量的比例，与剩余方差占已解释方差的比例之比，决定了需要的 $\delta$。如果 $\beta_c$ 非常接近 $\beta_u$（控制前后系数几乎不变），则 $\beta_c/(\beta_u-\beta_c)$ 很大，意味着即便未观测偏误相当弱（小的 $\hat{\delta}$）也难以将效应推至0；反之，如果加入控制后系数已经剧烈衰减（$\beta_c \ll \beta_u$），则可能一个较小的 $\delta$ 即足以将系数完全削弱至0。

命题3严格的推导给出了普遍形式的 $\hat{\delta}$ 公式。在应用中，我们通常将注意力放在 **$\hat{\beta}=0$** 的情况，并据此报告“解释结果为零所需的 $\delta$”。这也被称为 **“Oster's $\delta$”** 或 **“程度阈值”**。例如，如果计算得到 $\hat{\delta} = 2$，意味着**未观测变量与处理的关联强度需要是观测变量的两倍**才能将当前估计系数归零；相应地，若 $\hat{\delta} = 0.5$，则只要未观测偏差强度达到观测的一半就足以推翻结果。

**2. 解释和意义：**$\hat{\delta}$ 提供了一种**鲁棒性阈值**的衡量。一般地，若得到的 $\hat{\delta}$ 很大（远大于1），表示需要极强的未观测偏差才能使结果消失——这通常被解读为结果相当稳健，因为我们认为现实中未观测因素不太可能比已观测因素更强地影响处理选择。相反，如果 $\hat{\delta}$ 小于1，甚至接近0，则说明即使未观测偏差比观测的弱很多，也可能推翻结果——此时结果的稳健性令人担忧。经验上一般采用 $\hat{\delta}=1$ 作为经验判断的分界线：$\hat{\delta} > 1$ 被视为观测的控制已经足够重要（**观测因素至少和未观测因素一样重要**），结果比较稳健；而 $\hat{\delta} < 1$ 则提示需要警惕未观测偏差的问题。

需要注意的是，$\hat{\delta}$ 的计算需要先行假定 $R^2_{\max}$ 值（因为 $\hat{\delta}$与 $R^2_{\max}$ 相关）。因此在使用命题3时，我们往往**先取定一个 $R^2_{\max}$**，然后求对应的 $\hat{\delta}$。下一节将讨论 $R_{\max}$ 的选取策略。

---

### 3.2.5 参数选取与稳健性评估

在实践中，以上理论命题需要结合具体假定的参数来评估处理效应的稳健性。具体地，包括如何选择 $R^2_{\max}$ 和 $\delta$，如何据此生成系数的边界集合，以及如何解释这些结果来判断稳健性。

**1. 选择 $R^2_{\max}$（可解释的最大 $R^2$）：**

- $R^2_{\max}$ 决定了我们认为“如果包含所有相关变量，模型最多可以解释结果方差多少”。显然 $R^2_{\max}$ 必在当前 $R^2_c$ 和1之间（因为加入未观测变量只能提高 $R^2$ 但不可能超过 1 ）。
- 在没有额外信息时，一个常用做法是设定 **$R^2_{\max} = 1.3 \times R^2_c$** 作为经验值。这一特定选择来自 Oster 对随机实验数据的分析，发现若把 $R^2_{\max}$ 取为观测回归 $ R^2_c $ 的1.3倍，约有45%的非随机研究结果在该标准下仍能幸存，被认为是稳健的。
- 当然，$R^2_{\max} $的取值应结合具体研究背景：如果我们认为即使加入所有潜在变量也不可能解释非常高比例的 $Y$ 方差（例如因为 $Y$ 有很大随机噪音），可以将 $R^2_{\max}$ 设得较低；反之，如果怀疑遗漏了非常关键的解释变量，可以取较高的 $R^2_{\max}$。总之，$R^2_{\max}$ 反映了研究者对结果中不可解释变异的预估，是稳健性检验中的一个关键敏感参数。
- 举例: 在某些劳动经济学研究中，$R^2_c$ （已有控制的 $R^2$ ）可能只有0.3左右。如果我们认为还有未观测能力、人格等因素，或测量误差，使得即便加上它们 $R^2$ 也达不到1，那么也许取 $R^2_{\max}=0.5$或$0.6$ 是合理的上限。Oster建议通过常识或领域知识尽量缩小$R^2_{\max}$ 与1之间的范围，以免高估未观测变量的潜力。

**2. 选择 $\delta$（选择偏差比例系数):**
    $\delta$ 的选取同样基于研究者对现实的判断。

- **基准假设 ($\delta=1$)：** 一个常用基准假设是 $\delta=1$，即认为研究中收集和控制的观测变量总体上已经与处理变量有相当的关联强度，未观测因素不太可能比这更强。这种假设有一定合理性：因为研究人员往往会优先收集他们认为最重要的混杂变量，因此剩下的未观测变量总体作用可能不如观测集。另外，由于 $W_2$ 已经对 $W_1$ 正交化处理（剔除了与 $W_1$ 相关的部分），理论上 $W_2$ 表示的是相对于已包含控制的“剩余”混杂，更难有极高的选择关联。
- **敏感性分析：** 根据具体情况，研究者也可以考虑 $\delta > 1$ 的情景以作更保守的稳健性检验，或考虑 $\delta < 1$ 如果认为未观测因素确实比观测的弱得多。实施时，可以选取几个代表性的 $\delta$ 值（例如 0、0.5、1、2 等）进行敏感性分析，观察调整结果的变化幅度。
  -   **边界情形：**
  * $\delta=0$：这相当于假设未观测因素与处理完全独立（没有选择偏差），此时 $\beta_{adj} = \beta_c$（因为未观测偏误为 0）。因此 $\beta_c$ 本身构成了一个边界情形。
  * $\delta=1$：通常构成常用的另一端边界。
- **取值范围：** 在不引入更多假设时，$\delta$ 实际上可以从 0 延伸到 $+\infty$。不过鉴于正偏差假设和实际意义，通常我们认为 $\delta$ 不会无限大，可在较小区间内讨论（例如 $\delta$ 不太可能大于 3 或 5，在大多数应用中甚至很少超过 2）。

**3. 生成 $\beta$ 的边界集合：**

给定对 $R^2_{\max}$ 和 $\delta$ 的合理取值区间，我们可以利用命题 2 的公式计算一系列偏误调整系数 $\beta_{adj}$。特别地，如果我们为 $R^2_{\max}$ 和 $\delta$ 选定上界（分别记作 $R^2_{\max}$ 和 $\bar{\delta}$），则可以定义识别边界集合：

$$
B_s = [\beta_c, \beta_{adj}(R_{\max}, \bar{\delta})]
$$

其中：

* $\beta_c$ 对应 $R^2_{\max} = R^2_c$ 或 $\delta=0$ 的情形，即没有任何未观测偏误时的系数；
* $\beta_{adj}(R^2_{\max}, \bar{\delta})$ 是在假设最悲观的偏误情形（$R_{\max}$ 最大且未观测偏差达到上界 $\bar{\delta}$）下调整得到的系数。

这个区间 $[\beta_{adj}(R^2_{\max}, \bar{\delta}),\beta_c]$ 就是根据我们主观认可的偏误范围所识别出的可能真值区间。在 Oster 的建议中，一般取 $\bar{\delta}=1$ 作为上界假设，那么边界集合就是 $[\beta_{adj}(R^2_{\max}, 1),\beta_c]$。在此范围内，任何 $\delta \in [0, 1]$ 和 $R^2_{\max} \in [R^2_c, \text{假定的} R^2_{\max}]$ 都会产生一个 $\beta_{adj}$，这些取值都被视为尚在合理假定内可能的真实效应。

**4. 稳健性的评估：**

得到了边界集合（或若干感兴趣情形下的 $\beta_{adj}$ 值）后，我们需要判断结果的稳健性。这通常通过以下方式进行：

* **是否包含零：**
  如果边界集合 $B_s$ 穿过 0 值，即 $0 \in [\beta_c, \beta_{adj}(R_{\max}, \bar{\delta})]$，那么在假定的偏误范围内真实效应有可能为零，表明结果对未观测偏差不稳健。相反，如果整个区间仍然远离 0（例如全为正或全为负且不接近 0），则可以说结论较为稳健：即使考虑了最大可能的未观测偏误，处理效应的方向和显著性依然保持。例如，在加入控制后系数仍为正且显著，且计算得最偏不利调整下 $\beta_{adj}$ 仍为正且与 0 差距明显，那么我们有理由相信结果不是由遗漏偏误驱动的。
* **区间长度与原估计的不确定性：**
  可以将 $B_s$ 的端点与原始估计 $\beta_c$ 的置信区间比较。如果偏误调整后的区间边界落入 $\beta_1$ 的置信区间内，则说明即便进行偏误校正，我们对效应的判断（例如显著性或经济显著性）可能没有根本改变。但如果 $\beta_{adj}(R_{\max}, \bar{\delta})$ 比如落在 $\beta_c$ 的置信区间之外很多，意味着一旦考虑偏误，效应大小可能显著异于原估计，需要警惕。简单来说，我们希望观测控制下估计的结论在考虑合理范围的偏误调整后依然成立。
* **必要的 $R_{\max}$ 检验：**
  另一种补充分析方法是反过来求：在假定 $\delta=1$ 等较可信的前提下，需要怎样的 $R^2_{\max}$ 才能令 $\beta_{adj}=0$。如果所需 $R^2_{\max}$ 非常高甚至接近 1，那么意味着除当前控制外未观测因素必须解释几乎所有剩余的方差才能使结果归零，这是不太可能的，因此结果稳健。反之，若只需略高于 $R^2_c$ 的 $R^2_{\max}$（比如再解释 5% 的方差）就足以让效应消失，那说明结果容易被少量未观测偏误推翻，稳健性较差。这种 $R^2_{\max}$ 需求量的讨论可以结合对结果的理解来定性说明稳健性。例如，我们可以报告：“在假定选择偏差 $\delta=1$ 的情况下，需要 $R^2_{\max}$ 达到 0.xx（显著高于目前 $R^2_c=0.yy$）才能将系数推至零。考虑到 $Y$ 包含的噪音和其他因素，我们认为让未观测变量额外解释如此大的方差是不大可能的”。通过这样的论证来加强对结果鲁棒性的信心。

---

# 4. 命令介绍

本文基于 Oster (2019) 的理论框架，编写了 Stata 命令 `coefstability`（当前版本 3.3.0）。该命令旨在自动化实现系数稳定性检验，通过比较完整模型与基准模型的估计结果，量化遗漏变量偏误对因果推断的潜在影响。本版本在底层完全移植了 Oster 原版 `psacalc` 的 Mata 数学内核，并修复了原程序在不同命令下对固定效应处理逻辑不一致的问题，确保了计算结果的严谨性与一致性。

相关程序文件已集成在 GitHub 仓库 [Stata-Oster-2019](https://github.com/lmm51315-pixel/Stata-Oster-2019-Stata-) 的 `mydo/coefstability` 文件夹中。

## 4.1 命令概述

`coefstability` 的核心逻辑是根据用户提供的**完整回归模型**（Full Model），自动剥离控制变量构建**基准模型**（Base Model），进而利用 Oster (2019) 的近似公式计算经偏误调整后的处理效应 $\beta^*$。

**核心改进：**

1. **数学内核的精确移植 (Exact Kernel Porting)**：

   * 本命令并未简单重写 Oster 的公式，而是通过 Mata 语言**逐行复刻**了 Oster 官方发布的 `psacalc` (v2.1) 的底层算法。
   * 特别是在求解一元三次方程（Cardano 公式）以获取 $\delta \neq 1$ 时的 $\beta_{adj}$，以及在多根情况下依据“假设3”（Assumption 3）进行根的筛选与边界判定时，本命令与官方代码保持了完全一致的数学逻辑。这确保了在输入相同参数时，本命令能输出与 `psacalc` 毫无二致的精确结果，消除了因算法实现差异导致的数值误差。
2. **方差计算逻辑的统一与修正 (Unified Consistency)**：

   * 原版 `psacalc` 代码存在对不同命令处理不一致的“双重标准”问题（即对 `xtreg` 保留固定效应计算方差，而对 `areg` 却强制忽略固定效应）。
   * 本版本修复了这一逻辑缺陷，并删除了`areg`这一选项。无论用户使用的是 `xtreg`，还是 `reghdfe`，只要模型包含固定效应（Fixed Effects），程序在计算基准模型中处理变量的残差方差 ($\sigma_{xx}$) 时，均会严格计算组内方差 (Within Variance)。这一改进显著提高了对高维固定效应模型的支持准确度，防止因错误忽略固定效应而高估 $\sigma_{xx}$，进而导致低估 $\delta$ 值。

3. **智能化的 Rmax 参数设定 (Smart Rmax Input)**：

   * 优化了交互体验。在 `psacalc` 中，用户必须手动计算绝对数值（例如手动算出 $0.4 \times 1.3 = 0.52$ 并输入）。
   * 本命令的 `rmax()` 选项接受**倍数**输入（Multiplier）。默认值设为 Oster (2019) 推荐的 **1.3**。程序会自动计算 $R^2_{\max} = \min(1, \text{rmax} \times R^2_c)$。这不仅简化了操作，还自动规避了 $R^2_{\max} > 1$ 的逻辑错误，同时保留了在计算出的 $R^2_{\max} \le R^2_c$ 时自动微调的稳健性机制。

命令执行流程如下：

1. **解析完整模型**：用户输入包含所有控制变量的完整回归命令字符串（支持 `reg`, `xtreg`, `reghdfe`）。
2. **构建基准模型**：
   * 程序识别处理变量（`treatvar`），剔除其他协变量。
   * **关键步骤**：在构建基准模型及计算残差方差时，严格保留原模型中的固定效应（`absorb` 或 `fe`）、聚类及权重设定。
3. **计算统计量**：
   * 提取两模型的系数 ($\beta_c, \beta_u$) 和拟合优度 ($R^2_c, R^2_u$)。
   * 调用 Mata 内核计算 Oster 边界（含 $\delta=1$ 时的 $\beta^*$ 和 $\beta=0$ 时的 $\delta^*$）。

## 4.2 语法 (Syntax)

```stata
coefstability treatvar [if] [in] , model(string) [options]
```

*注意：本命令要求将完整的回归语句（含因变量、控制变量、选项）放入 `model()` 选项中。*

## 4.3 选项 (Options)

### 4.3.1 核心设定

* **`treatvar`**：**(必填)** 核心解释变量（处理变量）。必须是 `model()` 中已包含的变量。
* **`model(string)`**：**(必填)** 完整的回归命令字符串。
  * 完美支持以下命令：`regress`, `areg`, `xtreg` (fe/be), `reghdfe`。
  * *示例*：`model("reghdfe y x1 x2 x3, absorb(id year) cluster(id)")`

### 4.3.2 参数设定

* **`delta(real)`**：设定未观测变量与观测变量的选择比例系数 $\delta$，**默认为 1**。
* **`rmax(real)`**：设定 $R^2_{\max}$ 相对于完整模型 $R^2$ ($R^2_c$) 的**倍数**，**默认为 1.3**。
  * 程序内部计算逻辑为：$R^2_{\max} = \min(1, \ \text{rmax} \times R^2_c)$。
* **`beta(real)`**：设定目标 $\beta$ 值（用于计算 $\delta$），**默认为 0**（即检验原系数是否稳健到不包含 0）。

### 4.3.3 统计推断 (Bootstrap)

* **`bootstrap`**：启用 Bootstrap 方法以获得统计推断结果。
* **`reps(integer)`**：Bootstrap 重复次数，**默认为 1000**。
* **`seed(integer)`**：随机数种子，**默认为 12345**，确保结果可复现。
* **`level(cilevel)`**：置信区间的置信水平，默认为系统设定（通常为 95）。
* *智能识别*：程序会自动检测面板数据结构（`xtset`），若存在，将自动执行聚类 Bootstrap (Cluster Bootstrap)。

### 4.3.4 其他选项

* **`noisily`**：在结果窗口显示基准模型和完整模型的原始回归输出及详细过程。
* **`saving(filename)`**：将 Bootstrap 的抽样分布结果保存为 `.dta` 文件。

## 4.4 结果解释与返回值

### 4.4.1 结果报表

命令将输出标准化表格，并在下方注释中明确指出计算使用了 "Consistent Within-Variance" 逻辑：

1. **beta_adj**：在给定 $\delta$ (默认1) 下的偏差调整后系数 $\beta_{adj}$。
2. **Bounds**：由 $[\min(\beta_c, \beta_{adj}), \max(\beta_c, \beta_{adj})]$ 构成的识别区间。
3. **Delta (for $\beta=0$)**：使得调整后系数变为 0 所需的不可观测选择强度 $\delta^*$。
   * 通常 $\delta^* > 1$ 被视为结果稳健的标志。

### 4.4.2 返回值 (Stored Results)

程序将计算结果存储在 `r()` 中：

| 标量名称                        | 描述                                                           |
| :------------------------------ | :------------------------------------------------------------- |
| **`r(beta_full)`**      | 完整模型（Full Model）的原始系数$\tilde{\beta}$              |
| **`r(beta_base)`**      | 基准模型（Base Model）的原始系数$\mathring{\beta}$           |
| **`r(beta_star)`**      | 调整后系数$\beta_{adj}$ (Oster's Beta)                           |
| **`r(delta_star)`**     | 临界$\delta$ 值 (for target beta)                            |
| **`r(rmax)`**           | 计算中实际使用的$R_{\max}$ 值                                |
| **`r(r2_full)`**        | 完整模型的$R^2$ (Within $R^2$ for FE models)               |
| **`r(r2_base)`**        | 基准模型的$R^2$                                              |
| **`r(reject_null)`**    | 字符串结果 "Yes" 或 "No"，指示识别区间是否排除零               |


---

# 5. 应用示例

本节旨在通过具体的实证论文案例，演示如何使用 `coefstability` 命令进行系数稳定性检验。我们将展示如何复现知名期刊中的检验过程，并对比本命令与传统命令的输出效果，并展示本命令如何使用搭配`bootstrap`使用。

## 5.1 案例复现：金融包容性与碳排放 (Acheampong & Said, 2024)

> **Source**: Acheampong, A. O., & Said, R. (**2024**). Financial inclusion and the global net-zero emissions agenda: Does governance quality matter? **Energy Economics**, 137, 107785. [Link](https://doi.org/10.1016/j.eneco.2024.107785) (rep), [PDF](http://sci-hub.ren/10.1016/j.eneco.2024.107785), [Google](<https://scholar.google.com/scholar?q=Financial inclusion and the global net-zero emissions agenda: Does governance quality matter>). [Replication](https://ars.els-cdn.com/content/image/1-s2.0-S0140988324004936-mmc1.zip) 

#### 5.1.1 研究背景与遗漏变量挑战

Acheampong 和 Said (2024) 利用全球面板数据探讨了金融包容性 (Financial Inclusion, FI) 对二氧化碳排放的影响。尽管作者在回归模型中控制了 GDP、可再生能源、FDI 及时间固定效应等变量，并得出“金融包容性显著增加碳排放”的结论，但该结论仍可能受到未观测到的文化因素或非制度性政策等遗漏变量的干扰。

为了证明核心结论的稳健性，作者采用了 Oster (2019) 方法，通过设定 $R^2_{\max}=1$（即假设所有方差均可被解释），反推遗漏变量的选择强度 $\delta$ 需达到何种程度才能完全解释掉处理效应。

### 5.1.2 原文方法 (`psacalc`) 及其局限

原文基于 Table 10 中的 7 个模型设定（基准模型及加入不同治理变量的模型），使用 `psacalc` 命令逐一计算 $\delta$ 值。

**原文代码片段：**
```stata
// OLS results and Oster stability test
//Table 10
global tlist time2 time3 time4 time5 time6 time7 time8 time9 time10 time11 time12 time13 time14 time15 time16 time17
eststo clear

eststo: regress lnco2kt  lnrgdpc lnrgdpc2 lnrenew lnfdi  lntrad lnurb FI  $tlist ,  robust
psacalc delta FI, rmax (1)

eststo: regress lnco2kt  lnrgdpc lnrgdpc2 lnrenew lnfdi  lntrad lnurb  FI cc  $tlist ,  robust
psacalc delta FI, rmax (1)

eststo: regress lnco2kt  lnrgdpc lnrgdpc2 lnrenew lnfdi  lntrad lnurb FI  ge   $tlist ,  robust
psacalc delta FI, rmax (1)

eststo: regress lnco2kt  lnrgdpc lnrgdpc2 lnrenew lnfdi  lntrad lnurb FI  ps   $tlist ,  robust
psacalc delta FI, rmax (1)

eststo: regress lnco2kt  lnrgdpc lnrgdpc2 lnrenew lnfdi  lntrad lnurb FI  rq  $tlist ,  robust
psacalc delta FI, rmax (1)

eststo: regress lnco2kt  lnrgdpc lnrgdpc2 lnrenew lnfdi  lntrad lnurb FI  rl   $tlist ,  robust
psacalc delta FI, rmax (1)

eststo: regress lnco2kt  lnrgdpc lnrgdpc2 lnrenew lnfdi  lntrad lnurb FI  va   $tlist ,  robust
psacalc delta FI, rmax (1)
```
**方法局限性：**
1.  **缺乏统计推断：** `psacalc` 仅提供 $\delta$ 的点估计值。在小样本或异方差存在时，估计量可能存在较大波动，仅凭点估计难以判断结果的统计显著性。
2.  **结果展示单一：** 无法直观展示偏差调整后的系数 ($\beta_{adj}$) 及其置信区间，容易掩盖估计的不确定性。
3.  **计算逻辑黑箱：** 在处理面板数据固定效应时，不同命令（如 `xtreg` vs `regress`）的方差处理可能存在隐性差异。
   
### 5.1.3 使用 `coefstability` 的深度复现与纠偏

我们使用 `coefstability` 命令对该研究进行了完整复现，在保证计算内核与原文一致的前提下，进一步计算了偏差调整后的系数 $\beta_{adj}$ 及其 Bootstrap 置信区间。

**核心代码片段：**
```stata
* bootstrap设置
local B_reps = 1000
local B_seed = 12345
local B_level = 95
...
    capture quietly bootstrap ///
        beta_star=r(beta_star) ///
        delta_star=r(delta_star), ///
        reps(`B_reps') seed(`B_seed') level(`B_level') ///
        nodots ///
        saving(`bootfile', replace) ///
        reject(missing(r(beta_star))) : ///
        coefstability $treat_var, ///
            model(`"`full_model'"') ///
            rmax(1000) ///  <- 小技巧让rmax为1
            delta(1) ///
            beta(0)
...
```

#### A. 复现结果综合对比表

下表展示了使用 `coefstability` 复现的完整结果。我们不仅对比了 $\delta$ 值，还列出了调整后的系数 $\beta_{adj}$ 及其统计推断结果。

**表1：金融包容性系数的稳定性（重复实验结果）**

| Model Specification | Delta (Psa.) | Delta (Coe.) | Beta (Orig) | Beta (Psa.) |Beta (Coe.) | Oster Set (Bound) | Bootstrap 95% CI |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |:--- |
| **Baseline** | 1.683 | 1.683 | 0.049 | 0.020 | 0.020 |[0.020, 0.049] |  [0.003,0.034]|
| **Control: CC** | 1.688 | 1.688 | 0.049 | 0.021 | 0.021 |[0.021, 0.049] |  [0.002,0.035] |
| **Control: GE** | 1.447 | 1.447 | 0.042 | 0.013 | 0.013 |[0.013, 0.042] |  [-0.005,0.028] |
| **Control: PS** | 1.614 | 1.614 | 0.047 | 0.018 | 0.018 |[0.018, 0.047] |  [-0.000,0.034] |
| **Control: RQ** | 1.675 | 1.675 | 0.048 | 0.020 | 0.020 |[0.020, 0.048] | [0.002,0.034]  |
| **Control: RL** | 1.563 | 1.563 | 0.045 | 0.017 | 0.017 |[0.017, 0.045] | [-0.002,0.031] |
| **Control: VA** | 1.586 | 1.586 | 0.046 | 0.018 | 0.018 |[0.018, 0.046] |  [-0.002,0.032] |

> *注：Delta (Psa.) 为原文使用 psacalc 报告的值；Delta (Coe.) 为 coefstability 计算值。Beta (Adj) 是假设 $\delta=1, R_{max}=1$ 时的偏差调整系数。Bootstrap CI 是基于 1000 次抽样计算的 Beta (Adj) 偏差校正置信区间。*

#### B. 核心发现与原文辨析

通过 `coefstability` 提供的全面信息，我们对原文结果进行了以下三个层面的辨析：

1.  **算法一致性验证（Delta 值）**
    对比表格前两列可见，`coefstability` 计算的 $\delta$ 值与原文完全一致（精确到小数点后三位）。例如，Baseline 模型的 $\delta$ 均为 1.683。此外本文还进行了`coefstability`与`psacalc`方法的$\beta_{adj}$值计算对比，结果也完全一致，这充分证明了新命令在数学内核上准确复刻了 Oster 的方法论，且正确处理了包含时间固定效应的回归模型。

2.  **原文数据纠错（$\beta_{adj}$ 值）**
    原文在 Table 10 中报告的偏差调整系数 $\beta_{adj}$ 高达 **0.595**（见下图原文截图），这几乎是原始系数 0.049 的 12 倍。在引入遗漏变量偏误校正后，系数通常会发生衰减或符号改变，极少出现同向剧烈放大的情况。
    我们的复现结果显示，真实的 $\beta_{adj}$ 应在 **0.020 左右**。这意味着考虑了潜在偏误后，金融包容性的影响效应由 0.049 收敛至 0.020，这是一个符合经济学直觉的“效应衰减”过程。原文的 0.595 极大概率为笔误或计算错误。

<div align="center">
  <img src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/undefined20260130211047272.png" width="650" alt="coefstability检验结果">
</div>

> *注：原文 Table 10 截图，显示的 0.595 与复现结果 0.020 存在巨大差异)*

3.  **统计显著性的再评估（Bootstrap CI）**
    这是本案例最重要的发现。原文仅依据 $\delta > 1$ 便断定结果稳健。然而，通过 `coefstability` 的 Bootstrap 功能，我们发现所有模型的 $\beta_{adj}$ **95% 置信区间均包含 0**（例如 Baseline 区间为 `[-1.014, 1.447]`）。
    这一宽泛的区间表明，尽管点估计显示结果稳健（$\delta=1.683$），但在统计意义上，我们**无法排除**“真实的偏差调整后系数为 0”的可能性。这提示我们在解读稳健性时需更加谨慎：虽然模型通过了传统的 Oster 阈值检验，但其估计结果对抽样误差较为敏感。

### 5.1.4 小结

本案例充分展示了 `coefstability` 相比传统工具的优越性。它不仅帮助我们**验证了原文结论**（\beta_{adj} 一致），成功**纠正了原文笔误**（$\beta_{adj}$ 修正），更重要的是通过**Bootstrap 区间推断**揭示了点估计背后的不确定性风险。这种“点估计 + 偏差校正 + 区间推断”的三维分析框架，为实证研究提供了更严谨的稳健性检验标准。

---

## 5.2 案例二：气候变化风险与权益资本成本——复现 Cepni et al. (2024)

> **Source**: Cepni, O., Şensoy, A., & Yılmaz, M. H. (**2024**). Climate change exposure and cost of equity. **Energy Economics**, 130, 107288. [Link](https://doi.org/10.1016/j.eneco.2023.107288) (rep), [PDF](https://file-lianxh.oss-cn-shenzhen.aliyuncs.com/Refs/2026-Spring/Cepni_2024_Climate_change_exposure_and_cost_of_equity.pdf), [Google](<https://scholar.google.com/scholar?q=Climate change exposure and cost of equity>). [Replication](https://ars.els-cdn.com/content/image/1-s2.0-S0140988323007867-mmc1.zip)

### 5.2.1 文献背景与研究动机

随着气候变化日益成为全球焦点，资本市场是否已将企业面临的气候风险纳入定价体系？Cepni, Şensoy 和 Yılmaz (2024) 在 *Energy Economics* 上发表的研究深入探讨了这一议题。作者构建了衡量企业物理风险与转型风险（Physical and Transition Risks）的综合指标，并实证检验了该指标与权益资本成本（Cost of Equity）之间的因果关联。

研究结果表明，气候变化暴露度越高的企业，其承担的权益资本成本显著更高。尽管原文主要通过逐步引入控制变量（stepwise inclusion of controls）来论证结果的稳定性，未直接采用 Oster (2019) 的形式化检验，但其核心逻辑——即**通过观察引入控制变量后系数的稳定性来推断遗漏变量偏误**——与 Oster 方法不谋而合。本节将利用 `coefstability` 命令对该文结果进行形式化的敏感性分析。

### 5.2.2 原文回归设定

作者采用了典型的两步法回归策略：首先建立仅包含核心解释变量的基准模型，随后加入一系列公司特征变量构成完整模型。原文基于 `reghdfe` 的 Stata 代码逻辑如下：

```stata
use main_sample, clear
xtset GVKEY_num year

* 1. Baseline estimations (基准模型：仅含核心解释变量与固定效应)
reghdfe cost_of_equity_w1 L.ln_cc_expo_ew_w1, ///
    absorb(GVKEY_num year) vce(cluster GICIndustries)

* 2. Full estimations (完整模型：加入账面市值比、规模、盈利能力等控制变量)
reghdfe cost_of_equity_w1 L.ln_cc_expo_ew_w1 ///
    L.bm_w1 L.firm_size_w1 L.npm_w1 L.roa_w1 L.debt_at_w1 L.rd_sale_w1, ///
    absorb(GVKEY_num year) vce(cluster GICIndustries)
```

### 5.2.3 应用 `coefstability` 进行稳健性检验

为了量化不可观测混杂因素对因果推断的潜在威胁，我们使用 `coefstability` 命令对上述过程进行一键式复现。得益于该命令对 `reghdfe` 的原生支持，我们能够直接基于高维固定效应模型计算 Oster 边界。

```stata
* 设定随机种子以保证 Bootstrap 结果可复现
set seed 12345

// 1. 定义完整的回归命令
local cmd_reghdfe "reghdfe cost_of_equity_w1 L.ln_cc_expo_ew_w1 L.bm_w1 L.firm_size_w1 L.npm_w1 L.roa_w1 L.debt_at_w1 L.rd_sale_w1, absorb(GVKEY_num year) vce(cluster GICIndustries)"

// 2. 运行 coefstability
// 特性：直接支持 model() 中传入 reghdfe，且自动识别吸收的固定效应
coefstability L.ln_cc_expo_ew_w1,  ///
    model(`"`cmd_reghdfe'"')       /// <--- 直接传入 reghdfe 字符串
    delta(1)                       ///
    rmax(1.3)                      /// <--- 设定 Rmax = 1.3 * e(r2)
    beta(0)                           
```

**检验结果解读：**

<div align="center">
  <img src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/undefined20260201164359455.png" width="650" alt="coefstability检验结果">
</div>

检验结果显示，在考虑了不可观测变量的选择偏误（假设 $\delta=1$ 且 $R_{max}=1.3\tilde{R}$）后，调整后的处理效应系数 $\beta_{adj}$ 仍然为正且不包含零。这表明 Cepni et al. (2024) 关于气候风险提升权益成本的结论在考虑潜在遗漏变量偏误后依然稳健。

### 5.2.4 跨命令对比与数值差异分析

为了进一步验证计算的可靠性，我们将 `coefstability` 与传统的 `psacalc` 命令进行了对比。由于 `psacalc` 不支持 `reghdfe` 的高维固定效应吸收功能，我们退而求其次，统一使用 `xtreg, fe` 进行对比测试。代码如下：

```stata
local cmd_xtreg "xtreg `y_var' `treat_var' `controls' i.year, fe vce(cluster `cluster_id')"

// 使用 coefstability 计算
coefstability `treat_var', model(`"`cmd_xtreg'"') delta(1) rmax(1.3) beta(0)

// 使用 psacalc 计算 (需手动传递 Rmax 值)
// 注：此处需确保传入 psacalc 的绝对 Rmax 值与 coefstability 内部计算的一致
psacalc delta `treat_var', rmax(`abs_rmax') beta(0) model(`cmd_xtreg')
```

**表 2：敏感性分析结果对比 (Based on `xtreg`)**

| Model Specification | Delta (Psa.) | Delta (Coe.) | Beta (Orig) | Beta (Psa.) | Beta (Coe.) | Identified Set |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Baseline** | **-5.350** | **-5.321** | 0.837 | 0.998 | 0.998 | [0.837, 0.998] |

> 注：*表中展示的 $\beta$ 结果高度一致，但 $\delta^*$ 值（即解释变量失效所需的混杂强度）出现了微小差异（-5.350 vs -5.321）。这一现象并非计算错误，而是触及了敏感性分析中的关键技术细节：**数值计算的敏感性**。*

### 5.2.5 关键技术细节与数值特性剖析

细心的读者会发现，不同命令或模型设定下的敏感性分析结果可能存在细微甚至显著的差异。本节将从理论一致性和数值稳定性两个维度，对上述差异进行深度剖析。

#### 1. 固定效应模型中拟合优度（$R^2$）的理论一致性

Oster (2019) 方法的核心逻辑依赖于“系数移动”与“$R^2$ 移动”的比例关系。在等选择（equal selection）假设下，$R^2$ 的计算口径必须严格对应于回归模型中**用于识别处理效应 $\beta$ 的变异来源（Variation used for identification）**。

*   **`xtreg, fe` 的 $R^2$**：报告的 $Within-R^2$ 是基于“去除个体均值后的组内变异”计算的。这适用于仅包含一维个体固定效应的情形。
*   **`reghdfe` 的 $R^2$**：其 $Within-R^2$ 是在剔除（Partial-out）所有高维固定效应（如 Individual + Year + Industry FE）后的“剩余残差空间”上计算的。

**判别规则与建议：**
为了保证理论逻辑的一致性，研究者应遵循**“变异空间对齐”**原则：
*   若主模型采用 `xtreg`（仅吸收个体 FE），应使用 `xtreg` 的 $Within-R^2$。
*   若主模型采用 `reghdfe`（吸收多维 FE），必须使用 `reghdfe` 的 $Within-R^2$。`coefstability` 命令的设计初衷正是为了解决 `psacalc` 无法正确处理 `reghdfe` 残差空间的问题。切勿混用不同口径，因为 `reghdfe` 的 $Within-R^2$ 通常更为“严苛”，混用会导致 $\delta^*$ 估计出现系统性偏差。

#### 2. $\delta^*$ 估计量的病态敏感性（Ill-conditioning）

在表 2 中，尽管 $\beta$ 的调整值一致，但 $\delta^*$ 却有些许差异。这源于 $\delta^*$ 估计量在特定参数空间下的**敏感性（Ill-conditioning）**。根据其解析公式：

$$
\delta^* = \frac{(\tilde{\beta} - \beta)(\tilde{R} - \mathring{R})\sigma_y^2 \tau_x + \dots}{(R_{\max} - \tilde{R})\sigma_y^2 (\mathring{\beta} - \tilde{\beta})\sigma_X^2 + (\tilde{\beta} - \beta)(R_{\max} - \tilde{R})\sigma_y^2 (\sigma_X^2 - \tau_x) + \dots}
$$

**数值不稳定性机理：**
在实际计算中，常出现以下情况导致分母趋近于零（Singularity）：
1.  **方差抵消**：处理变量的总方差 $\sigma_X^2$ 与控制协变量后的残差方差 $\tau_x$ 非常接近（$\sigma_X^2 \approx \tau_x$），导致公式分母中的 $(\sigma_X^2 - \tau_x)$ 项急剧减小。
2.  **精度放大**：当分母极小（例如 $10^{-11}$ 量级）时，任何微小的数值扰动都会被放大。例如，不同命令对 $R^2$ 的存储精度差异（Double Precision 尾数误差），足以导致 $\delta^*$ 在小数点后数位发生剧烈漂移。

**结论与建议：**
与处理效应 $\beta$（通常是线性方程组的解，数值稳定）不同，$\delta^*$ 是一个涉及高阶项相减的比率，极易出现数值漂移。特别是在 $\delta^*$ 为负值的情况下（意味着未观测选择必须与可观测选择方向相反才能解释结果），其精确数值的参考意义有限。此时，研究者应更关注 **$\delta^*$ 的符号方向及其数量级**，而非纠结于具体的数值差异。这也进一步佐证了在实证研究中，报告识别边界（Identified Set）通常比单一的 $\delta^*$ 点估计更为稳健。

---


## 5.3 案例三：人工智能能否改善性别不平等——复现 Bao et al. (2025)

> **Source**: Bao, L., Huang, D., & Lin, C. (**2025**). Can Artificial Intelligence Improve Gender Equality Evidence from a Natural Experiment. **Management Science**. [Link](https://doi.org/10.1287/mnsc.2022.02787), [PDF](https://file-lianxh.oss-cn-shenzhen.aliyuncs.com/Refs/2026-Spring/Bao-2024-MS.pdf), [PDF-wp](https://file-lianxh.oss-cn-shenzhen.aliyuncs.com/Refs/2026-Spring/Bao-2024-MS-wp.pdf), [Appendix](https://pubsonline.informs.org/doi/suppl/10.1287/mnsc.2022.02787/suppl_file/mnsc.2022.02787.sm1.pdf), [Google](<https://scholar.google.com/scholar?q=Can Artificial Intelligence Improve Gender Equality Evidence from a Natural Experiment>), [Replication](https://services.informs.org/dataset/download.php?doi=mnsc.2022.02787).

### 5.3.1 文献背景与研究动机

人工智能（AI）在劳动力市场中的作用是一把双刃剑：它既可能因算法偏见加剧歧视，也可能通过提供客观评价减少人为偏见。Bao, Huang 和 Lin (2025) 在 *Management Science* 发表的研究聚焦于这一核心议题，利用中国一家大型在线辅导平台引入专有 AI 监控系统的自然实验，探讨了算法评估对性别不平等的因果影响。

在传统的在线教育市场中，由于缺乏关于教师教学质量的客观信号，家长往往依赖主观刻板印象（如倾向于选择女性教师），导致男性教师面临“统计性歧视”。该研究发现，AI 系统通过分析教学视频并生成客观的“质量分数”（Quality Score），有效地向市场传递了教师能力的硬指标。实证结果显示，AI 评分系统的引入显著缩小了男性教师在订单需求和薪资水平上与女性教师的差距。

为了确保这一结论并非由不可观测的教师特质（如未被记录的软技能、个人魅力等）驱动，作者采用了 Oster (2019) 的方法进行敏感性分析，以验证因果识别的稳健性。

### 5.3.2 原文回归设定与复现难点

作者在原文中使用了 `psacalc` 命令进行敏感性测试。根据其提供的复现代码包，关键代码逻辑如下：

```stata
use "data_main.dta", clear
...
** Part 1: Sensitivity Analysis using psacalc
* 计算调整后的 Beta (假设 delta=1)
bs r(beta), rep(100): psacalc beta pc2, rmax(0.40) delta(1) ///
    model(areg quality pc2 teacher_gender teacher_age teacher_experience age study gender, absorb(month))

* 计算调整后的 Beta (假设 delta=1.5)
bs r(beta), rep(100): psacalc beta pc2, rmax(0.40) delta(1.5) ///
    model(areg quality pc2 teacher_gender teacher_age teacher_experience age study gender, absorb(month))

* 计算临界 Delta (假设 beta=0)
psacalc delta pc2, rmax(0.40) beta(0) ///
    model(areg quality pc2 teacher_gender teacher_age teacher_experience age study gender, absorb(month))
```

**关于 $R^2_{max}$ 设定的说明：**
在复现过程中，我们发现作者在论文附表注释中声称使用的是 $R^2_{max} = \min(2\tilde{R}^2, 1)$。然而，通过检查数据发现，基准模型的 $\tilde{R}^2 \approx 0.30$，而作者在代码中显式设定了 `rmax(0.40)`。这意味着作者实际采用的参数设定约为 $R^2_{max} \approx 1.3\tilde{R}^2$，而非文中声称的 $2\tilde{R}^2$。为保证复现结果的可比性，后续分析将严格遵循作者 **Dofile 代码中的设定**（即 $R^2_{max}=0.40$ 或 $\approx 1.3\tilde{R}^2$）进行操作。

<div align="center">
  <img src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/undefined20260201174110919.png" width="650" alt="coefstability检验结果">
</div>

### 5.3.3 应用 `coefstability` 进行稳健性检验

鉴于 `areg` 命令在处理固定效应时的局限性（详见下文分析），且 `reghdfe` 在高维固定效应处理上具有显著的技术优势，本命令在设计上放弃了对 `areg` 的兼容，转而全面支持 `reghdfe`。

利用 `coefstability` 复现上述过程的代码如下：

```stata
* 设定随机种子以保证 Bootstrap 结果可复现
set seed 12345

* 定义回归模型字符串 (使用 reghdfe 替代 areg)
local cmd_model "reghdfe quality pc2 teacher_gender teacher_age teacher_experience age study gender, absorb(month)"

* 1. 估计 beta* (假设 delta=1) 并计算 Bootstrap 标准误
bootstrap r(beta_star), rep(100): ///
    coefstability pc2,    ///
    model(`"`cmd_model'"') ///
    delta(1)              ///
    rmax(1.3)             // 对应原文约 1.3 倍 R2 的设定

* 2. 估计 beta* (假设 delta=1.5)
bootstrap r(beta_star), rep(100): ///
    coefstability pc2,    ///
    model(`"`cmd_model'"') ///
    delta(1.5)            ///
    rmax(1.3)

* 3. 估计临界 Delta (假设 beta=0)
* 注：Delta 的点估计直接计算即可，通常无需 Bootstrap
coefstability pc2,        ///
    model(`"`cmd_model'"') ///
    beta(0)               ///
    rmax(1.3)
```

### 5.3.4 结果对比与技术解析

表 3 展示了使用原始 `psacalc`（基于 `areg`）与本文 `coefstability`（基于 `reghdfe`）的计算结果对比。

**表 3：敏感性分析结果对比**

| Model Specification | $\delta^*$ (for $\beta=0$) | $\beta^*$ ($\delta=1$) | $\beta^*$ ($\delta=1.5$) | $R^2_{max}$ Setting |
| :--- | :---: | :---: | :---: | :---: |
| **`psacalc` (Orig.)** | 3.695 | -0.910 | -0.823 | Fixed at 0.40 |
| **`coefstability`** | **3.790** | **-0.920** | **-0.839** | $1.3 \times \tilde{R}^2$ |

**结果稳健性：**
对比显示，尽管数值存在细微差异，但 Bao et al. (2025) 的核心结论在两种方法下均极其稳健：即使引入了强度为观测变量 3.7 倍以上的未观测混杂因素（$\delta^* \approx 3.79$），AI 评分对教学质量感知的处理效应仍然存在。

**数值差异的技术溯源（$Overall-R^2$ vs $Within-R^2$）：**
观察发现，两种方法得到的结果并不完全重合。进一步的代码解构揭示了 `psacalc` 在处理固定效应模型时的**理论缺陷**。由于 Stata 的 `areg` 命令默认仅存储整体拟合优度（$Overall-R^2$），并不直接返回组内拟合优度（$Within-R^2$）。`psacalc` 在检测到 `areg` 时，采取了如下的“退化处理”策略：

```stata
/* psacalc 内部源码片段 */
if "`command'"=="areg" loc command2 = "reg"  // <--- 强制转换为 OLS 逻辑
else loc command2="`command'"

quietly `command2' `depvar' `treatment' `mcontrol' ...
scalar `r_o'=e(r2)  // <--- 此时提取的是 Overall R2
```

这一处理导致 `psacalc` 在计算中实际上混用了 $Overall-R^2$（作为 $\tilde{R}$）与 $Overall-Variance$。这与 Oster (2019) 的理论假设相悖——Oster 强调，当模型包含固定效应时，敏感性分析应基于剔除固定效应后的**组内变异（Within Variation）**。

相比之下，`coefstability` 在调用 `reghdfe` 时，严格提取了 $e(r2\_within)$ 和对应的残差方差。因此，表 3 中 `coefstability` 的结果在理论上更为严谨，更准确地反映了固定效应模型下的稳健性边界。这一案例生动地说明了在应用前沿计量方法时，选择理论逻辑一致的计算工具的重要性。

---

# 6. 结语

本文介绍的 `coefstability` 命令为实证研究者提供了一个严谨且高效的计算工具，旨在将 Oster (2019) 提出的基于选择比率（Selection Ratio）的敏感性分析框架无缝集成至 Stata 分析流程中。相较于现有的 `psacalc` 命令，`coefstability` 的核心贡献在于其对高维固定效应模型（High-Dimensional Fixed Effects）的原生支持。通过严格遵循“变异空间对齐”原则，本命令修正了以往工具在处理 `areg` 或 `xtreg` 时因混用 $Overall-R^2$ 与 $Within-R^2$ 而导致的理论偏差，从而确保了敏感性分析结果在计量逻辑上的一致性与准确性。

`coefstability` 的输出设计旨在将抽象的“稳健性”概念转化为直观的量化指标。通过自动报告临界选择比率 $\delta^*$，研究者能够直接回答一个核心反事实问题：“未观测混杂因素的解释力需要达到观测变量的多少倍，才能完全推翻当前的处理效应结论？” 这一量化指标为因果推断的可靠性提供了判别依据：当 $\delta^*$ 远大于 1 时，我们有理由认为结果在常理范围内是稳健的；反之，若 $\delta^*$ 接近或小于 1，则意味着遗漏变量仅需具备与观测变量相当的解释力即可使结果失效，研究者需据此对结论持审慎态度。

当然，工具的便利性不能替代理论设定的审慎性。Oster (2019) 的方法论本质上是构建处理效应的识别边界（Identified Set），其有效性高度依赖于参数 $R_{\max}$ 和 $\delta$ 的合理设定。`coefstability` 的优势在于极大地降低了实施“压力测试”（Stress Test）的技术门槛，使研究者能够轻松地在多种参数组合（如 Oster 建议的 $R_{\max}=1.3\tilde{R}$）下检验结论的稳定性。我们建议研究者在实际应用中，结合领域知识与外部证据来界定参数空间，而非机械地依赖单一标准。

综上所述，`coefstability` 不仅丰富了 Stata 在因果推断领域的工具箱，更重要的是，它为评估观察性研究中的遗漏变量偏误提供了一条**理论严谨**且**操作简便**的途径。通过系统性地评估未观测混杂的潜在影响，该命令有助于提升实证研究的透明度与可信度，促使学术界在报告统计显著性的同时，更加关注因果识别的结构性稳健。

## 7. 参考文献

本文的理论和实证部分主要参考下面的几篇文献。

> Oster, E. (**2019**). Unobservable Selection and Coefficient Stability: Theory and Evidence. **Journal of Business & Economic Statistics**, 37(2), 187–204. [Link](https://doi.org/10.1080/07350015.2016.1227711), [PDF](http://sci-hub.ren/10.1080/07350015.2016.1227711), [Google](<https://scholar.google.com/scholar?q=Unobservable Selection and Coefficient Stability: Theory and Evidence>). [-cited-5000次](https://scholar.google.com/scholar?cites=11936978270607540916&as_sdt=2005&sciodt=0,5&hl=zh-CN), [github-`coefstability`](https://github.com/gratzt/Coef-Stability-Oster)

> Acheampong, A. O., & Said, R. (**2024**). Financial inclusion and the global net-zero emissions agenda: Does governance quality matter? **Energy Economics**, 137, 107785. [Link](https://doi.org/10.1016/j.eneco.2024.107785) (rep), [PDF](http://sci-hub.ren/10.1016/j.eneco.2024.107785), [Google](<https://scholar.google.com/scholar?q=Financial inclusion and the global net-zero emissions agenda: Does governance quality matter>). [Replication](https://ars.els-cdn.com/content/image/1-s2.0-S0140988324004936-mmc1.zip) 

> Cepni, O., Şensoy, A., & Yılmaz, M. H. (**2024**). Climate change exposure and cost of equity. **Energy Economics**, 130, 107288. [Link](https://doi.org/10.1016/j.eneco.2023.107288) (rep), [PDF](https://file-lianxh.oss-cn-shenzhen.aliyuncs.com/Refs/2026-Spring/Cepni_2024_Climate_change_exposure_and_cost_of_equity.pdf), [Google](<https://scholar.google.com/scholar?q=Climate change exposure and cost of equity>). [Replication](https://ars.els-cdn.com/content/image/1-s2.0-S0140988323007867-mmc1.zip)

> Bao, L., Huang, D., & Lin, C. (**2025**). Can Artificial Intelligence Improve Gender Equality Evidence from a Natural Experiment. **Management Science**. [Link](https://doi.org/10.1287/mnsc.2022.02787), [PDF](https://file-lianxh.oss-cn-shenzhen.aliyuncs.com/Refs/2026-Spring/Bao-2024-MS.pdf), [PDF-wp](https://file-lianxh.oss-cn-shenzhen.aliyuncs.com/Refs/2026-Spring/Bao-2024-MS-wp.pdf), [Appendix](https://pubsonline.informs.org/doi/suppl/10.1287/mnsc.2022.02787/suppl_file/mnsc.2022.02787.sm1.pdf), [Google](<https://scholar.google.com/scholar?q=Can Artificial Intelligence Improve Gender Equality Evidence from a Natural Experiment>), [Replication](https://services.informs.org/dataset/download.php?doi=mnsc.2022.02787).