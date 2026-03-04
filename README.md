# Stata 程序编写：Oster (2019) 系数稳定性检验的 Stata 实现

* 姓名: 马俊豪
* 学号: 21303162

## 内容简介

基于 Oster (2019) 提出的理论框架，本文开发了 Stata 命令 `coefstability`，实现了系数稳定性检验的自动化。该命令通过对比基准模型与完整模型的系数及 $R^2$ 变化，结合不可观测变量的选择比例（$\delta$）与最大理论拟合优度（$R_{\max}$），计算经偏误调整后的处理效应（$\beta^*$）及使效应归零的临界选择强度（$\delta^*$）。

本文详细介绍了该命令的语法结构、参数设定及推断功能，并通过复现 *Energy Economics* 三篇近期文献（Acheampong & Said, 2024; Cepni et al., 2024；Bao etal.,2024），展示了其在截面与面板数据分析中的应用。`coefstability` 为研究者提供了一个便捷、严谨的工具，以量化评估实证结果的稳健性。

### 内容说明

- data：存放本文复现案例所使用的数据，文件名对应原文名称。
- myado：存放自定义命令 `coefstability` ，以及运行本文 dofile 所需的外部命令。
- Orig_dofile：存放所复现三篇文章作者提供的原始资料。
- out： 存放本文使用的原始图表。
- refs： 存放用于在 Stata 中调用参考文献的 dofile。

### 代码运行

- 如需使用本文提供的自定义命令 `coefstability` ，请将 `coefstability.ado` 文件复制到以下目录之一：
  - Windows: `C:\stata\ado\personal\`
  - Mac/Linux: `~/Documents/Stata/ado/personal/`
- 运行 `myado.do` 以安装所有外部命令，完成后建议重启 Stata 以确保命令正常加载。
- 运行本文提供的的 dofile `T14_马俊豪_2026.do` 前，请更改 全局宏中的 `PP` , 将其设置为本项目所在的路径。其余代码无需修改，可直接点击执行。
