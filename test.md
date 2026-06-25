# Demo / Hardcode Inventory

本文件用于记录当前项目内需要在后续统一替换掉的 demo / hardcode / mock 数据入口。

## 扫描结论

- 当前项目中，和业务数据直接相关的 mock / hardcode 主要集中在 `pages/index/index.ink`。
- 本次已扫描 `pages/`、`app.js`、`app.json`、`AGENTS.md`、根目录文档，未发现其他明显的业务 mock 数据源。
- 下列条目建议在后续接入大模型或真实数据接口时统一替换。

## 需要替换的条目

### 1. Demo 图片生成函数

- 文件：`pages/index/index.ink`
- 位置：`L10-L12`
- 内容：`buildDemoImageUrl(prompt, imageSize)`
- 说明：当前通过文生图接口拼接 demo 插图 URL，属于临时展示资源，不是正式业务图片源。
- 后续建议：改为由真实卡片数据或模型返回的图片字段驱动，例如 `illustrationUrl` / `coverUrl`。

### 2. 静态学习洞察文案

- 文件：`pages/index/index.ink`
- 位置：`L14-L18`
- 内容：`STATIC_STUDY_INSIGHTS`
- 说明：按科目名称硬编码了 3 份静态洞察文案，当前仅用于学习页占位展示。
- 后续建议：改为由大模型或后端接口动态返回的科目分析文案。

### 3. 闯关结果分数

- 文件：`pages/index/index.ink`
- 位置：`L25`
- 内容：`challengeScore: 3`
- 说明：当前结果页分数为固定值，未和真实答题过程联动。
- 后续建议：改为绑定真实答题记录、正确题数和总题数。

### 4. 科目数据源

- 文件：`pages/index/index.ink`
- 位置：`L37-L72`
- 内容：`subjects` 数组
- 说明：当前整个首页与学习页的数据源均为本地硬编码数组，包含以下字段：
- 字段：`id`
- 字段：`title`
- 字段：`pendingCount`
- 字段：`scene`
- 字段：`content`
- 字段：`memoryKey`
- 字段：`memoryHint`
- 字段：`tagTwo`
- 字段：`tagThree`
- 字段：`illustrationUrl`
- 后续建议：改为统一从真实卡片数据、科目接口或大模型生成结果中映射。

### 5. 专利代理人 mock 数据

- 文件：`pages/index/index.ink`
- 位置：`L38-L48`
- 内容：专利代理人整组静态对象
- 说明：包括固定标题、待学习数量、场景文案、关键词、标签和 demo 插图。

### 6. 法律从业资格 mock 数据

- 文件：`pages/index/index.ink`
- 位置：`L49-L60`
- 内容：法律从业资格整组静态对象
- 说明：包括固定标题、待学习数量、场景文案、关键词、标签和 demo 插图。

### 7. 中医执照 mock 数据

- 文件：`pages/index/index.ink`
- 位置：`L61-L72`
- 内容：中医执照整组静态对象
- 说明：包括固定标题、待学习数量、场景文案、关键词、标签和 demo 插图。

### 8. 结果页占位文案

- 文件：`pages/index/index.ink`
- 位置：`L338`
- 内容：`本轮闯关已完成，当前先使用静态数据展示结果页样式。`
- 说明：当前结果页说明文字是纯占位文案，不是实际分析结果。
- 后续建议：替换为真实成绩总结、错题分析或大模型生成的结果解读。

## 暂不计入 mock 数据的内容

- `studyVoiceHint`：这是语音条的状态提示文案，属于 UI 状态文本，不是业务 mock 数据。
- `currentSubject` 的空对象默认值：这是页面初始化兜底结构，不是最终业务内容。
- 主菜单按钮文案、返回交互、空态标题等：属于固定 UI 文案，不属于 demo 数据源。

## 后续替换顺序建议

1. 先替换 `subjects` 数据源。
2. 再替换 `STATIC_STUDY_INSIGHTS`。
3. 接着替换 `challengeScore` 和结果页占位文案。
4. 最后移除 `buildDemoImageUrl()`，把图片源切到真实字段。
