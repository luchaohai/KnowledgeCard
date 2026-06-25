const fs = require('fs');
const path = require('path');

const projectRoot = path.resolve(__dirname, '..');
const jsonPath = path.join(projectRoot, 'assets', 'data', 'data.json');
const jsPath = path.join(projectRoot, 'assets', 'data', 'data.js');

const subjectConfigs = {
  '专利代理人': {
    summary: '围绕专利法、审查标准、代理实务与撰写训练进行系统备考。',
    overview: '专利代理人科目需要同时兼顾法条理解、审查逻辑和撰写表达，学习时应以规则判断和文书结构双线推进。',
    memoryKey: '法条',
    memoryHint: '重点关注授权条件、程序节点和文书表达，先记原则，再补例外情形。',
    tagTwo: '审查',
    tagThree: '撰写',
    insight: '专利代理人科目适合按规则判断、文书写法和程序时序拆卡学习。',
    modules: [
      ['新颖性判断', '新颖性', '对比', '检索', '先找最接近现有技术，再看差异点是否被公开。'],
      ['创造性三步法', '创造性', '动机', '区别', '先识别区别特征，再判断技术启示是否足够。'],
      ['实用性判断', '实用性', '效果', '实施', '围绕是否可制造、可使用、可重复实现来判断。'],
      ['说明书撰写', '说明书', '结构', '实施例', '先搭建技术背景、发明内容，再补实施方式。'],
      ['权利要求布局', '权利要求', '独权', '从权', '先守住核心保护范围，再细化从属限定。'],
      ['优先权规则', '优先权', '期限', '文件', '特别关注期限起算点和证明文件要求。'],
      ['无效宣告应对', '无效', '证据', '对比', '先稳住权利要求，再准备对比文件和修改口径。'],
      ['侵权判断路径', '侵权', '比对', '等同', '围绕全面覆盖和等同特征逐层比对。']
    ]
  },
  '法律从业资格': {
    summary: '围绕民法、刑法、诉讼法、行政法与商经法等核心模块分阶段复习。',
    overview: '法律从业资格更强调体系串联和法条适用，需要把概念、构成要件和程序节点拆分成可复述的小卡片。',
    memoryKey: '体系',
    memoryHint: '优先拉通部门法框架，再细化构成要件、责任承担和程序顺序。',
    tagTwo: '民法',
    tagThree: '刑法',
    insight: '法考类科目最怕只记结论不记适用条件，卡片要突出前提、规则和例外。',
    modules: [
      ['民事法律行为', '行为', '效力', '要件', '先判断成立条件，再看效力瑕疵和救济路径。'],
      ['物权变动规则', '物权', '公示', '交付', '重点分清登记主义与交付主义的适用差异。'],
      ['合同责任承担', '合同', '违约', '救济', '先判断违约类型，再匹配继续履行和赔偿规则。'],
      ['侵权责任结构', '侵权', '过错', '因果', '先锁定责任基础，再分析因果关系和免责事由。'],
      ['犯罪构成判断', '犯罪', '构成', '主观', '按客体、客观、主体、主观四层逐项筛查。'],
      ['共同犯罪区分', '共犯', '分工', '责任', '先定角色，再看行为贡献和责任范围。'],
      ['民事诉讼程序', '民诉', '管辖', '举证', '围绕起诉、答辩、举证、裁判的顺序记忆。'],
      ['刑事诉讼流程', '刑诉', '强制', '审判', '重点记侦查、起诉、审判中的权利保障节点。'],
      ['行政法合法性', '行政法', '权限', '程序', '先判断职权来源，再检查程序是否合法。'],
      ['商经法高频点', '商经', '公司', '票据', '对公司治理和票据规则要形成模块化记忆。']
    ]
  },
  '中医执照': {
    summary: '围绕中基、中诊、中药、方剂与临床辨证进行分层学习。',
    overview: '中医执照学习更依赖知识网络，卡片需要把证候、病机、治法和方药之间的对应关系拆开记忆。',
    memoryKey: '辨证',
    memoryHint: '先建立病机与证候关系，再串联治法、方剂和核心药物。',
    tagTwo: '方剂',
    tagThree: '临床',
    insight: '中医类卡片最关键的是把病机和治法配对，不要只背方名。',
    modules: [
      ['阴阳五行基础', '阴阳', '属性', '转化', '先理解对立统一，再记相互消长与转化。'],
      ['脏腑生理关系', '脏腑', '功能', '联系', '按心肝脾肺肾和腑的配合关系来记忆。'],
      ['气血津液辨析', '气血', '生成', '运行', '先区分生成来源，再看运行与失调表现。'],
      ['病因病机判断', '病机', '外感', '内伤', '从外感六淫和内伤七情两条线来拆解。'],
      ['四诊信息提取', '四诊', '望闻', '问切', '先抓主症，再把舌脉信息映射到证候。'],
      ['八纲辨证应用', '八纲', '表里', '寒热', '围绕阴阳总纲细分表里寒热虚实。'],
      ['方剂配伍思路', '方剂', '君臣', '加减', '先认主方，再理解配伍层级和加减理由。'],
      ['常见证型训练', '证型', '治法', '用药', '先锁病机，再匹配治法和代表方药。']
    ]
  }
};

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function buildCard(subject, subjectConfig, card, index) {
  const moduleConfig = subjectConfig.modules[index % subjectConfig.modules.length];
  const [moduleTitle, memoryKey, tagTwo, tagThree, clue] = moduleConfig;
  const sequence = index + 1;
  const safeCard = card && typeof card === 'object' ? card : {};

  return {
    id: safeCard.id || `${subject.id}-card-${sequence}`,
    order: sequence,
    title: `${moduleTitle} 第${sequence}卡`,
    scene: `${subject.title}当前进入${moduleTitle}训练卡，围绕${memoryKey}相关考点进行第${sequence}轮复习。`,
    content: `本卡聚焦${moduleTitle}。请先概括核心规则，再结合${tagTwo}与${tagThree}两个角度完成一轮自测。线索：${clue}`,
    memoryKey,
    memoryHint: `记忆提示：${clue}本卡重点把${memoryKey}和${tagTwo}/${tagThree}建立稳定联想。`,
    tagTwo,
    tagThree,
    illustrationUrl: safeCard.illustrationUrl || subject.illustrationUrl || '',
    aiInsight: `${subject.title}第${sequence}卡建议先口述${moduleTitle}的判断路径，再用一句话总结${memoryKey}的高频误区。`
  };
}

