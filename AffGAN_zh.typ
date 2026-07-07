// ===================== 文档全局设置 =====================
#set document(title: "用于图像超分辨率的摊销 MAP 推断", author: "Sønderby 等")

#set page(
  paper: "a4",
  margin: (top: 2.4cm, bottom: 2.4cm, left: 2.3cm, right: 2.3cm),
  numbering: "1",
  number-align: center,
)

// 正文字体：思源宋体；西文/数学保持默认 New Computer Modern
#set text(
  font: ("Source Han Serif SC", "Source Han Serif"),
  lang: "zh",
  region: "cn",
  size: 10.5pt,
  weight: "regular",
)
#set par(justify: true, leading: 0.85em, first-line-indent: 2em, spacing: 1.05em)

// 标题字体使用黑体（思源/微软雅黑回退）
#show heading: set text(font: ("Source Han Serif SC", "SimHei"), weight: "bold")
#set heading(numbering: "1.1")
#show heading.where(level: 1): it => {
  set text(size: 15pt)
  v(0.6em)
  block(it)
  v(0.2em)
}
#show heading.where(level: 2): set text(size: 12.5pt)
#show heading.where(level: 3): set text(size: 11pt)

// 数学公式编号
#set math.equation(numbering: "(1)")

// 链接与引用样式
#show ref: set text(fill: rgb("#1a4f8a"))
#show link: set text(fill: rgb("#1a4f8a"))

// 行间距让数学更舒展
#set math.equation(supplement: "式")

// ===================== 译者注样式盒 =====================
#let note(body) = block(
  fill: rgb("#eef4fb"),
  stroke: (left: 2.5pt + rgb("#3a76b8")),
  inset: (left: 12pt, right: 10pt, top: 8pt, bottom: 8pt),
  radius: 2pt,
  width: 100%,
)[
  #set text(size: 9.5pt)
  #set par(first-line-indent: 0em, leading: 0.7em)
  #text(weight: "bold", fill: rgb("#2a5a92"))[💡 译者注 ] #h(0.2em) #body
]

// ===================== 封面 =====================
#align(center)[
  #v(1.6cm)
  #text(size: 12pt, fill: rgb("#555555"))[作为会议论文发表于 ICLR 2017]
  #v(1.2cm)
  #text(font: ("Source Han Serif SC", "SimHei"), size: 24pt, weight: "bold")[
    用于图像超分辨率的\ 摊销 MAP 推断
  ]
  #v(0.5cm)
  #text(size: 12pt, fill: rgb("#666666"))[
    Amortised MAP Inference for Image Super-Resolution
  ]
  #v(1.0cm)
  #text(size: 11pt)[
    Casper Kaae Sønderby#super[1,2], Jose Caballero#super[1], Lucas Theis#super[1],\
    Wenzhe Shi#super[1] & Ferenc Huszár#super[1]
  ]
  #v(0.3cm)
  #text(size: 9.5pt, fill: rgb("#666666"))[
    #super[1] Twitter, 英国伦敦 #h(1em) #super[2] 哥本哈根大学, 丹麦
  ]
  #v(1.2cm)
  #line(length: 40%, stroke: 0.5pt + gray)
  #v(0.4cm)
  #text(size: 9.5pt, fill: rgb("#888888"))[
    中文翻译重排版 · 保留全部公式、图表与原始排版结构\
    （专业术语保留英文，重难点附译者注）
  ]
  #v(1.4cm)
]

// 摘要
#block(
  fill: rgb("#f7f7f7"),
  inset: 14pt,
  radius: 4pt,
  width: 100%,
)[
  #set par(first-line-indent: 0em, justify: true)
  #align(center)[#text(font: ("Source Han Serif SC", "SimHei"), size: 12pt, weight: "bold")[摘　要]]
  #v(0.4em)
  #set text(size: 10pt)
  图像超分辨率（super-resolution, SR）是一个_欠定（underdetermined）的逆问题_：大量看似合理的高分辨率图像都可以解释同一张下采样图像。当前大多数单图像 SR 方法采用经验风险最小化（empirical risk minimisation），通常配合逐像素的均方误差（mean squared error, MSE）损失。然而，这类方法的输出往往模糊、过度平滑，整体上显得不真实。一种更可取的做法是采用最大后验（Maximum a Posteriori, MAP）推断，它偏好那些在图像先验下始终具有高概率、因而看起来更可信的解。然而，针对 SR 的直接 MAP 估计并不容易，因为它要求我们从样本中构建图像先验模型。

  本文提出了用于*摊销 MAP 推断（amortised MAP inference）*的新方法，借助一个卷积神经网络直接计算 MAP 估计。我们首先提出一种新颖的神经网络架构，它将网络输出投影到“有效 SR 解所张成的仿射子空间（affine subspace）”上，从而保证网络的高分辨率输出始终与低分辨率输入保持一致。我们证明：在该架构下，摊销 MAP 推断问题可归约为最小化两个分布之间的交叉熵（cross-entropy），这与训练生成模型十分相似。我们提出三种求解该优化问题的方法：(1) 生成对抗网络（Generative Adversarial Networks, GAN）；(2) 去噪器引导的 SR——它将去噪过程的梯度估计反向传播以训练网络；(3) 以最大似然训练的图像先验为基础的基线方法。实验表明，基于 GAN 的方法在真实图像数据上表现最佳，在照片级真实感（photo-realistic）的纹理 SR 上效果尤为突出。
]

#v(0.6em)

// ===================== 目录 =====================
#block(
  width: 100%,
  inset: (top: 6pt),
)[
  #align(center)[#text(font: ("Source Han Serif SC", "SimHei"), size: 14pt, weight: "bold")[目　录]]
  #v(0.6em)
  #set text(size: 10pt)
  #show outline.entry.where(level: 1): it => {
    set text(weight: "bold")
    v(0.3em, weak: true)
    it
  }
  #outline(title: none, indent: auto, depth: 3)
]

#pagebreak()

// ===================== 正文 =====================

= 引言

图像超分辨率（SR）是一个欠定逆问题：给定一张低分辨率（low resolution, LR）输入，估计与之对应的高分辨率（high resolution, HR）图像。近年来，由于它在许多应用中既能提升视觉体验、又能限制需要存储或传输的原始像素数据量，因而引起了大量研究兴趣。SR 在医学诊断、司法取证等领域有诸多应用（Nasrollahi & Moeslund, 2014 及其引用的文献），而本文主要的动机是提升应用于自然图像时的感知质量（perceptual quality）。当前大多数单图像 SR 方法采用经验风险最小化，通常配合逐像素的 MSE 损失（Dong 等, 2016; Shi 等, 2016）。

然而，MSE（以及一般的凸损失函数）在面对多模态（multimodal）、非平凡分布（如自然图像上的分布）中的不确定性时，存在已知的局限。在 SR 中，大量看似合理的图像都能解释同一个 LR 输入，而任何以 MSE 训练的模型的*贝叶斯最优（Bayes-optimal）*行为，是输出这些合理解按其后验概率加权后的*均值*。对于自然图像，这种平均行为会导致模糊、过度平滑、整体显得不真实的输出——也就是说，所产生的估计在自然图像先验下概率很低。

针对我们的应用，一种理想化的方法应当使用全参考（full-reference）感知损失函数，以刻画人类视觉感知系统对各种失真的敏感度。

#note[
  *为什么 MSE 会导致模糊？* 当一个 LR 输入对应多个可能的 HR 解时，最小化 MSE 等价于让模型预测所有可能解的*期望（平均）*。把许多锐利但彼此错位的真实纹理平均起来，结果自然是一张“糊掉”的图。这正是“逐像素均值”惩罚的根本缺陷，也是本文转向 MAP 推断（取概率最高的“众数 / mode”而非均值）的核心出发点。
]

然而，最广泛使用的 MSE 损失及与之相关的峰值信噪比（peak-signal-to-noise-ratio, PSNR）指标，已被证明与人类对图像质量的感知相关性很差（Laparra 等, 2016; Wang 等, 2004）。人们提出了一些更好的感知质量指标，其中最流行的是结构相似性（structural similarity, SSIM）（Wang 等, 2004）及其多尺度变体（Wang 等, 2003）；更多近期研究可参见（Laparra 等, 2010; 2016; Bruna 等, 2016）。尽管这些指标与人类感知的相关性有所改善，但它们仍不能为训练 SR 神经网络（NN）提供完全令人满意的、可替代 MSE 的方案。

在缺乏令人满意的感知损失函数的情况下，我们离开经验风险最小化框架，提出仅基于自然图像统计的方法。本文主张：一种可取的做法是采用摊销 MAP 推断，它偏好具有高后验概率（因而在图像先验下也具有高概率）的解，同时保留摊销推断在计算上的优势。为了说明为何 MAP 推断是可取的，考虑 @fig:fig1 (a) 中的玩具问题：HR 数据是二维的 $y = [y_1, y_2]$，服从瑞士卷（Swiss-roll）密度分布；LR 观测被定义为两个像素的平均 $x = (y_1 + y_2) \/ 2$。考虑观测到一个 LR 数据点 $x = 0.5$：所有可能的 HR 解构成直线 $y_1 = 2x - y_2$——更一般地，是一个仿射子空间——如 @fig:fig1 (a) 中虚线所示。因此后验分布 $p(y|x)$ 是退化的（degenerate），对应于先验沿该直线的一个切片，如图中红色阴影所示。若最小化 MSE 或平均绝对误差（Mean Absolute Error, MAE），贝叶斯最优解将分别落在该直线上的*均值*或*中位数*处。

