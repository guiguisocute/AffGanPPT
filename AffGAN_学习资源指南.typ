// ===================== 文档全局设置 =====================
#set document(title: "AffGAN 论文数学前置 · 学习资源指南", author: "学习路线整理")

#set page(
  paper: "a4",
  margin: (top: 2.3cm, bottom: 2.2cm, left: 2.2cm, right: 2.2cm),
  numbering: "1",
  number-align: center,
)

#set text(
  font: ("Source Han Serif SC", "Source Han Serif"),
  lang: "zh", region: "cn",
  size: 10.5pt,
)
#set par(justify: true, leading: 0.82em, spacing: 1.0em, first-line-indent: 0em)

#show heading: set text(font: ("Source Han Serif SC", "SimHei"), weight: "bold")
#set heading(numbering: none)
#show heading.where(level: 1): it => { set text(size: 15pt); v(0.5em); block(it); v(0.15em) }
#show heading.where(level: 2): it => { set text(size: 12pt, fill: rgb("#1a4f8a")); v(0.3em); block(it) }
#show heading.where(level: 3): set text(size: 10.8pt)

#show link: it => text(fill: rgb("#1456a0"))[#underline(it)]
#show ref: set text(fill: rgb("#1a4f8a"))

// 资源条目样式
#let res(title, url, kind, lvl, body) = block(
  width: 100%,
  inset: (top: 4pt, bottom: 4pt, left: 10pt, right: 6pt),
  stroke: (left: 2pt + rgb("#9cc0e6")),
)[
  #set par(first-line-indent: 0em, leading: 0.7em)
  #text(weight: "bold", size: 10.5pt)[#title]
  #h(0.4em)
  #box(fill: rgb("#eaf2fb"), inset: (x: 4pt, y: 1pt), radius: 2pt)[#text(size: 8pt, fill: rgb("#2a5a92"))[#kind]]
  #h(0.2em)
  #box(fill: rgb("#f0ede6"), inset: (x: 4pt, y: 1pt), radius: 2pt)[#text(size: 8pt, fill: rgb("#7a6a3a"))[#lvl]]
  \
  #text(size: 8.5pt)[#link(url)]
  #v(2pt)
  #set text(size: 9.3pt)
  #body
]

#let maps(body) = text(size: 9pt, fill: rgb("#555555"))[📍 *对应论文：*#body]

// ===================== 封面 =====================
#align(center)[
  #v(1.0cm)
  #text(font: ("Source Han Serif SC", "SimHei"), size: 22pt, weight: "bold")[
    《用于图像超分辨率的摊销 MAP 推断》\
    数学前置 · 学习资源指南
  ]
  #v(0.4cm)
  #text(size: 11pt, fill: rgb("#666666"))[
    Amortised MAP Inference for Image Super-Resolution (AffGAN) — Study Resources
  ]
  #v(0.5cm)
  #line(length: 45%, stroke: 0.5pt + gray)
  #v(0.3cm)
  #text(size: 9.5pt, fill: rgb("#888888"))[
    按「概率推断 → 信息论散度 → 线性代数投影 → score/采样 → 进阶」五条主线组织\
    每条资源标注「类型 / 难度 / 对应论文章节」，链接均已核实
  ]
]

#v(0.6cm)

// 使用说明
#block(fill: rgb("#f7f7f7"), inset: 12pt, radius: 4pt, width: 100%)[
  #set text(size: 9.5pt)
  #set par(first-line-indent: 0em)
  *如何使用本指南。* 资源按「先建直觉 → 再补数学 → 最后看原始论文」的顺序排列。每个主题先给 1 个#text(weight: "bold")[首选入门]（⭐），再给若干补充。难度标记：#box(fill: rgb("#f0ede6"), inset: (x: 3pt, y: 1pt), radius: 2pt)[#text(size: 8pt)[入门]] 看完建直觉，#box(fill: rgb("#f0ede6"), inset: (x: 3pt, y: 1pt), radius: 2pt)[#text(size: 8pt)[进阶]] 含推导，#box(fill: rgb("#f0ede6"), inset: (x: 3pt, y: 1pt), radius: 2pt)[#text(size: 8pt)[原始]] 是论文/经典原文。

  *一个彩蛋。* 主题四「高维几何」的核心资源——"高维高斯像肥皂泡"——正是出自本论文作者之一 *Ferenc Huszár* 的博客；这也解释了论文 5.6 节为何特别讨论"众数在高维下高度非典型"。读它等于直接听作者讲课。
]

// ===================== 学习路线总表 =====================
= 学习路线总表