function enrichSubject(subject) {
  const config = subjectConfigs[subject.title];
  const pendingCount = Number.isInteger(subject.pendingCount) && subject.pendingCount > 0
    ? subject.pendingCount
    : Array.isArray(subject.cards)
      ? subject.cards.length
      : 0;
  const baseCards = Array.isArray(subject.cards) ? subject.cards : [];

  if (!config) {
    return {
      ...subject,
      pendingCount
    };
  }

  return {
    ...subject,
    scene: config.summary,
    content: config.overview,
    memoryKey: config.memoryKey,
    memoryHint: config.memoryHint,
    tagTwo: config.tagTwo,
    tagThree: config.tagThree,
    cards: Array.from({ length: pendingCount }, function(_, index) {
      return buildCard(subject, config, baseCards[index], index);
    })
  };
}

function main() {
  const data = readJson(jsonPath);
  const nextData = {
    ...data,
    studyInsights: {
      ...data.studyInsights,
      专利代理人: subjectConfigs['专利代理人'].insight,
      法律从业资格: subjectConfigs['法律从业资格'].insight,
      中医执照: subjectConfigs['中医执照'].insight
    },
    subjects: Array.isArray(data.subjects) ? data.subjects.map(enrichSubject) : []
  };
  const jsSource = [
    '// AUTO-GENERATED FROM data.json. DO NOT EDIT DIRECTLY.',
    'const studyData = ' + JSON.stringify(nextData, null, 2) + ';',
    '',
    'export default studyData;',
    ''
  ].join('\n');

  fs.writeFileSync(jsonPath, JSON.stringify(nextData, null, 2) + '\n', 'utf8');
  fs.writeFileSync(jsPath, jsSource, 'utf8');
  console.log('Updated data.json and data.js with unique card content.');
}

main();