#figure(
  image("images/fig1.png", width: 78%),
  caption: [
    通过一个玩具示例说明 SR 问题。二维 HR 数据 $y = [y_1, y_2]$ 从瑞士卷分布中采样（灰色）。下采样建模为 $x = (y_1 + y_2)\/2$。(a) 给定观测 $x = 0.5$，有效 SR 解沿直线 $y_2 = 1 - y_1$ 分布（橙线）；红色阴影表示后验 $p_(Y|X=0.5)$ 的大小。MSE、MAE 下的贝叶斯最优估计以及 $x=0.5$ 时的 MAP 估计已标注；不同 $x in [-8, 8]$ 对应的 MAP 估计也一并画出。(b) 在 $x in [-8, 8]$ 上的各模型输出，以及由在 $p_Y$ 上训练的去噪函数估计出的梯度。注意 AffGAN 与 AffDG 模型很好地拟合了后验众数，而 MSE 与 MAE 模型的输出普遍落入低概率区域。
  ],
) <fig:fig1>

#figure(
  table(
    columns: 3,
    align: (left, center, center),
    stroke: none,
    table.hline(stroke: 0.8pt),
    table.header([], [$H[q_theta, p_Y]$], [$ell_("MSE")(x, A y)$]),
    table.hline(stroke: 0.5pt),
    [MAP], [3.15], [—],
    [MSE], [9.10], [$1.25 dot 10^(-2)$],
    [MAE], [6.30], [$4.04 dot 10^(-2)$],
    [AffGAN], [4.10], [0.0],
    [SoftGAN], [4.25], [$8.87 dot 10^(-2)$],
    [AffDG], [3.81], [0.0],
    [SoftDG], [4.19], [$1.01 dot 10^(-1)$],
    table.hline(stroke: 0.8pt),
  ),
  caption: [直接估计的交叉熵 $H[q_theta, p_Y]$ 值。AffGAN 与 AffDG 取得了接近 MAP 解的交叉熵值，证实它们确实在最小化我们所期望的目标量。MSE 与 MAE 模型表现较差，因为它们并不最小化交叉熵。此外，使用仿射投影（Aff）的模型优于软约束（Soft）模型。],
  kind: table,
) <tab:tab1>

这个例子说明，MSE 与 MAE 可能产生在数据先验下概率极低的输出，而 MAP 推断总会找到*众数（mode）*——按定义它必然落在高概率区域。关于 MAP 推断可能存在的局限，详见 @sec:criticism 的讨论。我们的第一项贡献，是设计了一种卷积神经网络（CNN）架构以利用 SR 问题的结构。图像下采样是一种线性变换，可以建模为带步幅的卷积（strided convolution）。如 @fig:fig1 (a) 所示，与任意 LR 图像 $x$ 相容的所有 HR 图像 $y$ 张成一个仿射子空间。我们证明：通过使用特定选取的线性卷积层与反卷积层，可以实现一个到该仿射子空间的投影。这保证了我们的 CNN 始终输出与输入一致的估计。该*仿射投影层（affine projection layer）*可以附加到任何 CNN 上，乃至任何其他可训练的 SR 算法上。

利用该架构，我们证明：将模型训练用于 MAP 推断，可归约为最小化 HR 数据分布 $p_Y$ 与“模型输出在随机 LR 图像上评估时所隐含的分布 $q_G$”之间的交叉熵 $H[q_G, p_Y]$。其结果是，我们不再需要成对的 HR-LR 图像，训练变得更像是训练生成模型。然而，直接最小化交叉熵是不可行的；本文提出三种方法，它们都依赖于将模型输出投影到“有效解的仿射子空间”，以直接从数据中近似该目标：

+ 我们提出生成对抗网络（GAN）（Goodfellow 等, 2014）的一个变体，它近似地最小化 $q_G$ 与 $p_Y$ 之间的 KL 散度（Kullback–Leibler divergence）与交叉熵。我们的分析为在图像 SR 中使用 GAN（Ledig 等, 2016）提供了理论依据。我们还引入一个称为*实例噪声（instance noise）*的技巧，它可普遍用于缓解 GAN 训练的不稳定性。

+ 我们利用去噪（denoising）来捕捉自然图像统计。贝叶斯最优去噪近似地学会沿数据分布对数概率的方向迈出一个梯度步（Alain & Bengio, 2014; Rasmus 等, 2015; Greff 等, 2016）。这些来自去噪的梯度估计可以直接通过网络反向传播，借助梯度下降最小化 $q_G$ 与 $p_Y$ 之间的交叉熵。

+ 我们提出一种直接对数据概率密度建模的方法：用一个以最大似然训练的生成模型来建模密度。我们使用一个基于 PixelCNN（Oord 等, 2016）与条件高斯尺度混合的混合模型（Mixture of Conditional Gaussian Scale Mixtures, MCGSM；Theis 等, 2012）的可微生成模型，我们相信其性能在此类方法中已非常接近当前最优水平。

在 @sec:experiments 中，我们在二维玩具数据集与真实图像数据集上，实证地展示了所提方法的行为。

= 相关工作

GAN 框架由 Goodfellow 等（2014）提出，他们也证明了在某些条件下这些模型最小化 $q_G$ 与 $p_Y$ 之间的香农–詹森散度（Shannon-Jensen Divergence）。在 @sec:affgan 中，我们提出一种对应于最小化 $"KL"[q_G || p_Y]$ 的更新规则。最近，Nowozin 等（2016）给出了一种更一般的处理，将 GAN 与 $f$-散度最小化联系起来。与我们的工作并行，Mohamed & Lakshminarayanan（2016）的理论工作提出了对 GAN 式算法中学习过程的统一视角，我们的变体可视为其中一个特例。近期若干 GAN 论文聚焦于提升其稳定性的算法技巧（Radford 等, 2015; Salimans 等, 2016）。在 @sec:instnoise 中，我们引入了另一个这样的技巧——实例噪声。我们讨论其理论动机，并将它与 Salimans 等（2016）提出的*单边标签平滑（one-sided label smoothing）*进行比较。Arjovsky & Bottou（2017）在并行工作中提出过一种类似方法。

近来，已有若干尝试利用自然图像的深层表示来提升图像 SR 的感知质量。Bruna 等（2016）与 Li & Wand（2016）在一个预训练用于物体分类的深层 NN 的非线性特征空间中度量欧氏距离。Dosovitskiy & Brox（2016）与 Ledig 等（2016）采用类似思路，并额外加入对抗损失项。Garcia（2016）的未发表工作探索了将 GAN 与“LR 输入和下采样输出之间的 $L_1$ 惩罚”相结合。我们注意到，这些方法中使用的软 $L_2$ 或 $L_1$ 惩罚，可被解释为假设了高斯或拉普拉斯观测噪声。与之相反，我们的方法不假设任何观测噪声，而是通过 @sec:likelihood 所述的仿射投影*精确地*满足输入与输出的一致性。在另一项工作中，Larsen 等（2015）提出用 GAN 判别器学到的度量来替代训练变分自编码器时使用的逐像素 MSE。我们基于去噪器的方法利用了概率建模与“学习去噪”之间的一个根本联系（参见如 Vincent 等, 2008; Alain & Bengio, 2014; Vincent, 2011; Särelä & Valpola, 2005; Rasmus 等, 2015）：一个贝叶斯最优去噪器可用于估计数据对数概率的梯度。据我们所知，本工作是首次将去噪器的输出*显式地反向传播*以训练另一个网络。

= 理论 <sec:theory>

考虑一个由 $theta$ 参数化的函数 $f_theta (x)$，它将 LR 观测 $x$ 映射为 HR 估计 $hat(y)$。当前大多数 SR 方法通过经验风险最小化来优化模型参数：

$ op("argmin")_theta EE_(y,x)[ell(y, f_theta (x))] $ <eq:erm>

其中 $y$ 是真实目标，$ell$ 是某个损失函数。该损失函数通常是一个简单的凸函数，最常见的是 MSE，即 $ell_("MSE")(y, hat(y)) = ||y - hat(y)||_2^2$，如（Dong 等, 2016; Shi 等, 2016）。在此，我们转而希望执行 MAP 推断。对于单个 LR 观测，MAP 估计为

$ hat(y)(x) = op("argmax")_y log p_(Y|X)(y|x) $ <eq:map>

与其对每个 $x$ 分别计算 $hat(y)$，我们执行*摊销推断*，即希望训练 SR 函数 $f_theta (x)$ 直接计算 MAP 估计。学习参数 $theta$ 的一个自然损失函数是平均对数后验：

$ op("argmax")_theta EE_x log p_(Y|X)(f_theta (x)|x) $ <eq:logpost>