#table(
  columns: (auto, 1fr, auto, auto),
  align: (center + horizon, left + horizon, center + horizon, center + horizon),
  inset: 6pt,
  stroke: 0.4pt + rgb("#cccccc"),
  fill: (_, row) => if row == 0 { rgb("#1a4f8a") } else if calc.odd(row) { rgb("#f3f7fc") } else { white },
  table.header(
    ..([顺序], [主题（学完能看懂论文哪部分）], [建议时长], [对应章节]).map(c => text(fill: white, weight: "bold", size: 9.5pt)[#c])
  ),
  [1], [*贝叶斯点估计* — MAP / MLE / 后验均值的区别（看懂 Figure 1）], [1–2 天], [§3, 式(2)-(4)],
  [2], [*信息论散度* — 熵 / 交叉熵 / KL（理解训练目标 式 9）], [1–2 天], [§3.2, 式(9)(10)],
  [3], [*线性代数投影* — 伪逆 / 零空间 / 正交投影（本文核心创新）], [2–3 天], [§3.1, 附录B],
  [4], [*score 与去噪* — "去噪 = 估计 log 密度梯度"（式 12）], [2–3 天], [§3.3, 式(12)],
  [5], [*GAN 理论 + 变分推断* — 最优判别器、ELBO（附录 A/F）], [2–3 天], [§3.2, 附录A/F],
  [★], [*高维几何（选学）* — 测度集中 / 肥皂泡（5.6 节的批评）], [半天], [§5.6],
)

#v(0.3em)
#text(size: 9pt, fill: rgb("#777777"))[注：若时间紧张，优先级最高为主题 1、3、4 —— 分别撑起论文的"动机、架构创新、核心算法"。]

// ===================== 主题一 =====================
= 主题一 · 贝叶斯点估计（MAP / MLE / 后验均值）

#maps[§3 式(2)–(4)。理解"为什么 MSE 解=后验均值→模糊，而 MAP 解=众数→清晰"，看懂 Figure 1 的全部标注。]

#res("⭐ MLE vs MAP：两者的数学联系", "https://agustinus.kristia.de/blog/mle-vs-map/", "博客", "入门→进阶")[
  Agustinus Kristiadi 的博客。最干净地讲清 MAP 与 MLE 只差一个"先验项"，且 MLE 就是"无信息先验下的 MAP"。公式少而精，适合第一篇读。
]

#res("Full Explanation of MLE, MAP and Bayesian Inference", "https://towardsdatascience.com/full-explanation-of-mle-map-and-bayesian-inference-1db9a7fb1d2b/", "博客", "入门")[
  用抛硬币例子把三者从直觉到数值全部走一遍，并点明关键：MLE/MAP 给"点估计"，完整贝叶斯给"整条后验分布"——正是论文从"点估计"转向"采样"（5.6 节）的伏笔。
]

#res("The Intuition behind MLE and MAP（NBA 类比）", "https://medium.com/@devcharlie2698619/the-intuition-behind-maximum-likelihood-estimation-mle-and-maximum-a-posteriori-estimation-map-b8ba1ba1078f", "博客", "入门")[
  用"新手 vs 老练的 NBA 分析师"类比 MLE 与 MAP：MLE 易被一波手感带偏，MAP 用先验把估计拉回合理区间。记忆点强，适合建直觉。
]

#res("教材：Bishop《Pattern Recognition and Machine Learning》第 1–2 章", "https://www.microsoft.com/en-us/research/publication/pattern-recognition-machine-learning/", "教材", "进阶")[
  系统理解"点估计随损失函数而变"（平方损失→均值、绝对损失→中位数、0-1 损失→众数）的权威来源。这正是 Figure 1 三个估计量差异的根。
]

// ===================== 主题二 =====================
= 主题二 · 信息论：熵 / 交叉熵 / KL 散度

#maps[§3.2 式(9)(10)。核心是恒等式 $H[q,p] - "KL"[q‖p] = H[q]$——论文用它解释"AffGAN 为何偏好高熵、更多样的解"。]

#res("⭐ Generative Modeling 之前必看：交叉熵的编码直觉", "https://ramsane.github.io/articles/cross-entropy-explained-with-entropy-and-kl-divergence/", "博客", "入门")[
  用"用错误的编码表发消息要多花几个 bit"来解释 KL = 交叉熵 − 熵。是把信息论"翻译成人话"的最佳入口。
]

#res("Information Theory Fundamentals（含交互式可视化）", "https://nimasarang.com/blog/2024-08-24-information-theory/", "博客", "入门→进阶")[
  熵、交叉熵、KL、以及 *Jensen–Shannon 散度*（GAN 原始理论的量）一站式覆盖，带交互图和证明。还讲了 *forward KL vs reverse KL* 的差别——理解 GAN/变分推断模式行为的关键。
]

