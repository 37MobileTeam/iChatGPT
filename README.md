# iChatGPT
OpenAI ChatGPT app for  iOS, iPadOS, macoS

###  一、App 介绍

<img src="screenshot/01.jpeg" width="800" height:auto alt="iChatGPT app"/>

- 使用和原理介绍：[用 SwiftUI 实现 AI 聊天对话 app - iChatGPT](https://juejin.cn/post/7175051294808211512#heading-6)

**支持功能**

目前 v1.1.0，实现 ChatGPT 基本聊天功能：

* 可以直接与 ChatGPT 对话，并且保留上下文；
* 可以复制问题和回答内容；
* 可以快捷重复提问等


支持系统：
* iOS 14.0+
* iPadOS 14.0+
* macOS 11.0+

**TODO**

* 保存对话
* ~~显示个人头像~~
* 代码没有高亮
* ~~请求失败重试等~~
* 更多功能，欢迎提 PR ~

### 二、安装说明

#### macSO 安装包下载

- [Releases](https://github.com/37iOS/iChatGPT/releases)

> 注：
> 1. iOS 和 iPadOS 需要自行编译安装，暂时不提供安装包。
> 2. 首次打开提示：“无法打开mChatGPT.app”，因为 Apple 无法检查其是否包含恶意软件。”，请选中 app 后点击右键->打开，即可正常打开。

#### Xcode 构建

- 构建依赖：Xcode14

下载项目后，双击 `iChatGPT.xcodeproj` 打开项目构建。

> 注：依赖其它组件，需要保证能访问 GitHub 服务。


### 三、FAQ

- [New Issue](https://github.com/37iOS/iChatGPT/issues/new/choose)


### 四、效果示例

<img src="screenshot/02.jpeg" width="800" height:auto alt="screenshot/02.jpeg"/>
<img src="screenshot/03.jpeg" width="800" height:auto alt="screenshot/03.jpeg"/>
<img src="screenshot/04.jpeg" width="800" height:auto alt="screenshot/04.jpeg"/>
<img src="screenshot/05.jpeg" width="800" height:auto alt="screenshot/05.jpeg"/>
<img src="screenshot/06.jpeg" width="800" height:auto alt="screenshot/06.jpeg"/>
<img src="screenshot/07.jpeg" width="800" height:auto alt="screenshot/07.jpeg"/>


### 五、特别鸣谢

- [OpenAI ChatGPT](https://chat.openai.com/)
- [OpenAI Blog](https://openai.com/blog/)
- [A-kirami/nonebot-plugin-chatgpt](https://github.com/A-kirami/nonebot-plugin-chatgpt)
- [shaps80/MarkdownText](https://github.com/shaps80/MarkdownText)