其中期望对 LR 观测 $x$ 的分布取。该损失依赖于未知的后验分布 $p_(Y|X)$。我们用贝叶斯法则将对数后验分解如下：

$ op("argmax")_theta [ underbrace(EE_x log p_(X|Y)(x|f_theta (x)), "似然 (Likelihood)") + underbrace(EE_x log p_Y (f_theta (x)), "先验 (Prior)") - underbrace(EE_x log p_X (x), "边缘似然 (Marginal Likelihood)") ] $ <eq:bayes>

== 处理似然项 <sec:likelihood>

注意 @eq:bayes 的最后一项——边缘似然——不依赖于 $theta$，因此我们只需处理似然项与图像先验项。SR 中的观测模型可描述为

$ x = A hat(y) $ <eq:obs>

其中 $A$ 是用于图像下采样的线性变换。一般而言，$A$ 可建模为带步幅的二维卷积。因此 @eq:bayes 中的似然项是退化的，$p(x|f_theta (x)) = delta(x - A f_theta (x))$，于是 @eq:bayes 可重写为一个约束优化问题：

$ op("argmax")_(theta; forall x: A f_theta (x) = x) EE_x [log p_Y (f_theta (x))] $ <eq:constrained>

为满足约束，我们引入一类始终保证 $A f_theta (x) = x$ 的参数化函数。具体地，我们提出使用如下形式的函数：

$ g_theta (x) = Pi_x^A f_theta (x) = (I - A^+ A) f_theta (x) + A^+ x $ <eq:proj>

其中 $f_theta$ 是从 LR 到 HR 空间的任意映射，$Pi_x^A$ 是到仿射子空间 ${y : A y = x}$ 的投影，$A^+$ 是 $A$ 的 Moore-Penrose 伪逆（pseudoinverse），满足 $A A^+ A = A$ 和 $A^+ A A^+ = A^+$。方便的是，若 $A$ 是带步幅的二维卷积，则 $A^+$ 就成为一个反卷积（deconvolution）或上卷积（up-convolution）——这是深度学习中的标准操作（如 Shi 等, 2016）。需要强调的是，最优反卷积 $A^+$ 并不简单地等于 $A$ 的转置：@fig:fig2 (d) 展示了与高斯下采样核 $A$ 相对应的上采样核 $A^+$。对任意 $A$，反卷积 $A^+$ 都易于求得，这里我们使用 @app:b 中详述的数值方法。

#note[
  *如何理解这个投影？* @eq:proj 把网络输出拆成两部分：$A^+ x$ 是“基线解”（直接把 LR 上采样回 HR，保证低频内容正确），而 $(I - A^+ A) f_theta$ 是“残差”。算子 $(I - A^+ A)$ 是到 $A$ 零空间（null-space）的投影——无论 $f_theta$ 输出什么，把残差再下采样都恒为 0。因此整个网络的输出经下采样后总能精确还原出输入 $x$，一致性*被结构强制保证*，而非靠损失项软性鼓励。
]

直观上，$A^+ x$ 可看作一个基线 SR 解，而 $(I - A^+ A) f_theta$ 是残差。操作 $(I - A^+ A)$ 是到 $A$ 零空间的投影，因此当我们对残差 $(I - A^+ A) f_theta$ 下采样时，无论 $f_theta$ 是什么，结果都保证为 0。借助这种形式的函数，我们可以把 @eq:constrained 转化为一个无约束优化问题：

$ op("argmax")_theta EE_x log p_Y (Pi_x^A f_theta (x)) $ <eq:uncons>

有趣的是，上述目标可用模型输出的概率分布 $q_theta (y) := integral delta(y - Pi_x^A f_theta (x)) p_X (x) dif x$ 表示如下：

$ op("argmax")_theta EE_x log p_Y (Pi_x^A f_theta (x)) = op("argmax")_theta EE_(hat(y) tilde q_theta) log p_Y (hat(y)) = op("argmin")_theta H[q_theta, p_Y] $ <eq:crossent>

其中 $H[q, p]$ 表示 $q$ 与 $p$ 之间的交叉熵，我们使用了 $H[q_theta, p_Y] = EE_(hat(y) tilde q_theta)[-log p_Y (hat(y))]$。为最小化该目标，我们*不再需要*经验风险最小化中那种成对的输入-输出对。取而代之，我们需要让“重建图像的边缘分布 $q_theta$”与“HR 图像的分布”相匹配。在这个意义上，问题变得更像是无监督学习或生成式建模。在以下各节中，我们利用仿射投影的性质，提出三种寻找最优 $theta$ 的方法。

== 仿射投影生成对抗网络 <sec:affgan>

生成对抗网络（Goodfellow 等, 2014）由两部分组成：一个生成器 $G$，它通过参数化映射将从某分布采样的噪声 $z tilde p_Z$ 转化为图像 $G(z)$；一个判别器 $D$，它学习区分真实图像与合成图像。生成器与判别器交替更新，结果使生成分布 $q_G$ 逐渐逼近真实数据分布 $p_Y$。GAN 的行为取决于生成器与判别器训练方式的具体细节。我们对 $D$ 和 $G$ 使用如下目标函数：

$ L(D; G) &= -EE_(y tilde p_Y) log D(y) - EE_(z tilde p_Z) log(1 - D(G(z))), \
  L(G; D) &= -EE_(z tilde p_Z) log (D(G(z)) / (1 - D(G(z)))). $ <eq:gan>

算法迭代两个步骤：首先固定 $G$，通过降低 $L(D; G)$ 更新 $D$；然后固定 $D$，通过降低 $L(G; D)$ 更新 $G$。可以证明，这相当于最小化 $"KL"[q_G || p_Y]$，其中 $q_G$ 是 $G$ 生成样本的分布。证明见 @app:a。#footnote[首次见于（Huszár, 2016）。]

在 SR 的语境中，仿射投影后的 SR 函数 $Pi_x^A f_theta$ 扮演生成器的角色。生成器的输入不再是噪声，而是低分辨率图像 $x tilde p_X$。在其余设置不变的情况下，我们便可部署 GAN 算法来最小化 $"KL"[q_theta || p_Y]$。我们将此算法称为*仿射投影 GAN（affine projected GAN）*，简称 *AffGAN*。类似地，我们引入记号 *SoftGAN* 表示*不带*仿射投影的 GAN 算法，它转而使用一个额外的软约束 $ell_("LR") = "MAE"(x, A hat(y))$，如（Garcia, 2016）。注意交叉熵与 KL 散度之差正是 $q_theta$ 的熵：$H[q_theta, p_Y] - "KL"[q_theta || p_Y] = H[q_theta]$。因此，我们可以预期 AffGAN 倾向于偏好那些带来更高熵、从而整体上更多样化的近似 MAP 解。

#note[
  *交叉熵 vs. KL 散度的微妙差别。* 我们真正想最小化的是交叉熵 $H[q_theta, p_Y]$（这对应 MAP 目标 @eq:crossent）。但 GAN 实际最小化的是 KL 散度 $"KL"[q_theta || p_Y]$。两者相差一个 $-H[q_theta]$（即 $q_theta$ 自身的熵）。这意味着 GAN 在逼近 MAP 的同时，还额外“奖励”了输出的多样性，避免所有样本塌缩到同一个点（即缓解 mode collapse）——这其实是个有益的副作用。
]

=== 实例噪声 <sec:instnoise>

理论上，GAN 应当是一个收敛的算法。如果存在唯一的最优判别器，且每一步都将 $D$ 优化到完美，那么从技术上看，整个算法对应于对 $"KL"[q_theta || p_Y]$ 的某个估计关于 $theta$ 做梯度下降。然而在实践中，GAN 往往高度不稳定。那么理论究竟在哪里出了问题？我们认为，GAN 不稳定的主要原因在于 $q_theta$ 与 $p_Y$ 都是*高度集中（concentrated）*的分布，其支撑集（support）并不重叠。自然图像分布 $p_Y$ 通常被假设集中在一个低维流形（manifold）之上或附近。在大多数情况下，$q_theta$ 由于构造方式（如 AffGAN）本身就是退化的、类似流形的。因此，特别是在收敛之前，$q_theta$ 与 $p_Y$ 很有可能被多个判别器 $D$ 完美分开，这违反了收敛性证明的一个条件。

我们试图通过向 SR 样本与真实图像样本*同时*添加实例噪声来缓解这一问题。这相当于最小化散度 $d_sigma (q_theta, p_Y) = "KL"[p_sigma * q_theta || p_sigma * p_Y]$，其中 $p_sigma * q_theta$ 表示 $q_theta$ 与噪声分布 $p_sigma$ 的卷积。噪声水平 $sigma$ 可在训练过程中退火（anneal），噪声使我们能够在每次迭代中安全地将 $D$ 优化至收敛。该技巧与 Salimans 等（2016）引入的单边标签噪声相关，但不会在最优判别器中引入偏差；我们相信它是一种普遍适用于稳定 GAN 训练的有前景的技术。更多细节请参见 @app:c。

