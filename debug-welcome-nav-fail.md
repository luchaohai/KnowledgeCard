# Debug Session: welcome-nav-fail
- **Status**: [OPEN]
- **Issue**: 欢迎页点击或按键后无法进入主页 `pages/index/index`
- **Debug Server**: pending
- **Log File**: .dbg/trae-debug-log-welcome-nav-fail.ndjson

## Reproduction Steps
1. 启动应用，进入欢迎页。
2. 点击欢迎页中心区域，或按确认键。
3. 观察是否进入主页 `pages/index/index`。

## Hypotheses & Verification
| ID | Hypothesis | Likelihood | Effort | Evidence |
|----|------------|------------|--------|----------|
| A | `bindtap` / `onKeyDown` 没有触发到欢迎页 | High | Low | Pending |
| B | `goToIndex()` 已触发，但路由 API 调用失败 | High | Low | Pending |
| C | 已发生跳转，但 `index.ink` 加载阶段异常导致页面未呈现 | Med | Med | Pending |
| D | 欢迎页状态锁 `isNavigating` 或重复触发导致后续跳转被吞 | Med | Low | Pending |
| E | 宿主不支持当前点击交互，仅支持硬件按键进入 | Med | Low | Pending |

## Log Evidence
- Pending

## Verification Conclusion
- Pending