#res("Cross-entropy and KL divergence — Eli Bendersky", "https://eli.thegreenplace.net/2025/cross-entropy-and-kl-divergence/", "博客", "进阶")[
  偏数学但极清晰。明确点出"因为真实分布的熵 $H(P)$ 与模型无关，所以最小化交叉熵 ⟺ 最小化 KL"——这正是论文式(9)把 MAP 目标写成交叉熵的依据。
]

#res("Kullback–Leibler divergence — Wikipedia", "https://en.wikipedia.org/wiki/Kullback%E2%80%93Leibler_divergence", "参考", "原始")[
  作工具书查阅：KL 的非对称性、与 Bregman 散度的关系（附录 C 会用到）、链式法则分解（附录 F 用到）。
]

// ===================== 主题三 =====================
= 主题三 · 线性代数：伪逆 / 零空间 / 正交投影

#maps[§3.1 式(7) + 附录 B。本文最硬核的创新——仿射投影层 $Pi_x^A f = (I - A^+A)f + A^+x$。必须懂：$(I-A^+A)$ 是到 $A$ 零空间的投影，故残差下采样恒为 0。]

#res("⭐ 3Blue1Brown《线性代数的本质》第 7 章：列空间与零空间", "https://www.youtube.com/watch?v=uQhTuRlWMxw", "视频", "入门")[
  Grant Sanderson 用动画讲清 *column space（值域/像）* 与 *null space（核/零空间）* 的几何含义。看懂这一集，式(7) 的"残差落在零空间→下采样必为 0"就一目了然。
]

#res("3Blue1Brown《线性代数的本质》完整播放列表", "https://www.youtube.com/playlist?list=PLZHQObOWTQDPD3MizzM2xVFitgF8hE_ab", "视频", "入门")[
  共 15 集。若线代基础薄弱，建议至少看第 3（线性变换）、7（列/零空间）、9（点积与对偶）、13（基变换）集。视觉优先，几乎不需要预备知识。
]

#res("The Moore-Penrose Pseudoinverse（UCLA Math 33A, Laub 讲义）", "https://www.math.ucla.edu/~laub/33a.2.12s/mppseudoinverse.pdf", "讲义", "进阶")[
  伪逆 $A^+$ 的四条定义性质（$A A^+A=A$ 等）与 SVD 构造法的简洁 PDF 讲义。论文式(7) 反复用到这些性质。
]

#res("Moore-Penrose Pseudoinverse 与投影矩阵", "https://seanie12.github.io/blog/linear%20algebra/pesudo-inverse/", "博客", "进阶")[
  重点讲"$A A^+$ 与 $A^+A$ 都是 *正交投影矩阵*"这一关键事实——这正是仿射投影层能保证输入输出一致性的数学根源。
]

#res("教材：Strang《Introduction to Linear Algebra》(四个基本子空间)", "https://math.mit.edu/~gs/linearalgebra/", "教材", "进阶")[
  若想真正吃透"行空间/列空间/零空间/左零空间"四个基本子空间与最小二乘的关系（附录 B 的伪逆数值估计就是最小二乘思想），Strang 是黄金标准。配套 MIT 18.06 公开课视频。
]

// ===================== 主题四 =====================
= 主题四 · score 函数与去噪（"去噪 = 估计梯度"）

#maps[§3.3 式(12)：$(f^*(y)-y)\/sigma^2 approx nabla_y log p_Y(y)$。AffDG 方法的全部理论依据，也是当今扩散模型的同源思想。]

#res("⭐ Yang Song：Generative Modeling by Estimating Gradients of the Data Distribution", "https://yang-song.net/blog/2021/score/", "博客", "入门→进阶")[
  score-based 模型的权威科普长文。把 *score function = log 密度的梯度*、*denoising score matching*、*Langevin 采样* 串成一条线，配大量动图。读懂它，论文式(11)(12) 的去噪引导就彻底通了。#text(fill: rgb("#888888"))[（强烈推荐，本主题首选）]
]

#res("Yang Song：Sliced Score Matching", "https://yang-song.net/blog/2019/ssm/", "博客", "进阶")[
  讲 score matching 如何*绕开难以计算的配分函数*，只匹配 score。理解"为什么不需要显式知道先验 $p_Y$ 就能拿到梯度"。
]

#res("Denoising Score Matching 详解（含推导）", "https://johfischer.com/2022/09/18/denoising-score-matching/", "博客", "进阶")[
  一步步推导"加高斯噪声去噪"与"匹配 score"的等价性。是论文式(12) 那个约等号的完整证明版。
]

#res("原始论文：Vincent (2011) A Connection Between Score Matching and Denoising Autoencoders", "https://www.iro.umontreal.ca/~vincentp/Publications/smdae_techreport.pdf", "论文", "原始")[
  论文式(12) 直接引用的源头（Vincent, 2011）。证明了贝叶斯最优去噪器隐含数据 log 概率的梯度。想追根溯源必读。
]