#note[
  *实例噪声为什么有效？* 想象两条几乎不重叠的细线（$q_theta$ 与 $p_Y$）。判别器可以轻松地用无数种方式把它们分开，每种方式给生成器的梯度方向都不同且不可靠，训练因此发散。给两条线都“吹上”一层高斯噪声后，它们变胖、开始重叠，最优判别器变得唯一，给生成器的梯度也变得稳定可靠。随训练逐渐把噪声 $sigma$ 退火到 0，最终回到原问题。
]

== 去噪器引导的超分辨率 <sec:dg>

为了通过梯度下降优化 @eq:constrained 的判据，我们需要它关于 $theta$ 的梯度：

$ partial / (partial theta) EE_x [log p(Pi_x^A f_theta (x))] = EE_x [ (partial / (partial y) log p(y)) bar_(y = Pi_x^A f_theta (x)) dot Pi_x^A partial / (partial theta) f_theta (x) ] $ <eq:dggrad>

这里 $partial / (partial theta) f_theta$ 是 SR 函数的梯度，可通过反向传播计算；而 $partial / (partial y) log p_Y (y)$ 由于 $p_Y$ 未知，需要进行估计。我们利用（Alain & Bengio, 2014; Särelä & Valpola, 2005）的结果：在无穷小高斯噪声的极限下，最优去噪函数可用于估计该梯度：

$ f_sigma^* = op("argmin")_f EE_(y tilde p_Y) ell_("MSE")(f(y + sigma epsilon), y) ==> (f^*(y) - y) / sigma^2 approx partial / (partial y) log p_Y (y) $ <eq:denoise>

其中 $epsilon tilde cal(N)(0, I)$ 是高斯白噪声，$f_sigma^*$ 是噪声水平 $sigma$ 下的贝叶斯最优去噪函数。利用这些结果，我们可以这样最大化 @eq:crossent：先训练一个神经网络去对 $p_Y$ 的样本去噪，然后将 @eq:denoise 给出的梯度估计经由 @eq:dggrad 中的链式法则反向传播，以更新 $theta$。我们把这种方法称为 *AffDG*，因为它使用了仿射子空间投影，并由去噪自编码器（denoising autoencoder, DAE）的梯度所引导。与前面类似，我们把以软约束方式施加 @eq:obs 的同类算法称为 *SoftDG*。

#note[
  *“去噪即学习梯度”* （@eq:denoise）是本节的关键洞见，源自 score matching 理论：一个训练好的去噪器，其“去噪输出减去带噪输入”这一向量，恰好近似指向数据对数概率上升最快的方向 $nabla_y log p_Y(y)$。于是我们无需显式知道先验 $p_Y$，就能拿到“往更真实图像方向走”的梯度，并把它接进 SR 网络的反向传播里。
]

== 密度引导的超分辨率 <sec:density>

作为摊销 MAP 推断的一个更直接的基线模型，我们用最大似然为 $p_Y$ 拟合一个可处理（tractable）却强大的密度模型，然后用“相对于该生成模型的交叉熵”来近似 @eq:crossent。我们使用一个类似于 PixelCNN（Oord 等, 2016）的深度生成模型，但采用连续（且可微）的 MCGSM（Theis 等, 2012）似然。这类模型在密度估计上达到当前最优水平，评估相对较快，并能产生视觉上有趣的样本（Oord 等, 2016）。我们把这种方法称为 *AffLL*，因为它使用仿射投影，并由密度模型的对数似然（log-likelihood）所引导。

= 实验 <sec:experiments>

我们设计实验以回答以下问题：

- @sec:theory 中提出的方法能否成功最小化交叉熵？$arrow.r$ @sec:swiss
- 仿射投影层是否会损害 CNN 用于图像 SR 的性能？$arrow.r$ @sec:affproof
- 所提方法能否产生感知上更优的 SR 结果？$arrow.r$ @sec:grass ~ @sec:natural

我们首先在“精确 MAP 推断在计算上可行”的数据上展示所提算法的行为。此处 HR 数据 $y = [y_1, y_2]$ 从一个二维含噪瑞士卷分布中采样，一维 LR 数据 $x$ 就是两个 HR 像素的平均。接着，我们在一系列自然图像实验中以 $4 times$ 下采样测试所提算法。对第一个数据集，我们从含草地纹理的 HR 图像中随机裁剪图块。众所周知，使用 MSE 或 MAE 损失对随机纹理做 SR 非常困难。最后，我们在真实的人脸图像数据（Celeb-A）与自然图像（ImageNet）上测试所提模型。所有模型都是卷积神经网络，使用 Theano（Team 等, 2016）与 Lasagne（Dieleman 等, 2015）实现。完整实验细节参见 @app:d。

= 结果与讨论

== 二维 MAP 推断：瑞士卷 <sec:swiss>

在本实验中，我们希望证明 AffGAN 与 AffDG 确实在最小化 @eq:crossent 中的 MAP 目标。为此，我们使用二维玩具问题，此时 $p_Y$ 可以通过暴力蒙特卡洛（Monte Carlo）来评估。@fig:fig1 (b) 展示了以不同判据训练的模型在 $x = [-8, 8]$ 上的输出。AffGAN 与 AffDG 的解大体拟合了主导众数，与 MAP 推断类似。而对于 MSE 与 MAE 模型，输出普遍落入先验密度较低的区域。@tab:tab1 给出不同方法所达到的交叉熵 $H[q_theta, p_Y]$，在 10 次随机初始化的独立试验上取平均。基于 GAN 与 DAE 的模型的交叉熵值相对接近最优 MAP 解（本例中我们能以暴力方式求得）。正如预期，MSE 与 MAE 模型表现较差，因为它们并不最小化 $H[q_theta, p_Y]$。

我们还计算了网络输入与下采样后网络输出之间的平均 MSE。对于仿射投影模型，该误差*恰好为 0*。软约束模型即使经过大量训练也只能近似满足该约束（@tab:tab1 第二列）。此外，我们观察到，与软约束版本相比，仿射投影模型通常能找到更低的交叉熵 $H[q_theta, p_Y]$。

== 仿射投影网络：用 MSE 判据做概念验证 <sec:affproof>

添加仿射投影 $Pi_x^A$ 会限制 SR 网络所能建模的函数类，因此验证“网络是否仍能在 SR 上达到与无约束 CNN 架构相同的性能”就很重要。为测试这一点，我们以 MSE 为目标函数，在 CelebA 数据集上训练了带与不带仿射投影的 CNN 来执行 SR。结果见 @fig:fig2。

#figure(
  image("images/fig2.png", width: 92%),
  caption: [
    训练过程中 MSE 模型在 CelebA 上的性能。(a) HR 模型输出 $hat(y)$ 与真实 HR 图像 $y$ 之间的 MSE 距离；(b) 同上但用 SSIM；(c) LR 空间中输入 $x$ 与下采样后模型输出 $A hat(y)$ 之间的 MSE。图例中的二元组表示：（(F)ixed 固定 / (T)rainable 可训练的仿射投影，(T)rained 已训练 / (R)andom 随机初始化的仿射投影）。使用预训练仿射投影的模型（固定、可训练）在所有指标上始终优于使用随机初始化仿射投影或不使用投影的模型。此外，如 (c) 所示，固定的预训练仿射投影确保了输入与下采样输出之间最好的一致性。(d) 给出仿射投影的 $A$（上）与 $A^+$（下）核。
  ],
) <fig:fig2>

首先注意，使用仿射投影时，一个随机初始化的网络从更低的初始损失开始学习，因为网络输出的低频分量已经与目标图像匹配。我们观察到，仿射投影网络通常比无约束网络训练得更快。此外，以 MSE 与 SSIM 衡量，仿射投影网络往往能找到更好的解（@fig:fig2 (a)-(b)）。为探究网络架构的哪些方面带来了性能提升，我们又评估了两个变体：在一个变体中，我们将仿射投影 CNN 初始化为实现正确的投影，但随后把 $A^+$ 当作可训练参数；在最后一个变体中，我们保持架构不变，但把最终的反卷积层 $A^+$ 随机初始化并允许其被训练。我们发现，将 $A^+$ 初始化为正确的 Moore-Penrose 逆很重要，而无论它在训练中是否被固定，我们都得到相似的结果。@fig:fig2 (c) 展示了网络输入与下采样后网络输出之间的误差。可以看到，精确的仿射投影网络将该误差保持在几乎 0.0（直到数值精度），而任何其他网络都会破坏这种一致性。@fig:fig2 (d) 展示了下采样核 $A$ 及其对应的最优 $A^+$ 核。

== 草地纹理 <sec:grass>

众所周知，随机纹理难以用 MSE 损失函数建模。@fig:fig3 展示了使用以不同损失函数训练的相同仿射投影 CNN 对草地纹理图块做 $4 times$ SR 的结果。当随机初始化时，仿射投影 CNN 总能产生具有正确低频分量的输出，如 @fig:fig3 中标为 Affinit 的第三栏所示。AffGAN 模型显然产生了最锐利的图像，我们发现这些图像在给定 LR 输入的情况下是合理的。注意，重建并非逐像素完美，但它具有正确的统计属性，足以让人类视觉系统将其识别为草地纹理。AffDG 与 AffLL 模型都产生了模糊的结果，我们尝试了多种优化方法都无法改善。基于这些发现，我们选择不再对这两个模型做进一步实验，转而专注于 AffGAN。关于这两个模型结果的讨论参见 @app:e。

