<script def>
{
  "navigationBarTitleText": "妙记"
}
</script>

<script setup>
import wx from 'wx';

export default {
  data: {
    isNavigating: false
  },
  onLoad() {
    var self = this;

    this.welcomeTimer = setTimeout(function() {
      self.goToIndex();
    }, 5000);
  },
  onUnload() {
    if (this.welcomeTimer) {
      clearTimeout(this.welcomeTimer);
      this.welcomeTimer = null;
    }
    if (this.navigationUnlockTimer) {
      clearTimeout(this.navigationUnlockTimer);
      this.navigationUnlockTimer = null;
    }
  },
  goToIndex() {
    var self = this;
    var targetUrl = '/pages/index/index?entry=menu';

    if (this.data.isNavigating) {
      return;
    }

    this.setData({
      isNavigating: true
    });

    if (this.welcomeTimer) {
      clearTimeout(this.welcomeTimer);
      this.welcomeTimer = null;
    }

    if (this.navigationUnlockTimer) {
      clearTimeout(this.navigationUnlockTimer);
      this.navigationUnlockTimer = null;
    }

    wx.redirectTo({
      url: targetUrl,
      fail: function(error) {
        console.error('redirectTo index failed', error);
        self.setData({
          isNavigating: false
        });
      },
      complete: function() {
        self.navigationUnlockTimer = setTimeout(function() {
          self.navigationUnlockTimer = null;
          if (self.data && self.data.isNavigating) {
            self.setData({
              isNavigating: false
            });
          }
        }, 1200);
      }
    });
  },
  handleWelcomeTap() {
    this.goToIndex();
  },
  onKeyDown(event) {
    var code = event && event.code;
    var text = '';

    if (code) {
      text = String(code).toUpperCase();
    } else if (event && event.key) {
      text = String(event.key).toUpperCase();
    } else if (event && event.action) {
      text = String(event.action).toUpperCase();
    }

    if (
      code === 23 ||
      code === 66 ||
      text.indexOf('ENTER') !== -1 ||
      text.indexOf('OK') !== -1 ||
      text.indexOf('RIGHT') !== -1 ||
      text.indexOf('NEXT') !== -1
    ) {
      this.goToIndex();
    }
  }
};
</script>

<page>
  <view class="page" bindtap="handleWelcomeTap">
    <image
      class="welcome-image"
      src="../../assets/images/welcome.png"
      mode="aspectFill"
      bindtap="handleWelcomeTap"
    ></image>
  </view>
</page>

<style>
.page {
  width: 480px;
  height: 352px;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 16px;
  box-sizing: border-box;
  background-color: #050607;
}

.welcome-image {
  width: 100%;
  height: 100%;
  border-radius: 28px;
}

</style>
