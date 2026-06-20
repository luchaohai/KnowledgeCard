<script def>
{
  "navigationBarTitleText": "知识小卡片"
}
</script>

<script setup>
export default {
  data: {
    currentIndex: 0,
    cardPageText: '1/1',
    currentCard: {
      id: 0,
      title: '',
      image: '',
      scene: '',
      content: '',
      symbols: [],
      memoryKey: '',
      memoryHint: ''
    },
    cardFlipped: false,
    recallMode: false,
    revealedSymbols: [],
    nodEnabled: false,
    memoryList: [],
    memoryReviewDelayMs: 18000,
    cardMotionClass: '',
    voiceEnabled: false,
    voiceListening: false,
    voiceStatus: '卡片已准备好',
    lastTranscript: '未收到语音',
    cards: [
      {
        id: 1,
        title: '丝绸之路',
        image: '../../assets/illustrations/silk-road.svg',
        scene: '驼队穿过沙海，连通多地贸易路线',
        content: '丝绸之路不是单一路线，而是连接东亚、中亚、西亚与欧洲的贸易网络。丝绸之路不是单一路线，而是连接东亚、中亚、西亚与欧洲的贸易网络。丝绸之路不是单一路线，而是连接东亚、中亚、西亚与欧洲的贸易网络。丝绸之路不是单一路线，而是连接东亚、中亚、西亚与欧洲的贸易网络。',
        symbols: ['驼队', '沙海', '地图'],
        memoryKey: '商路',
        memoryHint: '看到骆驼和地图，就联想到跨区域贸易网络。'
      },
      {
        id: 2,
        title: '光年',
        image: '../../assets/illustrations/light-year.svg',
        scene: '一束光在星空中高速前进，用来衡量超远距离',
        content: '光年是距离单位，不是时间单位，表示光在真空中一年传播的距离。',
        symbols: ['光束', '星空', '距离'],
        memoryKey: '尺子',
        memoryHint: '把光年想成宇宙里的尺子，不要和时间单位混淆。'
      },
      {
        id: 3,
        title: '板块运动',
        image: '../../assets/illustrations/plate-motion.svg',
        scene: '两块地壳相互推挤，慢慢抬升出山脉',
        content: '地球表面的大陆并非静止不动，板块运动会形成山脉、海沟和地震带。',
        symbols: ['板块', '山脉', '地震'],
        memoryKey: '碰撞',
        memoryHint: '看到地壳相撞抬升，就想到山脉和地震带。'
      },
      {
        id: 4,
        title: '树木通信',
        image: '../../assets/illustrations/tree-network.svg',
        scene: '树根与菌丝在地下连接，互相传递信号和养分',
        content: '森林中的树木可以通过地下真菌网络交换养分和化学信号。',
        symbols: ['树根', '菌丝', '协作'],
        memoryKey: '网络',
        memoryHint: '把地下菌丝网络看作森林的信息线缆。'
      }
    ]
  },
  onLoad() {
    var firstCard = this.data.cards.length ? this.data.cards[0] : null;
    this.setData({
      currentIndex: 0,
      cardPageText: this.getCardPageText(0),
      currentCard: firstCard || this.getEmptyCard(),
      cardFlipped: false,
      cardMotionClass: '',
      voiceStatus: firstCard ? '已加载 ' + firstCard.title : '当前没有知识卡片',
      lastTranscript: '未收到语音'
    });
    this.initVoiceRecognition();
    this.initNodSensor();
  },
  onUnload() {
    this.clearMotionTimers();
    this.clearRecallTimers();
    this.clearMemoryReviewTimer();
    this.stopNodSensor();
    this.stopVoiceRecognition();
  },
  initVoiceRecognition() {
    if (typeof SpeechRecognition !== 'function') {
      this.setData({
        voiceEnabled: false,
        voiceListening: false,
        voiceStatus: '当前环境暂不支持语音',
        lastTranscript: '语音识别不可用'
      });
      return;
    }

    try {
      this.voiceRecognition = new SpeechRecognition();
      this.voiceRecognition.lang = 'zh-CN';
      this.voiceRecognition.continuous = false;
      this.voiceRecognition.interimResults = false;
      this.voiceRecognition.maxAlternatives = 1;

      this.voiceRecognition.onstart = () => {
        this.setData({
          voiceEnabled: true,
          voiceListening: true,
          voiceStatus: '正在听你说话',
          lastTranscript: '语音识别已开始'
        });
      };

      this.voiceRecognition.onresult = (event) => {
        var transcript = this.extractTranscript(event);
        this.setData({
          voiceListening: false,
          lastTranscript: transcript || '没有识别到有效语音'
        });
        this.handleVoiceCommand(transcript);
      };

      this.voiceRecognition.onerror = (event) => {
        var message = '语音识别失败';
        if (event && (event.message || event.error)) {
          message = String(event.message || event.error);
        }
        this.setData({
          voiceEnabled: true,
          voiceListening: false,
          voiceStatus: '语音识别出错',
          lastTranscript: message
        });
      };

      this.voiceRecognition.onend = () => {
        this.setData({
          voiceEnabled: true,
          voiceListening: false
        });
      };

      this.setData({
        voiceEnabled: true,
        voiceStatus: '可以说 下一张 或 记住了',
        lastTranscript: '未收到语音'
      });
    } catch (error) {
      this.setData({
        voiceEnabled: false,
        voiceListening: false,
        voiceStatus: '语音入口初始化失败',
        lastTranscript: error && error.message ? error.message : '未知错误'
      });
    }
  },
  extractTranscript(event) {
    var resultIndex;
    var result;

    if (!event || !event.results || !event.results.length) {
      return '';
    }

    resultIndex = typeof event.resultIndex === 'number' ? event.resultIndex : 0;
    result = event.results[resultIndex] || event.results[0];

    if (!result || !result.length || !result[0]) {
      return '';
    }

    return result[0].transcript ? String(result[0].transcript).trim() : '';
  },
  normalizeVoiceText(text) {
    if (!text) {
      return '';
    }

    return String(text)
      .replace(/\s+/g, '')
      .replace(/[，。、“”"'`~!@#$%^&*()_+\-=\[\]{};:<>?/\\|]/g, '');
  },
  startVoiceRecognition() {
    if (!this.voiceRecognition || this.data.voiceListening) {
      return;
    }

    try {
      this.voiceRecognition.start();
    } catch (error) {
      this.setData({
        voiceStatus: '语音启动失败',
        lastTranscript: error && error.message ? error.message : '无法启动语音识别'
      });
    }
  },
  stopVoiceRecognition() {
    if (!this.voiceRecognition) {
      return;
    }

    try {
      this.voiceRecognition.abort();
    } catch (error) {
      // ignore inactive session errors
    }
  },
  clearMotionTimers() {
    if (this.motionTimer) {
      clearTimeout(this.motionTimer);
      this.motionTimer = null;
    }
    if (this.motionResetTimer) {
      clearTimeout(this.motionResetTimer);
      this.motionResetTimer = null;
    }
  },
  clearRecallTimers() {
    if (this.recallTimer) {
      clearTimeout(this.recallTimer);
      this.recallTimer = null;
    }
  },
  clearMemoryReviewTimer() {
    if (this.memoryReviewTimer) {
      clearTimeout(this.memoryReviewTimer);
      this.memoryReviewTimer = null;
    }
  },
  initNodSensor() {
    if (typeof AbsoluteOrientationSensor !== 'function') {
      this.setData({
        nodEnabled: false
      });
      return;
    }

    try {
      this.orientationSensor = new AbsoluteOrientationSensor({
        frequency: 30
      });
      this.nodNeutralPitch = 0;
      this.nodPeakDetected = false;
      this.nodPeakTimestamp = 0;
      this.nodCooldownUntil = 0;

      this.orientationSensor.addEventListener('reading', (event) => {
        this.handleOrientationReading(event);
      });

      this.orientationSensor.addEventListener('error', () => {
        this.setData({
          nodEnabled: false
        });
      });

      this.orientationSensor.start();
      this.setData({
        nodEnabled: true
      });
    } catch (error) {
      this.setData({
        nodEnabled: false
      });
    }
  },
  stopNodSensor() {
    if (!this.orientationSensor) {
      return;
    }

    try {
      this.orientationSensor.stop();
    } catch (error) {
      // ignore inactive sensor errors
    }
  },
  getPitchFromQuaternion(quaternion) {
    var x;
    var y;
    var z;
    var w;

    if (!quaternion || quaternion.length < 4) {
      return 0;
    }

    x = Number(quaternion[0]) || 0;
    y = Number(quaternion[1]) || 0;
    z = Number(quaternion[2]) || 0;
    w = Number(quaternion[3]) || 0;

    return Math.atan2(
      2 * (w * x + y * z),
      1 - 2 * (x * x + y * y)
    );
  },
  handleOrientationReading(event) {
    var quaternion;
    var pitch;
    var delta;
    var now;

    quaternion = event && event.quaternion
      ? event.quaternion
      : this.orientationSensor && this.orientationSensor.quaternion;

    if (!quaternion) {
      return;
    }

    pitch = this.getPitchFromQuaternion(quaternion);
    this.nodNeutralPitch = this.nodNeutralPitch * 0.92 + pitch * 0.08;
    delta = pitch - this.nodNeutralPitch;
    now = Date.now();

    if (!this.data.recallMode || !this.data.cardFlipped || !this.data.nodEnabled) {
      this.nodPeakDetected = false;
      return;
    }

    if (now < this.nodCooldownUntil) {
      return;
    }

    if (!this.nodPeakDetected && Math.abs(delta) > 0.24) {
      this.nodPeakDetected = true;
      this.nodPeakTimestamp = now;
      return;
    }

    if (this.nodPeakDetected) {
      if (Math.abs(delta) < 0.08 && now - this.nodPeakTimestamp < 900) {
        this.nodPeakDetected = false;
        this.nodCooldownUntil = now + 1600;
        this.handleRememberedByNod();
        return;
      }

      if (now - this.nodPeakTimestamp >= 900) {
        this.nodPeakDetected = false;
      }
    }
  },
  resetRecallState() {
    this.clearRecallTimers();
    this.setData({
      recallMode: false,
      revealedSymbols: []
    });
  },
  startRecallReveal() {
    var symbols = this.data.currentCard.symbols || [];
    var title = this.data.currentCard.title || '当前卡片';
    var revealNext = () => {
      var nextIndex = this.data.revealedSymbols.length;
      var nextSymbols;

      if (!this.data.recallMode || nextIndex >= symbols.length) {
        if (this.data.recallMode) {
          this.setData({
            voiceStatus: '回忆模式进行中'
          });
        }
        this.clearRecallTimers();
        return;
      }

      nextSymbols = symbols.slice(0, nextIndex + 1);
      this.setData({
        revealedSymbols: nextSymbols,
        voiceStatus: '正在回忆 ' + title
      });

      this.recallTimer = setTimeout(revealNext, 680);
    };

    this.clearRecallTimers();
    this.setData({
      recallMode: true,
      revealedSymbols: []
    });

    this.recallTimer = setTimeout(revealNext, 420);
  },
  getPageTextByTotal(index, total) {
    if (!total) {
      return '0/0';
    }

    return String(index + 1) + '/' + String(total);
  },
  getCardPageText(index) {
    return this.getPageTextByTotal(index, this.data.cards.length);
  },
  getEmptyCard() {
    return {
      id: 0,
      title: '',
      image: '',
      scene: '',
      content: '',
      symbols: [],
      memoryKey: '',
      memoryHint: ''
    };
  },
  getCardByIndex(index) {
    return this.data.cards[index] || this.getEmptyCard();
  },
  scheduleMemoryReview(memoryList) {
    var i;
    var nextDueAt = 0;
    var delay;
    var list = memoryList || this.data.memoryList;

    this.clearMemoryReviewTimer();

    if (!list.length) {
      return;
    }

    nextDueAt = list[0].dueAt || 0;
    for (i = 1; i < list.length; i += 1) {
      if ((list[i].dueAt || 0) < nextDueAt) {
        nextDueAt = list[i].dueAt || 0;
      }
    }

    delay = Math.max(200, nextDueAt - Date.now());
    this.memoryReviewTimer = setTimeout(() => {
      this.releaseMemoryCards();
    }, delay);
  },
  releaseMemoryCards() {
    var now = Date.now();
    var pending = [];
    var dueCards = [];
    var updatedCards;
    var updateData;
    var i;
    var item;

    for (i = 0; i < this.data.memoryList.length; i += 1) {
      item = this.data.memoryList[i];
      if ((item.dueAt || 0) <= now) {
        dueCards.push({
          id: item.id,
          title: item.title,
          image: item.image,
          scene: item.scene,
          content: item.content,
          symbols: item.symbols,
          memoryKey: item.memoryKey,
          memoryHint: item.memoryHint
        });
      } else {
        pending.push(item);
      }
    }

    if (!dueCards.length) {
      this.scheduleMemoryReview();
      return;
    }

    updatedCards = this.data.cards.slice();
    for (i = 0; i < dueCards.length; i += 1) {
      if (!updatedCards.some((card) => card.id === dueCards[i].id)) {
        updatedCards.push(dueCards[i]);
      }
    }

    updateData = {
      cards: updatedCards,
      memoryList: pending,
      cardPageText: this.getPageTextByTotal(
        Math.min(this.data.currentIndex, Math.max(updatedCards.length - 1, 0)),
        updatedCards.length
      ),
      voiceStatus: dueCards.length === 1
        ? dueCards[0].title + ' 已回到待复习队列'
        : '有卡片回到待复习队列'
    };

    if (!this.data.cards.length && updatedCards.length) {
      updateData.currentIndex = 0;
      updateData.currentCard = updatedCards[0];
      updateData.cardPageText = this.getPageTextByTotal(0, updatedCards.length);
      updateData.cardFlipped = false;
      updateData.recallMode = false;
      updateData.revealedSymbols = [];
      updateData.cardMotionClass = '';
    }

    this.setData(updateData);
    this.scheduleMemoryReview(pending);
  },
  handleRememberedByNod() {
    var rememberedCard;
    var remainingCards;
    var memoryItem;
    var updatedMemoryList;
    var nextIndex = 0;
    var nextCard;

    if (!this.data.currentCard || !this.data.currentCard.id) {
      return;
    }

    rememberedCard = this.data.currentCard;
    remainingCards = this.data.cards.filter((card) => card.id !== rememberedCard.id);
    memoryItem = {
      id: rememberedCard.id,
      title: rememberedCard.title,
      image: rememberedCard.image,
      scene: rememberedCard.scene,
      content: rememberedCard.content,
      symbols: rememberedCard.symbols,
      memoryKey: rememberedCard.memoryKey,
      memoryHint: rememberedCard.memoryHint,
      dueAt: Date.now() + this.data.memoryReviewDelayMs
    };

    if (remainingCards.length) {
      nextIndex = this.data.currentIndex % remainingCards.length;
      nextCard = remainingCards[nextIndex];
    } else {
      nextCard = this.getEmptyCard();
    }

    updatedMemoryList = this.data.memoryList
      .filter((item) => item.id !== rememberedCard.id)
      .concat([memoryItem]);

    this.clearMotionTimers();
    this.clearRecallTimers();
    this.setData({
      cards: remainingCards,
      memoryList: updatedMemoryList,
      currentIndex: nextIndex,
      currentCard: nextCard,
      cardPageText: this.getPageTextByTotal(nextIndex, remainingCards.length),
      cardFlipped: false,
      recallMode: false,
      revealedSymbols: [],
      cardMotionClass: '',
      voiceStatus: rememberedCard.title + ' 已记住，稍后再次回顾',
      lastTranscript: '点头确认'
    });
    this.scheduleMemoryReview(updatedMemoryList);
  },
  handleVoiceCommand(transcript) {
    var text = this.normalizeVoiceText(transcript);

    if (!text) {
      this.setData({
        voiceStatus: '没有识别到清晰指令',
        lastTranscript: '未收到语音'
      });
      return;
    }

    if (
      text.indexOf('记住了') !== -1 ||
      text.indexOf('记住啦') !== -1 ||
      text.indexOf('我记住了') !== -1
    ) {
      this.flipToBack(transcript);
      return;
    }

    if (
      text.indexOf('看正面') !== -1 ||
      text.indexOf('回正面') !== -1 ||
      text.indexOf('回到正面') !== -1
    ) {
      this.flipToFront(transcript);
      return;
    }

    if (
      text.indexOf('下一张') !== -1 ||
      text.indexOf('下一张卡片') !== -1 ||
      text.indexOf('下一个') !== -1 ||
      text.indexOf('下一页') !== -1
    ) {
      this.showNextCard(transcript);
      return;
    }

    if (
      text.indexOf('上一张') !== -1 ||
      text.indexOf('上一页') !== -1 ||
      text.indexOf('上一个') !== -1
    ) {
      this.showPrevCard(transcript);
      return;
    }

    this.openCardByTitle(text, transcript);
  },
  openCardByTitle(normalizedText, transcript) {
    var i;
    var title;

    for (i = 0; i < this.data.cards.length; i += 1) {
      title = this.normalizeVoiceText(this.data.cards[i].title);
      if (title && normalizedText.indexOf(title) !== -1) {
        this.clearMotionTimers();
        this.clearRecallTimers();
        this.setData({
          currentIndex: i,
          cardPageText: this.getCardPageText(i),
          currentCard: this.getCardByIndex(i),
          cardFlipped: false,
          recallMode: false,
          revealedSymbols: [],
          cardMotionClass: '',
          voiceStatus: '已打开 ' + this.data.cards[i].title,
          lastTranscript: transcript
        });
        return;
      }
    }

    this.setData({
      voiceStatus: '未匹配到卡片名称',
      lastTranscript: transcript
    });
  },
  showNextCard(transcript) {
    var nextIndex;

    if (!this.data.cards.length) {
      return;
    }

    this.clearMotionTimers();
    this.clearRecallTimers();
    nextIndex = (this.data.currentIndex + 1) % this.data.cards.length;
    this.setData({
      currentIndex: nextIndex,
      cardPageText: this.getCardPageText(nextIndex),
      currentCard: this.getCardByIndex(nextIndex),
      cardFlipped: false,
      recallMode: false,
      revealedSymbols: [],
      cardMotionClass: '',
      voiceStatus: '已切换到 ' + this.data.cards[nextIndex].title,
      lastTranscript: transcript || '下一张'
    });
  },
  showPrevCard(transcript) {
    var prevIndex;

    if (!this.data.cards.length) {
      return;
    }

    this.clearMotionTimers();
    this.clearRecallTimers();
    prevIndex = (this.data.currentIndex - 1 + this.data.cards.length) % this.data.cards.length;
    this.setData({
      currentIndex: prevIndex,
      cardPageText: this.getCardPageText(prevIndex),
      currentCard: this.getCardByIndex(prevIndex),
      cardFlipped: false,
      recallMode: false,
      revealedSymbols: [],
      cardMotionClass: '',
      voiceStatus: '已切换到 ' + this.data.cards[prevIndex].title,
      lastTranscript: transcript || '上一张'
    });
  },
  flipToBack(transcript) {
    if (!this.data.cards.length || this.data.cardFlipped) {
      this.setData({
        voiceStatus: '当前已经是背面图片',
        lastTranscript: transcript || '记住了'
      });
      return;
    }

    this.clearMotionTimers();
    this.clearRecallTimers();
    this.setData({
      cardMotionClass: 'card-out',
      recallMode: true,
      revealedSymbols: [],
      voiceStatus: '正在进入回忆模式',
      lastTranscript: transcript || '记住了'
    });

    this.motionTimer = setTimeout(() => {
      this.setData({
        cardFlipped: true,
        cardMotionClass: 'card-in',
        voiceStatus: '回忆模式已开启'
      });
      this.startRecallReveal();

      this.motionResetTimer = setTimeout(() => {
        this.setData({
          cardMotionClass: ''
        });
      }, 220);
    }, 160);
  },
  flipToFront(transcript) {
    if (!this.data.cards.length || !this.data.cardFlipped) {
      this.setData({
        voiceStatus: '当前已经是正面内容',
        lastTranscript: transcript || '看正面'
      });
      return;
    }

    this.clearMotionTimers();
    this.clearRecallTimers();
    this.setData({
      cardMotionClass: 'card-out',
      recallMode: false,
      revealedSymbols: [],
      voiceStatus: '正在回到正面内容',
      lastTranscript: transcript || '看正面'
    });

    this.motionTimer = setTimeout(() => {
      this.setData({
        cardFlipped: false,
        cardMotionClass: 'card-in',
        voiceStatus: '已回到正面内容'
      });

      this.motionResetTimer = setTimeout(() => {
        this.setData({
          cardMotionClass: ''
        });
      }, 220);
    }, 160);
  },
  handleNextTap() {
    this.showNextCard('手动点击下一张');
  },
  handleVoiceTap() {
    this.startVoiceRecognition();
  }
};
</script>

<page>
  <view class="page">
    <view class="empty-state" ink:if="{{ !cards.length }}">
      <text class="empty-title">知识卡片</text>
      <text class="empty-copy">当前没有可展示的知识卡片。</text>
    </view>

    <view class="dialog-shell" ink:if="{{ cards.length }}">
      <view class="dialog-card {{ cardMotionClass }}" ink:if="{{ !cardFlipped }}">
        <text class="dialog-page-counter">{{ cardPageText }}</text>
        <view class="dialog-copy">
          <view class="dialog-top-row">
            <text class="dialog-title">{{ currentCard.title }}</text>
          </view>
          <view class="dialog-memory">
            <view class="dialog-memory-head">
              <text class="dialog-memory-label">keyword</text>
              <text class="dialog-memory-key">{{ currentCard.memoryKey }}</text>
              <view class="dialog-memory-grid">
                <view class="dialog-memory-cell" ink:for="{{ currentCard.symbols }}" ink:key="index">
                  <text class="dialog-memory-cell-text">{{ item }}</text>
                </view>
              </view>
            </view>
            <text class="dialog-memory-hint">{{ currentCard.memoryHint }}</text>
          </view>
          <view class="dialog-body">
            <view class="dialog-reading">
              <text class="dialog-scene">{{ currentCard.scene }}</text>
              <text class="dialog-content">{{ currentCard.content }}</text>
            </view>
          </view>
        </view>
      </view>

      <view class="dialog-card {{ cardMotionClass }}" ink:else>
        <text class="dialog-page-counter">{{ cardPageText }}</text>
        <view class="dialog-back">
          <image class="dialog-back-image" src="{{ currentCard.image }}" mode="aspectFill"></image>
          <text class="dialog-back-title">{{ currentCard.title }}</text>
          <view class="dialog-recall" ink:if="{{ recallMode }}">
            <text class="dialog-recall-label">回忆模式</text>
            <view class="dialog-recall-symbols">
              <text class="dialog-recall-symbol" ink:for="{{ revealedSymbols }}" ink:key="index">{{ item }}</text>
            </view>
          </view>
        </view>
      </view>

      <view class="dialog-bubble user-bubble">
        <text class="dialog-role">你</text>
        <text class="dialog-bubble-text">{{ lastTranscript }}</text>
      </view>

      <view class="dialog-bubble assistant-bubble">
        <text class="dialog-role">卡片</text>
        <text class="dialog-bubble-text">{{ voiceStatus }}</text>
      </view>

      <view class="dialog-actions">
        <button class="ghost-button" bindtap="handleVoiceTap">
          <text ink:if="{{ voiceListening }}">正在说话</text>
          <text ink:else>开始语音</text>
        </button>
        <button class="primary-button" bindtap="handleNextTap">下一张</button>
      </view>
    </view>
  </view>
</page>

<style>
.page {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  min-height: 100vh;
  padding: 14px;
  box-sizing: border-box;
  background-color: #000000;
}

.dialog-shell {
  width: 100%;
  max-width: 440px;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.dialog-card {
  position: relative;
  width: 100%;
  min-height: 320px;
  padding: 14px;
  box-sizing: border-box;
  border: var(--border-width-thin) solid rgba(64, 255, 94, 0.42);
  border-radius: 12px;
  background-color: rgba(7, 18, 10, 0.52);
}

.dialog-page-counter {
  position: absolute;
  top: 12px;
  right: 12px;
  padding: 3px 8px;
  box-sizing: border-box;
  border-radius: 999px;
  border: var(--border-width-thin) solid rgba(64, 255, 94, 0.26);
  background-color: rgba(64, 255, 94, 0.05);
  color: rgba(233, 255, 237, 0.78);
  font-size: 11px;
  line-height: 15px;
}

.card-out {
  animation: card-out 0.16s ease forwards;
}

.card-in {
  animation: card-in 0.22s ease forwards;
}

.dialog-copy {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding-top: 8px;
}

.dialog-top-row {
  display: flex;
  align-items: flex-start;
  width: 100%;
  gap: 12px;
}

.dialog-body {
  display: flex;
  flex-direction: column;
  gap: 8px;
  min-height: 132px;
}

.dialog-reading {
  flex: 3;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.dialog-title {
  width: 100%;
  color: var(--color-text-primary);
  font-size: 28px;
  line-height: 34px;
  font-weight: bold;
}

.dialog-scene {
  color: rgba(233, 255, 237, 0.84);
  font-size: 14px;
  line-height: 20px;
}

.dialog-content {
  color: rgba(190, 255, 204, 0.76);
  font-size: 14px;
  line-height: 22px;
}

.dialog-back {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.dialog-back-image {
  width: 100%;
  height: 168px;
  border-radius: 8px;
  border: var(--border-width-thin) solid rgba(64, 255, 94, 0.34);
}

.dialog-back-title {
  color: rgba(233, 255, 237, 0.96);
  font-size: 18px;
  line-height: 24px;
}

.dialog-recall {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 10px 12px;
  box-sizing: border-box;
  border: var(--border-width-thin) dashed rgba(64, 255, 94, 0.28);
  border-radius: 10px;
  background-color: rgba(64, 255, 94, 0.03);
}

.dialog-recall-label {
  color: rgba(64, 255, 94, 0.92);
  font-size: 13px;
  line-height: 17px;
  font-weight: bold;
}

.dialog-recall-symbols {
  display: flex;
  flex-wrap: wrap;
  justify-content: flex-start;
  align-items: flex-start;
  gap: 6px;
}

.dialog-recall-symbol {
  padding: 4px 8px;
  box-sizing: border-box;
  border-radius: 8px;
  border: var(--border-width-thin) solid rgba(64, 255, 94, 0.3);
  background-color: rgba(64, 255, 94, 0.05);
  color: rgba(233, 255, 237, 0.92);
  font-size: 12px;
  line-height: 16px;
}

.dialog-memory {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 6px;
  padding: 8px 10px 9px;
  box-sizing: border-box;
  border: var(--border-width-thin) dashed rgba(64, 255, 94, 0.26);
  border-radius: 10px;
  background-color: rgba(64, 255, 94, 0.02);
}

.dialog-memory-head {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-start;
  gap: 6px;
}

.dialog-memory-label {
  color: rgba(64, 255, 94, 0.9);
  font-size: 14px;
  line-height: 18px;
  font-weight: bold;
  text-transform: uppercase;
}

.dialog-memory-key {
  padding: 3px 7px;
  box-sizing: border-box;
  border-radius: 4px;
  background-color: #D9FF7A;
  color: #07120A;
  font-size: 11px;
  line-height: 15px;
}

.dialog-memory-grid {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-wrap: wrap;
  justify-content: flex-start;
  align-items: flex-start;
  align-content: flex-start;
  gap: 6px;
}

.dialog-memory-cell {
  flex: 0 0 auto;
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 28px;
  min-width: 58px;
  padding: 5px 8px;
  box-sizing: border-box;
  border: var(--border-width-thin) dashed rgba(64, 255, 94, 0.3);
  border-radius: 8px;
  background-color: rgba(64, 255, 94, 0.03);
}

.dialog-memory-cell-text {
  color: rgba(233, 255, 237, 0.9);
  font-size: 12px;
  line-height: 16px;
  font-weight: bold;
}

.dialog-memory-hint {
  width: 100%;
  color: rgba(190, 255, 204, 0.74);
  font-size: 12px;
  line-height: 16px;
}

.dialog-bubble {
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 10px 12px;
  box-sizing: border-box;
  border-radius: 10px;
}

.user-bubble {
  align-self: flex-end;
  width: calc(100% - 44px);
  border: var(--border-width-thin) solid rgba(64, 255, 94, 0.22);
  background-color: rgba(64, 255, 94, 0.03);
}

.assistant-bubble {
  width: calc(100% - 18px);
  border: var(--border-width-thin) solid rgba(64, 255, 94, 0.34);
  background-color: rgba(10, 24, 12, 0.52);
}

.dialog-role {
  color: rgba(64, 255, 94, 0.9);
  font-size: 11px;
  line-height: 15px;
}

.dialog-bubble-text {
  color: rgba(233, 255, 237, 0.92);
  font-size: 13px;
  line-height: 19px;
}

.dialog-actions {
  display: flex;
  gap: 10px;
}

.ghost-button,
.primary-button {
  flex: 1;
  min-height: 42px;
  border-radius: 12px;
  font-size: 15px;
  line-height: 20px;
}

.ghost-button {
  border: var(--border-width-thin) solid rgba(64, 255, 94, 0.3);
  background-color: rgba(64, 255, 94, 0.04);
  color: rgba(233, 255, 237, 0.94);
}

.primary-button {
  border: var(--border-width-thin) solid rgba(217, 255, 122, 0.9);
  background-color: #D9FF7A;
  color: #07120A;
}

.empty-state {
  width: 100%;
  max-width: 440px;
  padding: 24px 16px;
  box-sizing: border-box;
  border: var(--border-width-thin) dashed rgba(64, 255, 94, 0.26);
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.empty-title {
  color: rgba(233, 255, 237, 0.94);
  font-size: 22px;
  line-height: 28px;
}

.empty-copy {
  color: rgba(190, 255, 204, 0.72);
  font-size: 14px;
  line-height: 20px;
  text-align: center;
}

@keyframes card-out {
  0% {
    opacity: 1;
    transform: scaleX(1);
  }

  100% {
    opacity: 0;
    transform: scaleX(0.94);
  }
}

@keyframes card-in {
  0% {
    opacity: 0;
    transform: scaleX(0.94);
  }

  100% {
    opacity: 1;
    transform: scaleX(1);
  }
}
</style>