#figure(
  image("images/fig3.png", width: 95%),
  caption: [
    草地纹理的 $4 times$ SR。上排展示 LR 模型输入 $x$、真实 HR 图像 $y$ 以及按图例排列的各模型输出。下排为上排图像局部放大。AffGAN 图像比略显模糊的 AffMSE 图像锐利得多。注意 AffDG 与 AffLL 都产生了非常模糊的结果。Affinit 展示未经训练的仿射投影模型的输出，即基线解，体现了使用 $A^+$ 上采样的效果。
  ],
) <fig:fig3>

== CelebA 人脸 <sec:celeba>

@fig:fig4 展示了使用不同损失函数训练的若干模型的 SR 结果。正如预期，MSE 训练的模型输出有些泛化且过度平滑的图像。对于 GAN 模型，无论仿射投影还是软约束模型，全局内容都是正确的。比较 AffGAN 与 SoftGAN 的输出，AffGAN 模型产生的图像略微更锐利，但似乎也含有略多的高频噪声。我们观察到软约束模型存在一些颜色漂移（colour drifting）。@tab:tab2 给出同样四个模型的定量结果，正如预期，就 PSNR 与 SSIM 而言，MSE 模型取得最佳分数。输入与输出之间的一致性清楚表明，对 MSE 与 GAN 两种损失，使用仿射投影的模型都比软约束版本更好地满足了 @eq:obs。

#figure(
  image("images/fig4.png", width: 72%),
  caption: [
    CelebA 人脸的 $4 times$ SR。模型输入 $x$、目标 $y$ 以及按图例排列的各模型输出。AffGAN 与 SoftGAN 都产生了明显比模糊的 MSE 输出更锐利的图像。我们发现 AffGAN 输出的图像比 SoftGAN 略微更锐利，但也带有略多的高频噪声。
  ],
) <fig:fig4>

#figure(
  table(
    columns: 4,
    align: (left, center, center, center),
    stroke: none,
    table.hline(stroke: 0.8pt),
    table.header([], [SSIM], [PSNR], [$ell_("MSE")(x, A hat(y))$]),
    table.hline(stroke: 0.5pt),
    [MSE], [0.90], [26.30], [$8.0 dot 10^(-5)$],
    [AffMSE], [0.91], [26.53], [$1.6 dot 10^(-10)$],
    [SoftGAN], [0.76], [21.11], [$2.3 dot 10^(-3)$],
    [AffGAN], [0.81], [23.02], [$9.1 dot 10^(-10)$],
    table.hline(stroke: 0.8pt),
  ),
  caption: [
    CelebA 数据集的 PSNR、SSIM 与 MSE 分数。就 HR 空间的 PSNR 与 SSIM 而言，正如预期 MSE 训练的模型取得最佳分数，且 AffGAN 优于 SoftGAN。就 $ell_("MSE")(x, A hat(y))$ 而言，使用仿射投影（Aff）的模型在输入 $x$ 与下采样后模型输出 $A hat(y)$ 之间显示出明显优于未使用投影模型的一致性。
  ],
  kind: table,
) <tab:tab2>

== 自然图像 <sec:natural>

@fig:fig5 展示了在 ImageNet 自然图像上训练的 AffGAN 将图像从 $32 times 32$ 做 $4 times$ SR 至 $128 times 128$ 像素的结果。对大多数图像，结果是锐利的，并与 LR 输入很好地对应。然而，我们在部分图像中仍能看到大多数 GAN 结果中存在的高频噪声。有趣的是，第三列所描绘的蛇被超分辨成了水——这显然是错误的，但考虑到 LR 输入图像，它仍然是一张非常合理的图像。此外，在图像先验下水的密度很可能高于蛇，这表明 GAN 模型“梦出”了合理的数据。

#figure(
  image("images/fig5.png", width: 88%),
  caption: [
    在 ImageNet 上使用 AffGAN 将图像从 $32 times 32$ 做 $4 times$ SR 至 $128 times 128$。AffGAN 输出（上排）、真实 HR 图像 $y$（中排）、模型输入 $x$（下排）。AffGAN 总体上产生合理的输出，但仍然容易与真实图像区分开。有趣的是，第三列所描绘的蛇被超分辨成了水——这显然是错误的，但考虑到 LR 输入图像，它仍然是一张非常合理的图像。
  ],
) <fig:fig5>

== 批评与未来方向 <sec:criticism>

反对 MAP 推断的一个论点是：分布的众数依赖于*表示（representation）*——通过一个可逆变换把变量变换到另一空间、再在变换后的空间中执行 MAP 推断，可能会因变换不同而得到不同答案。作为一个极端例子，考虑用其累积分布函数 $F = P(Y <= dot)$ 来变换一个连续随机标量 $Y$。所得变量 $F(Y)$ 服从均匀分布，因此区间 $(0, 1]$ 中的任意值都可以是众数。于是，如果允许使用不同的表示，MAP 估计就不是唯一的；并且无法保证我们在本文中所求的 24 位 RGB 像素表示下的 MAP 估计有任何特殊之处。如果在卷积神经网络的特征空间中、甚至仅仅换一个色彩空间中执行 MAP 估计，都可能得到不同的解。有趣的是，AffGAN 对坐标变换更具韧性：@eq:gan 包含额外项 $H[q_theta]$，它受变换影响的方式与 $H[q_theta, p_Y]$ 相同。

第二个论点关乎“MAP 估计看起来合理”这一假设。尽管按定义众数落在高概率区域，但这并不保证它的*外观*与随机样本有任何相似之处。例如，考虑从 $d$ 维标准正态分布中抽取的数据。由于测度集中（concentration of measure）现象，随着 $d$ 增大，一个典型样本的范数将以极高概率约为 $sqrt(d)$。然而众数的范数为 0。在这个意义上，分布的众数是高度非典型的。事实上，人类观察者很容易把噪声分布的一个典型样本与众数区分开，却很难注意到两个随机样本之间的差别。这一论点表明，从后验 $p_(Y|X)$ 中*采样*可能是获取合理重建的一种好方法，甚至是更可取的方法。

#note[
  *“众数未必典型”这一悖论很重要。* 在高维空间里，概率密度最高的点（众数）反而可能“长得最不像”真实样本——这是测度集中现象的直接后果。这解释了为何纯 MAP 有时仍不够自然，也为作者在 @app:f 中把 AffGAN 扩展为“从后验采样”的随机版本（即变分推断视角）埋下伏笔。
]

通过向生成器网络提供额外噪声，可以将 AffGAN 扩展为执行近似贝叶斯推断，这与（Denton 等, 2015）有些相似。在 @app:f 中我们证明，这种随机版本的 AffGAN 可被视为在执行摊销变分推断（amortised variational inference），如变分自编码器（Variational Autoencoders；Kingma & Welling, 2014）中那样。

= 结论

在本工作中，我们为 SR 中的近似 MAP 推断开发了若干方法。我们首先引入了一种对神经网络的架构性约束，将模型输出投影到“有效解的仿射子空间”。随后我们利用该仿射投影，提出了三种用于 SR 摊销 MAP 推断的方法，分别基于 GAN、去噪与密度模型。在高维情形下，我们实证地发现基于 GAN 的方法 AffGAN 产生了视觉上最具吸引力的结果。我们的工作延续了 GAN 式算法用于图像 SR 的成功示范（Ledig 等, 2016），并为这一思路为何合理提供了额外的理论动机。在未来工作中，我们计划聚焦于 AffGAN 的随机扩展，它可被视为在执行摊销变分推断。

// ===================== 参考文献 =====================
#pagebreak()
= 参考文献