// ===================== 主题五 =====================
= 主题五 · GAN 理论与变分推断

#maps[§3.2 + 附录 A（最优判别器 $D^* = p_Y\/(p_Y+q_G)$、与 KL/JS 的联系）；附录 F（把随机版 AffGAN 解释为变分推断）。]

#res("⭐ Lilian Weng：From GAN to WGAN", "https://lilianweng.github.io/posts/2017-08-20-gan/", "博客", "入门→进阶")[
  GAN 理论的最佳中文友好讲解（英文）。完整推导*最优判别器*、并说明在最优判别器下 GAN 目标 = 最小化 JS 散度。还点出 GAN 不稳定源于"高维下两分布支撑集不相交"——这正是论文附录 C *实例噪声* 要解决的问题。亦有 arXiv 版 (1904.08994)。
]

#res("原始论文：Goodfellow et al. (2014) Generative Adversarial Nets", "https://arxiv.org/abs/1406.2661", "论文", "原始")[
  GAN 开山之作。论文式(10) 与附录 A 的更新规则都建立在它之上。看第 3–4 节的极小极大博弈与最优判别器证明。
]

#res("Lilian Weng：Flow-based / VAE 等生成模型综述", "https://lilianweng.github.io/posts/2018-10-13-flow-models/", "博客", "进阶")[
  理解附录 F"摊销变分推断"的背景：为何 $p(x)=integral p(x|z)p(z) dif z$ 难算、变分推断如何用 ELBO 绕开。
]

#res("Tutorial #5: Variational Autoencoders (RBC Borealis)", "https://rbcborealis.com/research-blogs/tutorial-5-variational-auto-encoders/", "博客", "入门→进阶")[
  ELBO 与"重建损失 + KL 正则"的直觉解释，并讲清 VAE 与 EM 算法的关系。论文附录 F 把 AffGAN 类比为 VAE，读此打底最顺。
]

#res("原始论文：Kingma & Welling (2014) Auto-Encoding Variational Bayes", "https://arxiv.org/abs/1312.6114", "论文", "原始")[
  VAE 原文，论文附录 F 直接对标的工作。重点看 ELBO 推导与重参数化技巧。
]

// ===================== 主题六 =====================
= 主题六（选学）· 高维几何：测度集中与"肥皂泡"

#maps[§5.6 的批评："高维标准高斯的典型样本范数 ≈ $sqrt(d)$，而众数范数为 0，故众数高度非典型"——这是质疑纯 MAP、转向后验采样的关键论据。]

#res("⭐ Why High-Dimensional Gaussians Feel Like Soap Bubbles", "https://rd.me/typicality-soap-bubble", "博客", "入门")[
  用"肥皂泡"比喻讲透测度集中：高维高斯的概率质量几乎全在一层薄壳上，而密度最高的原点反而几乎没有样本。直接对应论文 5.6 节的论证。#text(fill: rgb("#888888"))[（该比喻源自本文作者 Ferenc Huszár 的博客 inFERENCe）]
]

#res("The Counterintuitive Behavior of High-Dimensional Gaussians — Mianzhi Wang", "https://research.wmz.ninja/articles/2018/03/the-counterintuitive-behavior-of-high-dimensional-gaussian-distributions.html", "博客", "进阶")[
  带 *Gaussian Annulus Theorem（高斯环带定理）* 的较严格版本，量化"99% 质量集中在薄壳"的现象。想要数学保证看这篇。
]

#res("The unintuitive nature of high-dimensional spaces", "https://andrewcharlesjones.github.io/journal/high-dim-gaussians.html", "博客", "进阶")[
  从"密度 vs 体积"的竞争角度解释悖论：虽然原点密度最高，但远离均值处体积大得多，质量被挤到中间的窄带。配模拟代码，便于动手验证。
]

#v(0.6em)
#line(length: 100%, stroke: 0.4pt + rgb("#cccccc"))
#v(0.3em)
#block(fill: rgb("#eef4fb"), inset: 11pt, radius: 4pt, width: 100%)[
  #set text(size: 9.3pt)
  #set par(first-line-indent: 0em)
  *学完后的建议路径。* ① 先用 1 周过完主题 1–2（概率 + 信息论），同时配 3B1B 线代视频热身；② 第 2 周攻主题 3–4（伪逆投影 + score），这是论文的技术核心；③ 第 3 周读附录 A/F 与 GAN/VAE 原文，回看译文里的"译者注"对照理解；④ 最后重读论文 Figure 1 与 5.6 节，检验是否真的打通"MAP→交叉熵→投影→GAN"这条主线。
]