#block(inset: (left: 0pt))[
  #set par(first-line-indent: 0em, hanging-indent: 1.6em, leading: 0.6em)
  #set text(size: 9pt)
  #set block(spacing: 0.7em)

  Guillaume Alain and Yoshua Bengio. What regularized auto-encoders learn from the data-generating distribution. _Journal of Machine Learning Research_, 15(1):3563–3593, 2014.

  Martin Arjovsky and Léon Bottou. Towards principled methods for training generative adversarial networks. In _International Conference on Learning Representations_, 2017.

  Joan Bruna, Pablo Sprechmann, and Yann LeCun. Super-resolution with deep convolutional sufficient statistics. _International Conference on Learning Representations_, 2016.

  Emily L Denton, Soumith Chintala, Rob Fergus, et al. Deep generative image models using a Laplacian Pyramid of adversarial networks. In _Advances in Neural Information Processing Systems_, pp. 1486–1494, 2015.

  Sander Dieleman, Jan Schlüter, Colin Raffel, Eben Olson, Søren Kaae Sønderby, Daniel Nouri, and Eric Battenberg and. Lasagne: First release., 2015.

  Chao Dong, Chen Change Loy, Kaiming He, and Xiaoou Tang. Image super-resolution using deep convolutional networks. _IEEE Transactions on Pattern Analysis & Machine Intelligence_, pp. 295–307, 2016.

  Alexey Dosovitskiy and Thomas Brox. Generating images with perceptual similarity metrics based on deep networks. _arXiv preprint arXiv:1602.02644_, 2016.

  David Garcia. Open source code. retrieved on 22 Sept 2016, 2016.

  Ian Goodfellow, Jean Pouget-Abadie, Mehdi Mirza, Bing Xu, David Warde-Farley, Sherjil Ozair, Aaron Courville, and Yoshua Bengio. Generative adversarial nets. In _Advances in Neural Information Processing Systems_, pp. 2672–2680, 2014.

  Klaus Greff, Antti Rasmus, Mathias Berglund, Tele Hotloo Hao, Jürgen Schmidhuber, and Harri Valpola. Tagger: Deep unsupervised perceptual grouping. In _Advances in Neural Information Processing Systems_, 2016.

  Gao Huang, Zhuang Liu, and Kilian Q Weinberger. Densely connected convolutional networks. _arXiv preprint arXiv:1608.06993_, 2016.

  Ferenc Huszár. An alternative update rule for generative adversarial networks. Unpublished note (retrieved on 7 Oct 2016), 2016.

  Diederik P. Kingma and Max Welling. Auto-encoding variational bayes. In _The International Conference on Learning Representations_, 2014.

  Valero Laparra, Jordi Muñoz Marí, and Jesús Malo. Divisive normalization image quality metric revisited. _J. Opt. Soc. Am. A_, pp. 852–864, 2010.

  Valero Laparra, Johannes Ballé, Alexander Berardino, and Eero P Simoncelli. Perceptual image quality assessment using a normalized laplacian pyramid. In _Proc. IS&T Int'l Symposium on Electronic Imaging_, 2016.

  Anders Boesen Lindbo Larsen, Søren Kaae Sønderby, and Ole Winther. Autoencoding beyond pixels using a learned similarity metric. In _Proceedings of The 33rd International Conference on Machine Learning_, pp. 1558–1566, 2015.

  Christian Ledig, Lucas Theis, Ferenc Huszár, Jose Caballero, Andrew Aitken, Alykhan Tejani, Johannes Totz, Zehan Wang, and Wenzhe Shi. Photo-realistic single image super-resolution using a generative adversarial network. _arXiv preprint arXiv:1609.04802_, 2016.

  Chuan Li and Michael Wand. Combining markov random fields and convolutional neural networks for image synthesis. In _The IEEE Conference on Computer Vision and Pattern Recognition (CVPR)_, 2016.

  Shakir Mohamed and Balaji Lakshminarayanan. Learning in implicit generative models. _arXiv preprint arXiv:1610.03483_, 2016.

  Kamal Nasrollahi and Thomas B. Moeslund. Super-resolution: a comprehensive survey. _Machine Vision and Applications_, pp. 1423–1468, 2014.

  Sebastian Nowozin, Botond Cseke, and Ryota Tomioka. f-GAN: Training generative neural samplers using variational divergence minimization. _arXiv preprint arXiv:1606.00709_, 2016.

  Aaron van den Oord, Nal Kalchbrenner, and Koray Kavukcuoglu. Pixel recurrent neural networks. In _Proceedings of The 33rd International Conference on Machine Learning_, pp. 1747–1756, 2016.

  Alec Radford, Luke Metz, and Soumith Chintala. Unsupervised representation learning with deep convolutional generative adversarial networks. In _International Conference on Learning Representations_, 2015.

  Antti Rasmus, Mathias Berglund, Mikko Honkala, Harri Valpola, and Tapani Raiko. Semi-supervised learning with ladder networks. In _Advances in Neural Information Processing Systems_, pp. 3546–3554, 2015.

  Tim Salimans, Ian Goodfellow, Wojciech Zaremba, Vicki Cheung, Alec Radford, and Xi Chen. Improved techniques for training gans. In _Advances in Neural Information Processing Systems_, 2016.

  Jaakko Särelä and Harri Valpola. Denoising source separation. _Journal of Machine Learning Research_, pp. 233–272, 2005.

  Wenzhe Shi, Jose Caballero, Ferenc Huszar, Johannes Totz, Andrew P Aitken, Rob Bishop, Daniel Rueckert, and Zehan Wang. Real-time single image and video super-resolution using an efficient sub-pixel convolutional neural network. In _Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition_, pp. 1874–1883, 2016.

  The Theano Development Team, Rami Al-Rfou, Guillaume Alain, et al. Theano: A python framework for fast computation of mathematical expressions. _arXiv preprint arXiv:1605.02688_, 2016.

  Lucas Theis and Matthias Bethge. Generative image modeling using spatial lstms. In _Advances in Neural Information Processing Systems_, pp. 1927–1935, 2015.

  Lucas Theis, Reshad Hosseini, and Matthias Bethge. Mixtures of conditional gaussian scale mixtures applied to multiscale image representations. _PLoS ONE_, 2012.

  Pascal Vincent. A connection between score matching and denoising autoencoders. _Neural computation_, pp. 1661–1674, 2011.

  Pascal Vincent, Hugo Larochelle, Yoshua Bengio, and Pierre-Antoine Manzagol. Extracting and composing robust features with denoising autoencoders. In _Proceedings of the 25th International Conference on Machine Learning_, pp. 1096–1103, 2008.

  Zhou Wang, Eero P Simoncelli, and Alan C Bovik. Multiscale structural similarity for image quality assessment. In _Conference Record of the 27th Asilomar Conference on Signals, Systems and Computers_, volume 2, pp. 1398–1402, 2003.

  Zhou Wang, Alan C Bovik, Hamid R Sheikh, and Eero P Simoncelli. Image quality assessment: from error visibility to structural similarity. _IEEE transactions on image processing_, pp. 600–612, 2004.
]

// ===================== 附录 =====================
#pagebreak()
#counter(heading).update(0)
#set heading(numbering: (..n) => {
  let nums = n.pos()
  if nums.len() == 1 { "附录 " + numbering("A", nums.at(0)) }
  else { numbering("A.1", ..nums) }
})

= 用于最小化 KL 散度的生成对抗网络 <app:a>

首先注意，对于固定的生成器 $G$，判别器 $D$ 最大化：

$ & EE_(y tilde p_Y) log D_psi (y) + EE_(z tilde cal(N)) log(1 - D_psi (G_theta (z))) = $ <eq:a1>
$ & EE_(y tilde p_Y) log D_psi (y) + EE_(y tilde q_G) [log(1 - D_psi (y))] = $ <eq:a2>
$ & integral_y p_Y (y) log D_psi (y) + q_G (y) log(1 - D_psi (y)) dif y $ <eq:a3>

其中 $q_G$ 是生成分布。形如 $a log(x) + b log(1 - x)$ 的函数总在 $a / (a + b)$ 处取得最大值，于是我们得到贝叶斯最优判别器（假设各类先验概率相等）：

$ D^*(y) = p_Y (y) / (p_Y (y) + q_G (y)) $ <eq:a4>

假设该贝叶斯最优判别器是唯一的，且能被我们的神经网络紧密逼近（关于此假设的更多讨论见 @app:c）。使用此处提出的修正更新规则，判别器与生成器的联合优化问题为

$ V(psi, theta) = max_(psi, theta) EE_(y tilde p_Y) log D_psi (y) + EE_(z tilde cal(N)) [log(D_psi (G_theta (z))) - log(1 - D_psi (G_theta (z)))] $ <eq:a5>

从 $"KL"[q_G | p_Y]$ 的定义出发：

$ "KL"[q_G | p_Y] &= EE_(y tilde q_G) log (q_G (y)) / (p_Y (y)) $ <eq:a6>
$ &= EE_(y tilde q_G) log (1 - D^*(y)) / (D^*(y)) quad ("代入贝叶斯最优分类器") $ <eq:a7>
$ &approx EE_(y tilde q_G) log (1 - D_psi (y)) / (D_psi (y)) = -EE_(y tilde q_G) log (D_psi (y)) / (1 - D_psi (y)) $ <eq:a8>

这恰好等于 @eq:a5 中影响生成器的那些项。

= 仿射投影 <app:b>

== 伪逆的数值估计

在实践中，我们将下采样投影 $A$ 实现为一个带固定高斯平滑核的带步幅卷积，其步幅对应于下采样因子。$A^+$ 实现为一个转置卷积操作，其参数通过随机梯度下降在以下目标函数上数值优化：

$ ell_1 (B) &= EE_(y tilde cal(N)_(r d)) ||A y - A B A y||_2^2 $ <eq:b1>
$ ell_2 (B) &= EE_(x tilde cal(N)_r) ||B x - B A B x||_2^2 $ <eq:b2>
$ A^+ &= op("argmin")_B {ell_1 (B) + ell_2 (B)} $ <eq:b3>

其中 $cal(N)_d$ 是 $d$ 维标准正态分布，$d$ 是 LR 数据 $x$ 的维数。$ell_1$ 与 $ell_2$ 可分别视为对变换 $A - A B A$ 与 $B - B A B$ 谱范数（spectral norm）的蒙特卡洛估计。上述蒙特卡洛形式的优点是可以通过随机梯度下降优化。操作 $A B A$ 可看作一个三层全线性卷积神经网络，其中 $A$ 对应一个带固定核的带步幅卷积，而 $B$ 是一个可训练的反卷积。我们注意到，对于某些下采样核 $A$，精确的 $A^+$ 会有一个无限大的核，尽管它总能用一个局部核来逼近。在收敛时，我们发现 $ell_1 + ell_2$ 介于 $10^(-12)$ 与 $10^(-8)$ 之间，具体取决于下采样因子、用于 $A$ 的高斯核宽度以及 $A$ 与 $B$ 的滤波器尺寸。

== 梯度

仿射投影 SR 模型的梯度通过应用链式法则导出：

$ f_theta (x) &= (I - A^+ A) g_theta (x) + A^+ x $ <eq:b4>
$ (partial f_theta (x)) / (partial theta) &= (partial f_theta (x)) / (partial g_theta (x)) (partial g_theta (x)) / (partial theta) = (I - A^+ A) (partial g_theta (x)) / (partial theta) $ <eq:b5>

这本质上是 $g_theta (x)$ 梯度的高通滤波（high-pass filtered）版本。

= 实例噪声 <app:c>

GAN 以训练不稳定而著称，已有若干论文试图通过各种技巧改善其收敛性质（Salimans 等, 2016; Radford 等, 2015）。考虑如下理想化的 GAN 算法，每次迭代包含以下步骤：

+ 我们通过在 $q_theta$ 与 $p_Y$ 之间做逻辑回归来训练判别器 $D$，直至收敛；
+ 我们从 $D$ 中提取对数似然比的估计 $s(y) = log (q_theta (y)) / (p(y))$；
+ 我们以目标函数 $EE_(y tilde q_theta) s(y)$ 取一个随机梯度步来更新 $theta$。

如果 $q_theta$ 与 $p_Y$ 是低维空间中良态（well-conditioned）的分布，该算法就在对 KL 散度的某个近似上执行梯度下降，因此它应当收敛。那么为什么在实际情形中它会高度不稳定呢？

关键在于，该算法的收敛依赖于若干并不总成立的假设：(1) 对数似然比 $log (q_theta (y)) / (p(y))$ 是有限的；(2) 詹森–香农散度 $"JS"[q_theta || p]$ 是 $theta$ 的良态函数；(3) 逻辑回归问题的贝叶斯最优解是唯一的。我们断言，在现实情形中这些假设无一成立，主要原因在于 $q_theta$ 与 $p_Y$ 是支撑集可能不重叠的集中分布。在图像建模中，自然图像分布 $p_Y$ 通常被假设集中在一个较低维流形之上或附近；类似地，$q_theta$ 往往因构造而退化。两个分布在高维空间中共享支撑集的概率非常小，尤其是在训练早期。如果 $q_theta$ 与 $p_Y$ 的支撑集不重叠：(1) 对数似然比、进而 KL 散度是无穷大的；(2) 詹森–香农散度饱和于其最大值，且在 $theta$ 上局部为常数；(3) 可能存在一大批近似最优的判别器，它们的逻辑回归损失都非常接近贝叶斯最优，但每一个都可能给生成器提供截然不同的梯度。因此，即便对固定的 $q_theta$ 与 $p_Y$，训练判别器 $D$ 也可能因初始化不同而每次找到不同的近似最优解。

避免这些病态的主要方式是*让判别器的任务变难*。例如，在大多数 GAN 实现中，判别器每次迭代只被部分更新，而非训练至收敛。另一种削弱判别器的方式是添加标签噪声，或等价地，使用 Salimans 等（2016）引入的单边标签平滑。在该技术中，判别器训练数据中的标签被随机翻转。然而我们认为这些技术并不能充分解决上述所有问题。

#figure(
  image("images/fig6.png", width: 70%),
  caption: [
    (a) 两个完全可分、不重叠分布的样本示意；(b) 加入单边标签平滑；(c) 加入实例噪声。单边标签平滑移动了最优决策边界，但 $p_Y$ 仍覆盖了 $q_theta$ 中无支撑的区域。实例噪声拓宽了两个分布的支撑集，且不会使最优判别器产生偏差。
  ],
) <fig:fig6>

在 @fig:fig6 (a) 中，我们展示了两个几乎完全可分的分布。注意分布之间的大间隙意味着存在大量可能的分类器能够区分这两个分布并取得相近的逻辑损失。贝叶斯最优分类器可能不唯一，且近似最优分类器的集合非常庞大且多样。在 @fig:fig6 (b) 中，我们展示单边标签平滑（或等价的标签噪声）的效果。在该技术中，一些真实数据样本 $y tilde p_Y$ 的标签被翻转，使判别器以为它们来自 $q_theta$。判别器的任务现在确实更难了，但所有分类器受到的惩罚几乎相同。结果，仍然存在一大批取得近似最优损失的判别器，只不过近似最优损失现在更大了。如果贝叶斯最优分类器不唯一，标签平滑并无帮助。

我们转而提议向*样本*而非标签添加噪声，我们称之为实例噪声。使用实例噪声，两个分布的支撑集被拓宽，它们不再完全可分，如 @fig:fig6 (c) 所示。添加噪声后，贝叶斯最优判别器变得唯一，判别器因训练分布更宽而更不易过拟合，且对数似然比变得更良态。含噪分布之间的詹森–香农散度现在是 $theta$ 的一个非常数函数。使用实例噪声，很容易构造一个最小化以下散度的算法：

$ d_sigma (q_theta, p_Y) = "KL"[p_sigma * q_theta || p_sigma * p_Y] $ <eq:c1>

其中 $sigma$ 是噪声分布的参数。对含噪样本做逻辑回归可得到 $s_sigma (x) = log (p_sigma * q_theta) / (p_sigma * p_Y)$ 的估计。更新生成器时，我们必须在来自 $q_theta$ 的含噪样本上最小化 $s(sigma)$ 的均值。我们知道，如果 $p_sigma$ 是高斯的，则 $d_sigma$ 是一个 Bregman 散度，且当且仅当两个分布相等时它为 0。由于添加了噪声，$d_sigma$ 对分布的局部特征不那么敏感。

我们在实验中发现，实例噪声有助于 AffGAN 的收敛。我们尚未在生成式建模应用中测试实例噪声。由于不必担心过度训练判别器，我们可以将其训练至收敛，或在对生成器的相邻两次更新之间多取若干梯度步。该方法的一个关键超参数是噪声分布。我们使用加性高斯噪声，并在训练中对其方差退火。我们提出一种启发式退火策略：调整噪声，使最优判别器的损失在训练中保持恒定。其他噪声分布（如重尾分布或 spike-and-slab）也许效果更好，但我们尚未研究这些选项。

= 实验细节 <app:d>

*损失函数。* 对 GAN 模型，生成参数与判别参数使用 @eq:gan 更新。对以软约束方式施加 @eq:obs 的模型，我们向生成参数添加一个额外的 MAE 损失项 $ell_("MAE") = 1/N sum_i ||x_i - A hat(y)_i||$，其中 $i$ 遍历数据样本数 $N$。

去噪器引导的模型以两步流程训练。首先，我们预训练一个 DAE，通过最小化以下目标来对数据分布的样本去噪：

$ ell_("DAE") &= 1/N sum ||y - f_("DAE")^sigma (tilde(y))||^2 $ <eq:d1>
$ tilde(y) &= y + epsilon, quad epsilon tilde cal(N)(0, sigma I) $ <eq:d2>

训练中我们对噪声水平 $sigma$ 退火，并持续保存在逐渐减小的噪声水平上训练的 DAE 模型参数 $f_("DAE")^sigma$。随后我们按 @eq:dggrad 中的梯度学习生成器参数，使用 DAE 来估计 $partial / (partial y) log p(y)$：

$ partial / (partial theta) EE_x [log p(hat(y))] &= EE_x [partial / (partial y) log p(y) dot partial / (partial theta) hat(y)] $ <eq:d3>
$ &= EE_x [(f_("DAE")^sigma (tilde(y)) - y) / sigma^2 dot partial / (partial theta) hat(y)] $ <eq:d4>
$ theta_(i+1) &<- theta_i + alpha partial / (partial theta) EE_x [log p(hat(y))] $ <eq:d5>

其中 $alpha$ 是学习率。训练中我们持续载入在逐渐降低的噪声水平上训练的 DAE 参数，以便在训练初期获得指向近似正确方向、同时覆盖大片数据空间的梯度，而在训练后期获得贴近数据流形的精确梯度。

对密度引导的模型，我们首先通过最大化可处理的对数似然来预训练一个密度模型：

$ L(y) = sum_j log p(y_j | y_(<j)) $ <eq:d6>

其中联合密度用链式法则分解，$j$ 遍历像素。与 DAE 类似，我们在训练中持续保存密度模型的参数。随后我们通过直接最小化“生成样本在所学密度模型下的负对数似然”来学习生成器参数：

$ ell = -L(hat(y)) = -L(f_theta (x)) $ <eq:d7>

*二维瑞士卷。* 二维目标数据 $y = [y_1, y_2]$ 从如下定义的二维瑞士卷中采样：

$ nu_1 &tilde cal(N)(mu_1, sigma_1), quad nu_2 tilde cal(N)(mu_2, sigma_2) $ <eq:d8>
$ r &= 0.4 nu_1 + nu_2 $ <eq:d9>
$ y &= [cos(nu_1) * r, sin(nu_1) * r] $ <eq:d10>

其中 $mu_1 = 10, sigma_1 = 3, mu_2 = 0, sigma_2 = 0.2$。LR 输入定义为 $x = (y_1 + y_2)\/2$。交叉熵 $H[q_theta, p_Y]$ 通过对一个高斯核密度估计器（拟合于无噪瑞士卷密度即 $sigma_2 = 0$ 的 50,000 个样本）估计概率密度函数来计算，并将每个核的带宽设为 $sigma_2 = 0.2$。所有生成器与判别器均为 2 层全连接 NN，每层 64 个单元。对 AffDG 模型，DAE 是一个每层 256 个单元的两层 NN，训练时将高斯噪声标准差从 0.5 退火至 0.25。

*图像数据。* 对所有图像实验，我们将 $A$ 设为使用 $9 times 9$ 高斯平滑核、步幅为 4（对应 $4 times$ 下采样）的卷积。$A^+$ 设为一个带 $4^2$ 个 $5 times 5$ 核的卷积操作，随后按（Shi 等, 2016）所述对像素重排序，输出对应 $4 times$ 上采样卷积。$A^+$ 的参数按 @app:b 所述数值优化。所有下采样均使用 $A$ 投影完成。对所有图像模型，我们使用卷积模型，除输出层外所有层均采用 ReLU 非线性与批归一化（batch normalization）。所有生成器都使用类似（Huang 等, 2016）的跳跃连接（skip connection），并对模型输出施加最终的 sigmoid 非线性，其结果要么直接使用，要么通过由 $A$ 与 $A^+$ 参数化的仿射变换层。判别器是标准卷积网络，后接一个最终的 sigmoid 层。

对草地纹理实验，我们使用从高分辨率草地纹理图像中随机提取的数据图块。生成器使用 6 层卷积，滤波器图数为 32、32、64、64、128，并每隔两层加跳跃连接。判别器有 4 层带步幅卷积，滤波器图数为 32、64、128、256。对 AffDG 模型，DAE 是一个每层 128 个滤波器图的四层卷积网络，训练时将高斯噪声标准差从 0.5 退火至 0.01。密度模型实现为类似 Oord 等（2016）的 PixelCNN，含 4 层卷积、每层 64 个滤波器图、核尺寸为 5（首层用 7）。原始 PixelCNN 使用不可微的类别分布作为似然模型，故无法用于基于梯度的优化；我们转而使用 MCGSM 作为似然模型（Theis & Bethge, 2015），它已被证明是良好的图像密度模型（Theis 等, 2012），使用 32 个混合分量与 32 个二次特征来逼近协方差矩阵。

对 CelebA 实验，数据集按标准划分为训练、验证与测试集。所有图像先中心裁剪并缩放至 $64 times 64$，再用 $A$ 下采样至 $16 times 16$。所有生成器为 12 层卷积网络，含 4 层的 128、256、512 滤波器图，每隔四层加跳跃连接。判别器为 8 层卷积网络，含两层的 128、256、512、1024 滤波器图，每隔两层使用步幅 2。

对 ImageNet 实验，2012 数据集被随机划分为训练、验证与测试集，测试集与验证集各含 $10^4$ 个样本。随后丢弃所有小于 20kB 的图像以剔除分辨率过低者。图像先中心裁剪并缩放至 $128 times 128$，再用 $A$ 下采样至 $32 times 32$。生成器为 8 层卷积网络，含 4 层的 128、256 滤波器图，每隔两层加跳跃连接。判别器为 8 层卷积网络，含两层的 128、256、512、1024 滤波器图，每隔两层使用步幅 2。为稳定训练，我们使用从初始标准差 0.1 线性退火至 0 的高斯实例噪声。若无此额外正则化，我们无法稳定地训练模型。

= 去噪器与密度引导超分辨率的补充结果 <app:e>

@fig:fig7 展示了在草地纹理上训练的 AffDG 与 AffLL 模型在训练过程中的 PSNR 与 SSIM 分数。注意模型确实在收敛，但如 @fig:fig3 所示，图像非常模糊。对两个模型，我们都遇到了训练发散的问题。对高噪声水平的 DAE 模型，梯度只是近似正确，但覆盖数据流形周围的大片空间；而对低噪声水平，梯度在数据流形周围的小范围内更准确。对密度模型，我们相信类似现象导致训练发散，因为对精确的密度模型，所估计的密度很可能在数据流形周围非常陡峭，使训练初期的学习十分困难。为解决这些问题，我们以高噪声水平或低对数似然值的模型开始训练，然后在训练中持续载入噪声水平逐渐更小、或对数似然值更好的模型参数。这一效果在训练中清晰可见，即 @fig:fig7 中 AffDG 的阶梯状行为。我们注意到，用于训练 AffLL 的密度模型取得了 $-4.10$ 比特每维（bits per dimension）的对数似然，这与 Theis & Bethge（2015）在某纹理数据集上得到的值相当。此外，AffLL 模型在该密度模型下取得了 $> -3.5$ 的高对数似然值，这表明该密度模型只是未能对 $p_Y$ 提供足够精确的表示，从而无法为训练 AffLL 模型提供精确的分数。

#figure(
  image("images/fig7.png", width: 92%),
  caption: [
    AffDG 与 AffLL 模型的 PSNR 与 SSIM 结果。注意 AffDG 模型的阶梯状行为源于持续切换至噪声水平更低的 DAE 模型。
  ],
) <fig:fig7>

= 使用 AffGAN 进行 SR 的摊销变分推断 <app:f>

这里我们将证明，AffGAN 模型的一个随机扩展近似地最小化一个摊销变分推断判据。我们引入 AffGAN 的一个变体，其中生成器函数除 LR 数据 $x$ 外，还接受一些独立的噪声变量 $z$ 作为输入：

$ z &tilde p_Z $ <eq:f1>
$ hat(y) &= Pi_x^A f_theta (x, z) $ <eq:f2>

类似于我们在 @sec:likelihood 中定义 $q_theta$ 的方式，我们引入如下记号：

$ q_(Y; theta) &:= EE_(x tilde p_X) EE_(z tilde p_Z) delta(y - Pi_x^A f_theta (x, z)) $ <eq:f3>
$ q_(Y|X; theta) &:= EE_(z tilde p_Z) delta(y - Pi_x^A f_theta (x, z)) $ <eq:f4>
$ q_(X,Y; theta) &:= p_X dot q_(Y|X; theta) $ <eq:f5>

这里仿射投影确保在 $q_(X,Y; theta)$ 下 $x$ 与 $y$ 始终一致。因此，在 $q_(X,Y; theta)$ 下，给定 $y$ 时 $x$ 的条件分布按构造与似然 $p_(X|Y) = delta(x - A y)$ 相同，下式成立：

$ q_(X,Y; theta) = q_(Y; theta) dot p_(X|Y) = p_X dot q_(Y|X; theta) $ <eq:f6>

对 $p_(X|Y) = (p_(Y|X) p_X) / p_Y$ 应用贝叶斯法则并代入上式，我们得到：

$ q_(Y; theta) dot p_(Y|X=A y) = p_(Y; theta) dot q_(Y|X=A y; theta) $ <eq:f7>

AffGAN 目标所最小化的 KL 散度现在可重写为：

$ "KL"[q_(Y; theta) || p_Y] &= EE_(q_(Y; theta)) log (q_(Y; theta)(y)) / (p_Y (y)) $ <eq:f8>
$ &= EE_(q_(X,Y; theta)) log (q_(Y; theta)(y)) / (p_Y (y)) $ <eq:f9>
$ &= EE_(q_(X,Y; theta)) log (q_(Y|X; theta)(y|x)) / (p_(Y|X)(y|x)) $ <eq:f10>
$ &= EE_(p_X) "KL"[q_(Y|X; theta) || p_(Y|X)] $ <eq:f11>

因此我们可以得出结论：@sec:affgan 所述的 AffGAN 算法近似地最小化以下摊销变分推断判据：

$ op("argmin")_theta "KL"[q_(Y; theta) || p_Y] = op("argmin")_theta EE_(x tilde p_X) "KL"[q_(Y|X; theta) || p_(Y|X)] $ <eq:f12>

并且在此过程中，它只需要来自 $p_Y$ 与 $p_X$ 的样本。

#figure(
  image("images/fig8.png", width: 92%),
  caption: [
    在 ImageNet 上使用 AffGAN 将图像从 $32 times 32$ 做 $4 times$ SR 至 $128 times 128$。AffGAN 输出（上排）、真实 HR 图像 $y$（中排）、模型输入 $x$（下排）。
  ],
) <fig:fig8>
